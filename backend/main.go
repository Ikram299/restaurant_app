package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"regexp"
	"strings"
	"time"

	"restaurant-app/backend/handlers" // Importez votre package handlers
	"restaurant-app/backend/models"   // Assurez-vous que ce chemin correspond à votre projet

	"github.com/joho/godotenv"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/driver/sqlite" // Si vous utilisez SQLite, sinon remplacez par votre pilote DB
	"gorm.io/gorm"
)

// Déclarations de variables globales
var DB *gorm.DB       // Connexion à la base de données GORM
var adminToken string // Variable globale pour stocker le token admin du .env
var serverPort string // Variable globale pour stocker le port du serveur
var serverURL string  // Variable globale pour stocker l'URL du serveur (pour les chemins d'images)

// init est une fonctiq on spéciale de Go qui s'exécute au démarrage du programme, AVANT main().
func init() {
	// Charger les variables d'environnement en premier
	err := godotenv.Load() // Charge les variables depuis le fichier .env
	if err != nil {
		// Log un avertissement si le .env n'est pas trouvé, mais permet de continuer
		// (utile pour les environnements de déploiement où les variables sont déjà définies)
		log.Printf("DEBUG GO: AVERTISSEMENT: Pas de fichier .env trouvé, en utilisant les variables d'environnement système ou les valeurs par défaut. Erreur: %v", err)
	}

	// Récupérer le token admin et le port du serveur
	adminToken = os.Getenv("ADMIN_TOKEN")
	if adminToken == "" {
		log.Println("DEBUG GO: ERREUR DE CONFIGURATION: ADMIN_TOKEN non défini dans .env ou environnement. Les routes admin seront non sécurisées ou inaccessibles.")
	}
	serverPort = os.Getenv("PORT")
	if serverPort == "" {
		serverPort = "8080" // Port par défaut si non défini
		log.Printf("DEBUG GO: PORT non défini dans .env ou environnement. Utilisation du port par défaut: %s", serverPort)
	}

	// Récupérer l'URL du serveur (pour les images)
	serverURL = os.Getenv("SERVER_URL")
	if serverURL == "" {
		serverURL = fmt.Sprintf("http://localhost:%s", serverPort) // Valeur par défaut
		log.Printf("DEBUG GO: SERVER_URL non défini dans .env ou environnement. Utilisation du défaut: %s", serverURL)
	}

	// Connexion à la base de données SQLite
	// Remplacez 'sqlite.Open("restaurant-app.db")' si vous utilisez une autre base de données
	DB, err = gorm.Open(sqlite.Open("restaurant-app.db"), &gorm.Config{})
	if err != nil {
		log.Fatal("DEBUG GO: Échec de la connexion à la base de données :", err)
	}

	// Migration automatique des modèles
	err = DB.AutoMigrate(
		&models.Client{},
		&models.Plat{},
		&models.Panier{},
		&models.Reservation{},
		&models.Commande{},
		&models.Paiement{},
		&models.Notification{},
		&models.CommandePlat{},
		&models.PanierPlat{},
	)
	if err != nil {
		log.Fatal("DEBUG GO: Erreur lors de la migration de la base de données :", err)
	}
	fmt.Println("DEBUG GO: Base de données connectée et migrée avec succès.")
	fmt.Printf("DEBUG GO: Serveur prêt sur le port %s. ADMIN_TOKEN configuré.\n", serverPort)
}

// Middleware pour autoriser les requêtes CORS et gérer les requêtes OPTIONS (pre-flight)
func enableCors(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*") // Autorise toutes les origines pour le développement
	w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
	// Ajout de "X-Admin-Token" aux en-têtes autorisés
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Admin-Token")
	// Gérer la requête OPTIONS pour le pre-flight CORS
	if r.Method == http.MethodOptions {
		w.WriteHeader(http.StatusOK) // Répond 200 OK pour la requête OPTIONS
		return
	}
}

// Middleware pour l'authentification Admin
// Ce middleware protège les routes qui ne doivent être accessibles qu'aux administrateurs.
func adminAuthMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		enableCors(w, r) // S'assure que CORS est géré pour ce middleware aussi

		// enableCors gère déjà les OPTIONS, donc si c'est une requête OPTIONS, on a déjà répondu
		if r.Method == http.MethodOptions {
			return
		}

		// Récupère le token de l'en-tête "X-Admin-Token"
		token := r.Header.Get("X-Admin-Token")
		if token == "" {
			// Alternative: Supporte aussi l'en-tête "Authorization: Bearer <token>"
			authHeader := r.Header.Get("Authorization")
			if len(authHeader) > 7 && authHeader[:7] == "Bearer " {
				token = authHeader[7:]
			}
		}

		// Vérifie si le ADMIN_TOKEN est configuré côté backend
		if adminToken == "" {
			log.Println("DEBUG GO: Erreur de configuration: ADMIN_TOKEN non défini dans le backend. Impossible de vérifier l'authentification.")
			http.Error(w, "Erreur de configuration du serveur. Veuillez contacter l'administrateur.", http.StatusInternalServerError)
			return
		}

		// Compare le token fourni avec le token attendu
		if token != adminToken {
			log.Printf("DEBUG GO: Accès admin refusé. Token fourni: '%s' (attendu: '%s')", token, adminToken)
			http.Error(w, "Accès administrateur requis. Authentification invalide.", http.StatusForbidden)
			return
		}

		log.Println("DEBUG GO: Accès admin autorisé.")
		next.ServeHTTP(w, r) // Passe au handler suivant si l'authentification réussit
	}
}

// --- HANDLERS D'AUTHENTIFICATION (Login et Signup) ---

func loginHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(w, r)
	if r.Method == http.MethodOptions {
		return
	}

	var loginReq models.Client
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(&loginReq)
	if err != nil {
		log.Printf("DEBUG GO: Erreur de décodage JSON de la requête de connexion: %v", err)
		http.Error(w, "Requête invalide", http.StatusBadRequest)
		return
	}

	log.Printf("DEBUG GO: Tentative de connexion pour l'email: %s", loginReq.Email)

	var storedClient models.Client
	if err := DB.Where("email = ?", loginReq.Email).First(&storedClient).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			log.Printf("DEBUG GO: Client non trouvé pour l'email: %s", loginReq.Email)
			http.Error(w, "Identifiants incorrects", http.StatusUnauthorized)
			return
		}
		log.Printf("DEBUG GO: Erreur lors de la récupération du client de la DB: %v", err)
		http.Error(w, "Erreur interne du serveur", http.StatusInternalServerError)
		return
	}

	err = bcrypt.CompareHashAndPassword([]byte(storedClient.MotDePasseHashed), []byte(loginReq.MotDePasse))
	if err != nil {
		log.Printf("DEBUG GO: Mot de passe incorrect pour l'email %s: %v", loginReq.Email, err)
		http.Error(w, "Identifiants incorrects", http.StatusUnauthorized)
		return
	}

	// Connexion réussie - Prépare la réponse pour Flutter
	clientResponse := map[string]interface{}{
		"ID":           storedClient.ID,
		"email":        storedClient.Email,
		"nomClient":    storedClient.NomClient,
		"prenomClient": storedClient.PrenomClient,
		"numTel":       storedClient.NumTel,
		"adresse":      storedClient.Adresse,
		"isAdmin":      storedClient.IsAdmin, // Ceci envoie bien le statut isAdmin à Flutter
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(clientResponse)
	log.Printf("DEBUG GO: Connexion réussie pour l'email: %s (isAdmin: %v)", loginReq.Email, storedClient.IsAdmin)
}

func signupHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(w, r)
	if r.Method == http.MethodOptions {
		return
	}

	log.Println("DEBUG GO: Requête reçue sur le handler /signup")

	var clientData models.Client
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(&clientData)
	if err != nil {
		log.Printf("DEBUG GO: Erreur de décodage JSON à l'inscription: %v", err)
		http.Error(w, "Requête invalide", http.StatusBadRequest)
		return
	}

	log.Printf("DEBUG GO: Données client reçues pour inscription: Email=%s, Nom=%s, IsAdmin=%v", clientData.Email, clientData.NomClient, clientData.IsAdmin)

	// Vérifie que l'email n'existe pas déjà
	var existingClient models.Client
	if err := DB.Where("email = ?", clientData.Email).First(&existingClient).Error; err == nil {
		log.Printf("DEBUG GO: Tentative d'inscription avec un email déjà utilisé: %s", clientData.Email)
		http.Error(w, "Email déjà utilisé", http.StatusConflict)
		return
	} else if !errors.Is(err, gorm.ErrRecordNotFound) { // Gère les autres erreurs DB
		log.Printf("DEBUG GO: Erreur DB lors de la vérification de l'email: %v", err)
		http.Error(w, "Erreur serveur lors de la vérification de l'email.", http.StatusInternalServerError)
		return
	}

	// Hacher le mot de passe avant de l'enregistrer
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(clientData.MotDePasse), bcrypt.DefaultCost)
	if err != nil {
		log.Printf("DEBUG GO: Erreur lors du hachage du mot de passe: %v", err)
		http.Error(w, "Erreur interne du serveur lors du hachage", http.StatusInternalServerError)
		return
	}

	// Crée une nouvelle instance de Client pour la base de données avec le hachage
	newClient := models.Client{
		Email:            clientData.Email,
		NomClient:        clientData.NomClient,
		PrenomClient:     clientData.PrenomClient,
		MotDePasseHashed: string(hashedPassword), // Stocke le HACHAGE ici
		NumTel:           clientData.NumTel,
		Adresse:          clientData.Adresse,
		IsAdmin:          clientData.IsAdmin, // Utilise la valeur isAdmin reçue du frontend
	}

	// Ajoute le client dans la base
	if err := DB.Create(&newClient).Error; err != nil {
		log.Printf("DEBUG GO: Erreur lors de l'inscription du client dans la DB: %v", err)
		http.Error(w, "Échec de l'inscription", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	fmt.Fprintln(w, "Inscription réussie")
	log.Printf("DEBUG GO: Client inscrit avec succès: %s (isAdmin: %v)", newClient.Email, newClient.IsAdmin)
}

// --- HANDLERS DE RÉSERVATION (Côté CLIENT) ---

// createReservationHandler gère la création d'une nouvelle réservation par un client.
// Méthode: POST /api/reservations
func createReservationHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(w, r)
	if r.Method == http.MethodOptions {
		return
	}

	if r.Method != http.MethodPost {
		http.Error(w, "Méthode non autorisée", http.StatusMethodNotAllowed)
		return
	}

	var reservation models.Reservation
	if err := json.NewDecoder(r.Body).Decode(&reservation); err != nil {
		log.Printf("DEBUG GO: Erreur de décodage JSON pour création réservation: %v", err)
		http.Error(w, "Requête invalide: format JSON incorrect.", http.StatusBadRequest)
		return
	}

	// Validation des champs obligatoires
	if reservation.ClientName == "" || reservation.ClientEmail == "" || reservation.ClientPhone == "" || reservation.NumGuests <= 0 || reservation.ReservationDate.IsZero() {
		http.Error(w, "Tous les champs obligatoires (nom, email, téléphone, nombre de convives, date) doivent être remplis et valides.", http.StatusBadRequest)
		log.Println("DEBUG GO: Champs obligatoires de réservation manquants ou invalides.")
		return
	}
	// Validation simple de l'email
	if !regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$`).MatchString(reservation.ClientEmail) {
		http.Error(w, "Email invalide.", http.StatusBadRequest)
		log.Printf("DEBUG GO: Email invalide fourni: %s", reservation.ClientEmail)
		return
	}

	// Validation de la date : doit être dans le futur (ou aujourd'hui, après l'heure actuelle si la date est aujourd'hui)
	now := time.Now()
	// Réinitialise l'heure de la date de réservation à 00:00:00 pour une comparaison simple par date
	reservationDateOnly := time.Date(reservation.ReservationDate.Year(), reservation.ReservationDate.Month(), reservation.ReservationDate.Day(), 0, 0, 0, 0, now.Location())
	todayDateOnly := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())

	if reservationDateOnly.Before(todayDateOnly) {
		http.Error(w, "La date de réservation ne peut pas être dans le passé.", http.StatusBadRequest)
		log.Printf("DEBUG GO: Réservation refusée, date dans le passé: %s", reservation.ReservationDate.String())
		return
	}

	// Si la date est aujourd'hui, vérifier que l'heure n'est pas dans le passé
	if reservationDateOnly.Equal(todayDateOnly) {
		if reservation.ReservationDate.Before(now) { // Compare la date/heure de la réservation avec l'heure actuelle
			http.Error(w, "L'heure de réservation ne peut pas être dans le passé pour aujourd'hui.", http.StatusBadRequest)
			log.Printf("DEBUG GO: Réservation refusée, heure dans le passé pour aujourd'hui: %s", reservation.ReservationDate.String())
			return
		}
	}

	reservation.Status = "En attente" // Définir le statut par défaut pour toute nouvelle réservation

	if err := DB.Create(&reservation).Error; err != nil {
		log.Printf("DEBUG GO: Erreur DB lors de la création de la réservation: %v", err)
		http.Error(w, "Échec de la création de la réservation. Veuillez réessayer.", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(map[string]interface{}{
		"message":     "Réservation créée avec succès!",
		"reservation": reservation, // Retourne la réservation créée, y compris son ID généré
	})
	log.Printf("DEBUG GO: Réservation créée par client: %s (ID: %s)", reservation.ClientName, reservation.ID)
}

// getReservationByIDHandler récupère une réservation spécifique par son ID.
// Méthode: GET /api/reservations/{id}
func getReservationByIDHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(w, r)
	if r.Method == http.MethodOptions {
		return
	}

	if r.Method != http.MethodGet {
		http.Error(w, "Méthode non autorisée", http.StatusMethodNotAllowed)
		return
	}

	// Extrait l'ID de la réservation de l'URL
	pathSegments := strings.Split(r.URL.Path, "/")
	if len(pathSegments) < 4 || pathSegments[3] == "" { // Vérifie qu'il y a un segment pour l'ID
		http.Error(w, "ID de réservation manquant ou URL invalide.", http.StatusBadRequest)
		return
	}
	id := pathSegments[3] // L'ID est le 4ème segment (indice 3)

	var reservation models.Reservation
	if err := DB.Where("id = ?", id).First(&reservation).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			http.Error(w, "Réservation non trouvée.", http.StatusNotFound)
			log.Printf("DEBUG GO: Réservation non trouvée pour ID: %s", id)
			return
		}
		log.Printf("DEBUG GO: Erreur DB lors de la récupération de la réservation (ID: %s): %v", id, err)
		http.Error(w, "Erreur serveur lors de la récupération de la réservation.", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(reservation)
	log.Printf("DEBUG GO: Réservation récupérée pour ID: %s", id)
}

// cancelReservationHandler permet à un client d'annuler sa réservation.
// Méthode: PUT /api/reservations/cancel/{id}
func cancelReservationHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(w, r)
	if r.Method == http.MethodOptions {
		return
	}

	if r.Method != http.MethodPut {
		http.Error(w, "Méthode non autorisée", http.StatusMethodNotAllowed)
		return
	}

	// Extrait l'ID de la réservation de l'URL
	pathSegments := strings.Split(r.URL.Path, "/")
	if len(pathSegments) < 5 || pathSegments[4] == "" { // L'ID est le 5ème segment (indice 4)
		http.Error(w, "ID de réservation manquant ou URL invalide.", http.StatusBadRequest)
		return
	}
	id := pathSegments[4]

	var reservation models.Reservation
	if err := DB.Where("id = ?", id).First(&reservation).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			http.Error(w, "Réservation non trouvée.", http.StatusNotFound)
			log.Printf("DEBUG GO: Annulation: Réservation non trouvée pour ID: %s", id)
			return
		}
		log.Printf("DEBUG GO: Erreur DB lors de la récupération pour annulation (ID: %s): %v", id, err)
		http.Error(w, "Erreur serveur lors de l'annulation.", http.StatusInternalServerError)
		return
	}

	// Empêche d'annuler une réservation déjà annulée ou terminée
	if reservation.Status == "Annulée" || reservation.Status == "Terminée" {
		http.Error(w, "Cette réservation ne peut pas être annulée dans son état actuel.", http.StatusBadRequest)
		log.Printf("DEBUG GO: Tentative d'annuler une réservation de statut '%s' (ID: %s)", reservation.Status, id)
		return
	}

	reservation.Status = "Annulée" // Met à jour le statut
	if err := DB.Save(&reservation).Error; err != nil {
		log.Printf("DEBUG GO: Échec de l'enregistrement de l'annulation (ID: %s): %v", id, err)
		http.Error(w, "Échec de l'annulation de la réservation.", http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "Réservation annulée avec succès!"})
	log.Printf("DEBUG GO: Réservation annulée par client (ID: %s)", id)
}

// --- HANDLERS DE RÉSERVATION (Côté ADMIN - Protégés par adminAuthMiddleware) ---

// getAllReservationsAdminHandler récupère toutes les réservations, avec un filtre optionnel par statut.
// Méthode: GET /admin/reservations?status={statut}
func getAllReservationsAdminHandler(w http.ResponseWriter, r *http.Request) {
	// Le middleware adminAuthMiddleware a déjà appelé enableCors
	if r.Method != http.MethodGet {
		http.Error(w, "Méthode non autorisée", http.StatusMethodNotAllowed)
		return
	}

	var reservations []models.Reservation
	statusFilter := r.URL.Query().Get("status") // Récupère le paramètre de requête "status"

	query := DB.Order("reservation_date ASC") // Trier uniquement par date
	if statusFilter != "" && statusFilter != "Tous" {
		query = query.Where("status = ?", statusFilter)
	}

	if err := query.Find(&reservations).Error; err != nil {
		log.Printf("DEBUG GO: Erreur DB lors de la récupération des réservations (filtre: %s): %v", statusFilter, err)
		http.Error(w, "Échec de la récupération des réservations.", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(reservations)
	log.Printf("DEBUG GO: Toutes les réservations récupérées par admin (filtré par statut: '%s').", statusFilter)
}

// updateReservationAdminHandler met à jour une réservation existante (par admin).
// Méthode: PUT /admin/reservations/{id}
func updateReservationAdminHandler(w http.ResponseWriter, r *http.Request) {
	// Le middleware adminAuthMiddleware a déjà appelé enableCors
	if r.Method != http.MethodPut {
		http.Error(w, "Méthode non autorisée", http.StatusMethodNotAllowed)
		return
	}

	// Extrait l'ID de la réservation de l'URL
	pathSegments := strings.Split(r.URL.Path, "/")
	if len(pathSegments) < 4 || pathSegments[3] == "" {
		http.Error(w, "ID de réservation manquant dans l'URL.", http.StatusBadRequest)
		return
	}
	id := pathSegments[3]

	var reservation models.Reservation
	if err := DB.Where("id = ?", id).First(&reservation).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			http.Error(w, "Réservation non trouvée.", http.StatusNotFound)
			log.Printf("DEBUG GO: Réservation non trouvée pour mise à jour par admin (ID: %s)", id)
			return
		}
		log.Printf("DEBUG GO: Erreur DB lors de la récupération de la réservation pour mise à jour (ID: %s): %v", id, err)
		http.Error(w, "Erreur serveur.", http.StatusInternalServerError)
		return
	}

	// Décode le corps de la requête dans un map pour une mise à jour partielle
	var updateData map[string]interface{}
	if err := json.NewDecoder(r.Body).Decode(&updateData); err != nil {
		log.Printf("DEBUG GO: Erreur de décodage JSON pour mise à jour réservation: %v", err)
		http.Error(w, "Requête invalide: format JSON incorrect.", http.StatusBadRequest)
		return
	}

	// Met à jour les champs (validation manuelle)
	if status, ok := updateData["status"].(string); ok {
		validStatuses := map[string]bool{"En attente": true, "Confirmée": true, "Annulée": true, "Terminée": true}
		if !validStatuses[status] {
			http.Error(w, "Statut de réservation invalide.", http.StatusBadRequest)
			log.Printf("DEBUG GO: Tentative de mise à jour avec un statut invalide: %s", status)
			return
		}
		reservation.Status = status
	}
	if clientName, ok := updateData["client_name"].(string); ok {
		reservation.ClientName = clientName
	}
	if clientEmail, ok := updateData["client_email"].(string); ok {
		// Re-valider l'email si modifié
		if !regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$`).MatchString(clientEmail) {
			http.Error(w, "Email invalide.", http.StatusBadRequest)
			log.Printf("DEBUG GO: Email invalide fourni pour update: %s", clientEmail)
			return
		}
		reservation.ClientEmail = clientEmail
	}
	if clientPhone, ok := updateData["client_phone"].(string); ok {
		reservation.ClientPhone = clientPhone
	}
	if numGuests, ok := updateData["num_guests"].(float64); ok { // JSON décode les nombres en float64
		if int(numGuests) <= 0 {
			http.Error(w, "Le nombre de convives doit être supérieur à zéro.", http.StatusBadRequest)
			return
		}
		reservation.NumGuests = int(numGuests)
	}
	// Gérer la mise à jour de la date et l'heure si elles sont fournies
	if dateStr, ok := updateData["reservation_date"].(string); ok {
		// Doit parser le format ISO 8601 complet (avec heure et Z)
		parsedDate, err := time.Parse(time.RFC3339Nano, dateStr) // Utilisez time.RFC3339 pour "2025-06-17T18:00:00.000Z"
		if err != nil {
			http.Error(w, "Format de date invalide. Attendu ISO 8601 (ex: 2006-01-02T15:04:05Z).", http.StatusBadRequest)
			log.Printf("DEBUG GO: Format de date invalide pour update: %s. Erreur: %v", dateStr, err)
			return
		}
		// Effectuer la même validation de date future que lors de la création
		now := time.Now()
		// Pour la comparaison "past", utiliser la date complète incluant l'heure
		if parsedDate.Before(now) {
			http.Error(w, "La date et l'heure de réservation ne peuvent pas être dans le passé.", http.StatusBadRequest)
			log.Printf("DEBUG GO: Mise à jour refusée, date/heure dans le passé: %s", parsedDate.String())
			return
		}
		reservation.ReservationDate = parsedDate
	}
	if specialNotes, ok := updateData["special_notes"].(string); ok {
		reservation.SpecialNotes = specialNotes
	}
	if isSpecialEvent, ok := updateData["is_special_event"].(bool); ok {
		reservation.IsSpecialEvent = isSpecialEvent
	}
	if eventDescription, ok := updateData["event_description"].(string); ok {
		reservation.EventDescription = eventDescription
	}
	if wantsReminder, ok := updateData["wants_reminder"].(bool); ok {
		reservation.WantsReminder = wantsReminder
	}

	if err := DB.Save(&reservation).Error; err != nil {
		log.Printf("DEBUG GO: Erreur DB lors de la mise à jour de la réservation (ID: %s): %v", id, err)
		http.Error(w, "Échec de la mise à jour de la réservation.", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"message":     "Réservation mise à jour avec succès!",
		"reservation": reservation, // Retourne la réservation mise à jour
	})
	log.Printf("DEBUG GO: Réservation mise à jour par admin (ID: %s), nouveau statut: %s", id, reservation.Status)
}

// deleteReservationAdminHandler supprime une réservation (par admin).
// Méthode: DELETE /admin/reservations/{id}
func deleteReservationAdminHandler(w http.ResponseWriter, r *http.Request) {
	// Le middleware adminAuthMiddleware a déjà appelé enableCors
	if r.Method != http.MethodDelete {
		http.Error(w, "Méthode non autorisée", http.StatusMethodNotAllowed)
		return
	}

	// Extrait l'ID de la réservation de l'URL
	pathSegments := strings.Split(r.URL.Path, "/")
	if len(pathSegments) < 4 || pathSegments[3] == "" {
		http.Error(w, "ID de réservation manquant dans l'URL.", http.StatusBadRequest)
		return
	}
	id := pathSegments[3]

	// Supprime la réservation par son ID
	if err := DB.Where("id = ?", id).Delete(&models.Reservation{}).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			http.Error(w, "Réservation non trouvée.", http.StatusNotFound)
			log.Printf("DEBUG GO: Réservation non trouvée pour suppression par admin (ID: %s)", id)
			return
		}
		log.Printf("DEBUG GO: Erreur DB lors de la suppression de la réservation (ID: %s): %v", id, err)
		http.Error(w, "Échec de la suppression de la réservation.", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusNoContent) // 204 No Content pour une suppression réussie
	log.Printf("DEBUG GO: Réservation supprimée par admin (ID: %s).", id)
}

// --- HANDLERS DE GESTION DES CLIENTS (Côté ADMIN - Protégés par adminAuthMiddleware) ---

// getAllClientsAdminHandler récupère tous les clients de la base de données.
// Méthode: GET /admin/clients
// createClientAdminHandler gère la création d'un nouveau client (par admin).
// Méthode: POST /admin/clients
// Ces deux fonctions sont maintenant appelées par le handler unique adminClientsHandler
func adminClientsHandler(w http.ResponseWriter, r *http.Request) {
	// enableCors est déjà appelé par adminAuthMiddleware
	if r.Method == http.MethodOptions {
		return // OPTIONS requests are handled by CORS middleware
	}

	switch r.Method {
	case http.MethodGet:
		getAllClientsAdminHandler(w, r)
	case http.MethodPost:
		createClientAdminHandler(w, r)
	default:
		http.Error(w, "Méthode non autorisée pour cette URL.", http.StatusMethodNotAllowed)
	}
}

func getAllClientsAdminHandler(w http.ResponseWriter, r *http.Request) {
	// No need to check method here, it's handled by adminClientsHandler
	var clients []models.Client
	if err := DB.Find(&clients).Error; err != nil {
		log.Printf("DEBUG GO: Erreur DB lors de la récupération de tous les clients: %v", err)
		http.Error(w, "Échec de la récupération des clients.", http.StatusInternalServerError)
		return
	}

	// Pour ne pas exposer le mot de passe haché
	for i := range clients {
		clients[i].MotDePasseHashed = "" // Efface le mot de passe haché avant d'encoder
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(clients)
	log.Println("DEBUG GO: Tous les clients récupérés par admin.")
}

func createClientAdminHandler(w http.ResponseWriter, r *http.Request) {
	// No need to check method here, it's handled by adminClientsHandler
	var newClient models.Client
	if err := json.NewDecoder(r.Body).Decode(&newClient); err != nil {
		log.Printf("DEBUG GO: Erreur de décodage JSON pour création client: %v", err)
		http.Error(w, "Requête invalide: format JSON incorrect.", http.StatusBadRequest)
		return
	}

	// Validation des champs obligatoires
	if newClient.Email == "" || newClient.NomClient == "" || newClient.PrenomClient == "" || newClient.MotDePasse == "" {
		http.Error(w, "Nom, Prénom, Email et Mot de passe sont requis.", http.StatusBadRequest)
		log.Println("DEBUG GO: Champs obligatoires du client manquants.")
		return
	}
	if !regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$`).MatchString(newClient.Email) {
		http.Error(w, "Email invalide.", http.StatusBadRequest)
		log.Printf("DEBUG GO: Email invalide fourni pour création client: %s", newClient.Email)
		return
	}

	// Vérifier si l'email existe déjà
	var existingClient models.Client
	if err := DB.Where("email = ?", newClient.Email).First(&existingClient).Error; err == nil {
		http.Error(w, "Un client avec cet email existe déjà.", http.StatusConflict)
		log.Printf("DEBUG GO: Tentative de création client avec email existant: %s", newClient.Email)
		return
	} else if !errors.Is(err, gorm.ErrRecordNotFound) {
		log.Printf("DEBUG GO: Erreur DB lors de la vérification de l'email client: %v", err)
		http.Error(w, "Erreur serveur lors de la vérification de l'email.", http.StatusInternalServerError)
		return
	}

	// Hacher le mot de passe
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newClient.MotDePasse), bcrypt.DefaultCost)
	if err != nil {
		log.Printf("DEBUG GO: Erreur lors du hachage du mot de passe pour le nouveau client: %v", err)
		http.Error(w, "Erreur interne du serveur lors du hachage du mot de passe.", http.StatusInternalServerError)
		return
	}
	newClient.MotDePasseHashed = string(hashedPassword)
	newClient.MotDePasse = "" // Effacer le mot de passe en clair

	// Laisser GORM gérer CreatedAt/UpdatedAt
	if err := DB.Create(&newClient).Error; err != nil {
		log.Printf("DEBUG GO: Erreur DB lors de la création du client: %v", err)
		http.Error(w, "Échec de la création du client.", http.StatusInternalServerError)
		return
	}

	// Ne pas renvoyer le mot de passe haché
	newClient.MotDePasseHashed = ""

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(newClient)
	log.Printf("DEBUG GO: Client inscrit avec succès: %s (isAdmin: %v)", newClient.Email, newClient.IsAdmin)
}

// getClientByIDAdminHandler récupère un client spécifique par son ID.
// Méthode: GET /admin/clients/{id}
func getClientByIDAdminHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Méthode non autorisée", http.StatusMethodNotAllowed)
		return
	}

	pathSegments := strings.Split(r.URL.Path, "/")
	if len(pathSegments) < 4 || pathSegments[3] == "" {
		http.Error(w, "ID client manquant dans l'URL.", http.StatusBadRequest)
		return
	}
	// L'ID du client est un uint dans le modèle, mais ici dans l'URL, c'est une string
	// Il faudra le convertir en uint si la recherche DB l'exige, mais GORM peut souvent gérer la comparaison string avec uint si le type est compatible
	// Pour la sûreté, on va convertir si nécessaire.
	clientIDStr := pathSegments[3] // ID du client sous forme de string

	var client models.Client
	// Utilisez First(&client) directement sur la string, GORM devrait gérer la conversion si l'ID dans la DB est un UUID ou si le type GORM uint peut être comparé à une string d'ID
	if err := DB.Where("ID = ?", clientIDStr).First(&client).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			http.Error(w, "Client non trouvé.", http.StatusNotFound)
			log.Printf("DEBUG GO: Client non trouvé pour ID: %s", clientIDStr)
			return
		}
		log.Printf("DEBUG GO: Erreur DB lors de la récupération du client (ID: %s): %v", clientIDStr, err)
		http.Error(w, "Erreur serveur lors de la récupération du client.", http.StatusInternalServerError)
		return
	}

	client.MotDePasseHashed = "" // Ne pas exposer le mot de passe haché

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(client)
	log.Printf("DEBUG GO: Client récupéré pour ID: %s", clientIDStr)
}

// updateClientAdminHandler met à jour un client existant (par admin).
// Méthode: PUT /admin/clients/{id}
func updateClientAdminHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPut {
		http.Error(w, "Méthode non autorisée", http.StatusMethodNotAllowed)
		return
	}

	pathSegments := strings.Split(r.URL.Path, "/")
	if len(pathSegments) < 4 || pathSegments[3] == "" {
		http.Error(w, "ID client manquant dans l'URL.", http.StatusBadRequest)
		return
	}
	clientIDStr := pathSegments[3]

	var clientToUpdate models.Client
	if err := DB.Where("ID = ?", clientIDStr).First(&clientToUpdate).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			http.Error(w, "Client non trouvé.", http.StatusNotFound)
			log.Printf("DEBUG GO: Client non trouvé pour mise à jour par admin (ID: %s)", clientIDStr)
			return
		}
		log.Printf("DEBUG GO: Erreur DB lors de la récupération du client pour mise à jour (ID: %s): %v", clientIDStr, err)
		http.Error(w, "Erreur serveur.", http.StatusInternalServerError)
		return
	}

	var updateData map[string]interface{}
	if err := json.NewDecoder(r.Body).Decode(&updateData); err != nil {
		log.Printf("DEBUG GO: Erreur de décodage JSON pour mise à jour client: %v", err)
		http.Error(w, "Requête invalide: format JSON incorrect.", http.StatusBadRequest)
		return
	}

	// Appliquer les mises à jour
	if nomClient, ok := updateData["nomClient"].(string); ok {
		clientToUpdate.NomClient = nomClient
	}
	if prenomClient, ok := updateData["prenomClient"].(string); ok {
		clientToUpdate.PrenomClient = prenomClient
	}
	// L'email ne devrait pas être modifiable via PUT s'il est une clé unique et non modifiable facilement.
	// Si vous voulez permettre la modification de l'email, vous devrez gérer les validations d'unicité ici.
	// Pour l'instant, nous ne le mettons pas à jour.
	// if email, ok := updateData["email"].(string); ok { ... }
	if numTel, ok := updateData["numTel"].(string); ok {
		clientToUpdate.NumTel = numTel
	}
	if adresse, ok := updateData["adresse"].(string); ok {
		clientToUpdate.Adresse = adresse
	}
	if isAdmin, ok := updateData["isAdmin"].(bool); ok {
		clientToUpdate.IsAdmin = isAdmin
	}

	// Gérer la réinitialisation du mot de passe si un nouveau mot de passe est fourni (via un champ spécifique)
	if newPassword, ok := updateData["newPassword"].(string); ok && newPassword != "" {
		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
		if err != nil {
			log.Printf("DEBUG GO: Erreur lors du hachage du nouveau mot de passe pour client (ID: %s): %v", clientIDStr, err)
			http.Error(w, "Erreur interne du serveur lors du hachage du mot de passe.", http.StatusInternalServerError)
			return
		}
		clientToUpdate.MotDePasseHashed = string(hashedPassword)
	}

	if err := DB.Save(&clientToUpdate).Error; err != nil {
		log.Printf("DEBUG GO: Erreur DB lors de la mise à jour du client (ID: %s): %v", clientIDStr, err)
		http.Error(w, "Échec de la mise à jour du client.", http.StatusInternalServerError)
		return
	}

	// Ne pas renvoyer le mot de passe haché
	clientToUpdate.MotDePasseHashed = ""

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(clientToUpdate)
	log.Printf("DEBUG GO: Client mis à jour par admin (ID: %s)", clientIDStr)
}

// deleteClientAdminHandler supprime un client (par admin).
// Méthode: DELETE /admin/clients/{id}
func deleteClientAdminHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodDelete {
		http.Error(w, "Méthode non autorisée", http.StatusMethodNotAllowed)
		return
	}

	pathSegments := strings.Split(r.URL.Path, "/")
	if len(pathSegments) < 4 || pathSegments[3] == "" {
		http.Error(w, "ID client manquant dans l'URL.", http.StatusBadRequest)
		return
	}
	clientIDStr := pathSegments[3]

	if err := DB.Where("ID = ?", clientIDStr).Delete(&models.Client{}).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			http.Error(w, "Client non trouvé.", http.StatusNotFound)
			log.Printf("DEBUG GO: Client non trouvé pour suppression par admin (ID: %s)", clientIDStr)
			return
		}
		log.Printf("DEBUG GO: Erreur DB lors de la suppression du client (ID: %s): %v", clientIDStr, err)
		http.Error(w, "Échec de la suppression du client.", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusNoContent) // 204 No Content pour une suppression réussie
	log.Printf("DEBUG GO: Client supprimé par admin (ID: %s).", clientIDStr)
}

// --- FONCTION UTILITAIRE ---

// splitPath aide à extraire les segments de l'URL pour http.HandleFunc.
// Exemple: "/api/reservations/123" devient ["", "api", "reservations", "123"]
func splitPath(path string) []string {
	return strings.Split(path, "/")
}

// --- FONCTION MAIN (Point d'entrée du serveur) ---

func main() {
	// Créer une instance de DishHandler et ClientHandler
	// Assurez-vous que le répertoire 'uploads' existe au même niveau que votre exécutable Go
	uploadDir := "./uploads"
	if _, err := os.Stat(uploadDir); os.IsNotExist(err) {
		os.Mkdir(uploadDir, 0755) // Crée le répertoire avec les permissions rwx-rx-rx
	}
	dishHandler := handlers.NewDishHandler(DB, adminToken, uploadDir, serverURL)

	// --- Routes d'authentification (existantes) ---
	http.HandleFunc("/login", loginHandler)
	http.HandleFunc("/signup", signupHandler)

	// --- Routes de Réservation (Côté CLIENT) ---
	// Pour créer une réservation (POST)
	http.HandleFunc("/api/reservations", createReservationHandler)
	// Pour récupérer une réservation par ID (GET)
	// Note: HandleFunc avec une terminaison "/" permet de capturer /api/reservations/ID
	http.HandleFunc("/api/reservations/", getReservationByIDHandler)
	// Pour annuler une réservation (PUT)
	http.HandleFunc("/api/reservations/cancel/", cancelReservationHandler)

	// --- Routes de Réservation (Côté ADMIN - Protégées par adminAuthMiddleware) ---
	// Pour récupérer toutes les réservations (GET)
	http.HandleFunc("/admin/reservations", adminAuthMiddleware(getAllReservationsAdminHandler))
	// Pour mettre à jour/supprimer une réservation par ID (PUT/DELETE)
	// Note: La même route HandleFunc peut servir pour PUT et DELETE si le handler gère la méthode HTTP.
	// Dans notre cas, les handlers updateReservationAdminHandler et deleteReservationAdminHandler
	// vérifieront eux-mêmes la méthode. Le middleware applique la protection.
	// NOUVEAU: Un handler pour gérer les requêtes PUT/DELETE sur /admin/reservations/{id}
	// C'est nécessaire car http.HandleFunc ne peut pas mapper directement PUT/DELETE à des chemins dynamiques.
	// Ce handler interne va ensuite rediriger vers le bon handler en fonction de la méthode HTTP.
	adminReservationsByIdHandler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		enableCors(w, r) // Appelle CORS ici aussi, même si le middleware l'a déjà fait.
		if r.Method == http.MethodOptions {
			return
		}

		// Vérifiez la méthode HTTP et déléguez au bon handler
		switch r.Method {
		case http.MethodPut:
			updateReservationAdminHandler(w, r)
		case http.MethodDelete:
			deleteReservationAdminHandler(w, r)
		default:
			http.Error(w, "Méthode non autorisée pour cette URL.", http.StatusMethodNotAllowed)
		}
	})
	// Appliquez le middleware d'authentification à ce handler unifié.
	http.HandleFunc("/admin/reservations/", adminAuthMiddleware(adminReservationsByIdHandler))

	// --- Routes de Gestion des Plats (DishHandler) ---
	// Endpoint public pour récupérer tous les plats
	// CORRECTION ICI: Envelopper le handler dans une fonction anonyme pour gérer enableCors
	http.HandleFunc("/dishes", func(w http.ResponseWriter, r *http.Request) {
		enableCors(w, r)
		dishHandler.GetDishesHandler(w, r)
	})
	// Endpoints admin pour créer, mettre à jour, supprimer des plats
	http.HandleFunc("/admin/dishes", adminAuthMiddleware(dishHandler.CreateDishHandler)) // POST pour la création
	// Handler pour les opérations PUT et DELETE sur un plat spécifique par ID
	adminDishesByIdHandler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		enableCors(w, r)
		if r.Method == http.MethodOptions {
			return
		}
		switch r.Method {
		case http.MethodPut:
			dishHandler.UpdateDishHandler(w, r)
		case http.MethodDelete:
			dishHandler.DeleteDishHandler(w, r)
		default:
			http.Error(w, "Méthode non autorisée pour cette URL.", http.StatusMethodNotAllowed)
		}
	})
	http.HandleFunc("/admin/dishes/", adminAuthMiddleware(adminDishesByIdHandler)) // Pour ID (PUT/DELETE)

	// --- Routes de Gestion des Clients (Côté ADMIN - Protégées par adminAuthMiddleware) ---

	// Consolide GET et POST pour /admin/clients dans un seul handler
	// C'est la SEULE ligne qui doit enregistrer la route "/admin/clients" (sans slash final)
	http.HandleFunc("/admin/clients", adminAuthMiddleware(adminClientsHandler))

	// Pour récupérer un client par ID (GET), mettre à jour (PUT) ou supprimer (DELETE)
	// On crée un handler unifié pour gérer GET, PUT, DELETE sur /admin/clients/{id}
	adminClientsByIdHandler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		enableCors(w, r) // S'assure que CORS est géré
		if r.Method == http.MethodOptions {
			return
		}

		switch r.Method {
		case http.MethodGet:
			getClientByIDAdminHandler(w, r)
		case http.MethodPut:
			updateClientAdminHandler(w, r)
		case http.MethodDelete:
			deleteClientAdminHandler(w, r)
		default:
			http.Error(w, "Méthode non autorisée pour cette URL.", http.StatusMethodNotAllowed)
		}
	})
	http.HandleFunc("/admin/clients/", adminAuthMiddleware(adminClientsByIdHandler))

	// Route pour servir les fichiers statiques (images uploadées)
	// Assurez-vous que votre dossier 'uploads' existe au même niveau que votre exécutable Go
	http.Handle("/uploads/", http.StripPrefix("/uploads/", http.FileServer(http.Dir("./uploads"))))

	// Démarrer le serveur HTTP
	log.Printf("DEBUG GO: Serveur démarré sur le port %s...", serverPort)
	log.Fatal(http.ListenAndServe(":"+serverPort, nil))
}
