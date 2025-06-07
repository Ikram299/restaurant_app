package main

import (
	"encoding/json"
	"errors" // Importez le package errors pour gorm.ErrRecordNotFound
	"fmt"
	"log"
	"net/http"
	"restaurant-app/backend/models" // Assurez-vous que ce chemin correspond \u00e0 votre projet

	"golang.org/x/crypto/bcrypt"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var DB *gorm.DB // Renomm\u00e9 db en DB (variable globale conventionnelle)

func init() {
	var err error
	// Connexion \u00e0 la base de donn\u00e9es SQLite
	DB, err = gorm.Open(sqlite.Open("restaurant-app.db"), &gorm.Config{}) // Utilise DB
	if err != nil {
		log.Fatal("DEBUG GO: \u00c9chec de la connexion \u00e0 la base de donn\u00e9es :", err) // DEBUG PRINT
	}

	// Migration automatique : cr\u00e9e les tables si elles n'existent pas
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
		log.Fatal("DEBUG GO: Erreur lors de la migration de la base de donn\u00e9es", err) // DEBUG PRINT
	}
	fmt.Println("DEBUG GO: Base de donn\u00e9es connect\u00e9e et migrat\u00e9e avec succ\u00e8s.") // DEBUG PRINT
}

// Middleware pour autoriser les requ\u00eates CORS
func enableCors(w http.ResponseWriter) {
	w.Header().Set("Access-Control-Allow-Origin", "*") // Autorise toutes les origines
	w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization") // Ajout Authorization pour les futurs tokens
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(w)

	if r.Method == http.MethodOptions {
		return // G\u00e8re la requ\u00eate OPTIONS (pr\u00e9-vol CORS)
	}

	var loginReq models.Client // Pour d\u00e9coder la requ\u00eate entrante (email et motDePasse en clair)
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(&loginReq)
	if err != nil {
		log.Printf("DEBUG GO: Erreur de d\u00e9codage JSON de la requ\u00eate de connexion: %v", err) // DEBUG PRINT
		http.Error(w, "Requ\u00eate invalide", http.StatusBadRequest)
		return
	}

	log.Printf("DEBUG GO: Tentative de connexion pour l'email: %s", loginReq.Email) // DEBUG PRINT

	// R\u00e9cup\u00e9rer le client par email seulement
	var storedClient models.Client
	// Note: storedClient.MotDePasseHashed contiendra le hachage
	if err := DB.Where("email = ?", loginReq.Email).First(&storedClient).Error; err != nil { // Utilise DB
		if errors.Is(err, gorm.ErrRecordNotFound) { // Utilise errors.Is pour v\u00e9rifier le type d'erreur
			log.Printf("DEBUG GO: Client non trouv\u00e9 pour l'email: %s", loginReq.Email) // DEBUG PRINT
			http.Error(w, "Identifiants incorrects", http.StatusUnauthorized)
			return
		}
		log.Printf("DEBUG GO: Erreur lors de la r\u00e9cup\u00e9ration du client de la DB: %v", err) // DEBUG PRINT
		http.Error(w, "Erreur interne du serveur", http.StatusInternalServerError)
		return
	}

	// Comparer le mot de passe fourni (en clair) avec le mot de passe hach\u00e9 de la base de donn\u00e9es
	err = bcrypt.CompareHashAndPassword([]byte(storedClient.MotDePasseHashed), []byte(loginReq.MotDePasse)) // Utilise MotDePasseHashed
	if err != nil {
		log.Printf("DEBUG GO: Mot de passe incorrect pour l'email %s: %v", loginReq.Email, err) // DEBUG PRINT
		http.Error(w, "Identifiants incorrects", http.StatusUnauthorized)
		return
	}

	// Connexion r\u00e9ussie - Pr\u00e9parez la r\u00e9ponse pour Flutter
	// Cr\u00e9ez un objet map \u00e0 renvoyer, en excluant les champs sensibles comme le mot de passe hach\u00e9
	clientResponse := map[string]interface{}{
		"email":        storedClient.Email,
		"nomClient":    storedClient.NomClient,
		"prenomClient": storedClient.PrenomClient,
		"numTel":       storedClient.NumTel,
		"adresse":      storedClient.Adresse,
		"isAdmin":      storedClient.IsAdmin, // Ceci envoie bien le statut isAdmin \u00e0 Flutter
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(clientResponse)                                                                           // Renvoie les donn\u00e9es du client en JSON
	log.Printf("DEBUG GO: Connexion r\u00e9ussie pour l'email: %s (isAdmin: %v)", loginReq.Email, storedClient.IsAdmin) // DEBUG PRINT
}

func signupHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(w)

	if r.Method == http.MethodOptions {
		return // G\u00e8re la requ\u00eate OPTIONS (pr\u00e9-vol CORS)
	}

	fmt.Println("DEBUG GO: Requ\u00eate re\u00e7ue sur le handler /signup") // DEBUG PRINT (ajout\u00e9 ici)

	var clientData models.Client
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(&clientData)
	if err != nil {
		log.Printf("DEBUG GO: Erreur de d\u00e9codage JSON \u00e0 l'inscription: %v", err) // DEBUG PRINT
		http.Error(w, "Requ\u00eate invalide", http.StatusBadRequest)
		return
	}

	log.Printf("DEBUG GO: Donn\u00e9es client re\u00e7ues pour inscription: Email=%s, Nom=%s, IsAdmin=%v", clientData.Email, clientData.NomClient, clientData.IsAdmin) // DEBUG PRINT

	// V\u00e9rifie que l'email n'existe pas d\u00e9j\u00e0
	var existingClient models.Client
	if err := DB.Where("email = ?", clientData.Email).First(&existingClient).Error; err == nil { // Utilise DB
		log.Printf("DEBUG GO: Tentative d'inscription avec un email d\u00e9j\u00e0 utilis\u00e9: %s", clientData.Email) // DEBUG PRINT
		http.Error(w, "Email d\u00e9j\u00e0 utilis\u00e9", http.StatusConflict)
		return
	} else if !errors.Is(err, gorm.ErrRecordNotFound) { // G\u00e8re les autres erreurs DB
		log.Printf("DEBUG GO: Erreur DB lors de la v\u00e9rification de l'email: %v", err) // DEBUG PRINT
		http.Error(w, "Erreur serveur lors de la v\u00e9rification de l'email", http.StatusInternalServerError)
		return
	}

	// Hacher le mot de passe avant de l'enregistrer
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(clientData.MotDePasse), bcrypt.DefaultCost)
	if err != nil {
		log.Printf("DEBUG GO: Erreur lors du hachage du mot de passe: %v", err) // DEBUG PRINT
		http.Error(w, "Erreur interne du serveur lors du hachage", http.StatusInternalServerError)
		return
	}

	// Cr\u00e9e une nouvelle instance de Client pour la base de donn\u00e9es avec le hachage
	newClient := models.Client{
		Email:            clientData.Email,
		NomClient:        clientData.NomClient,
		PrenomClient:     clientData.PrenomClient,
		MotDePasseHashed: string(hashedPassword), // Stocke le HACHAGE ici
		NumTel:           clientData.NumTel,
		Adresse:          clientData.Adresse,
		IsAdmin:          clientData.IsAdmin, // Utilise la valeur isAdmin re\u00e7ue
	}

	// Ajoute le client dans la base
	if err := DB.Create(&newClient).Error; err != nil { // Utilise DB
		log.Printf("DEBUG GO: Erreur lors de l'inscription du client dans la DB: %v", err) // DEBUG PRINT
		http.Error(w, "Échec de l'inscription", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	fmt.Fprintln(w, "Inscription r\u00e9ussie")
	log.Printf("DEBUG GO: Client inscrit avec succ\u00e8s: %s (isAdmin: %v)", newClient.Email, newClient.IsAdmin) // DEBUG PRINT
}

func main() {
	// Routes pour login et signup
	http.HandleFunc("/login", loginHandler)
	http.HandleFunc("/signup", signupHandler) // Doit \u00eatre d\u00e9finie

	// D\u00e9marre le serveur HTTP sur le port 8080
	log.Println("DEBUG GO: Serveur d\u00e9marr\u00e9 sur le port 8080...") // DEBUG PRINT
	log.Fatal(http.ListenAndServe(":8080", nil))
}
