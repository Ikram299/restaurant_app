package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"restaurant-app/backend/models" // Assure-toi que ce chemin correspond à ton projet

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var db *gorm.DB

func init() {
	var err error
	// Connexion à la base de données SQLite
	db, err = gorm.Open(sqlite.Open("restaurant-app.db"), &gorm.Config{})
	if err != nil {
		log.Fatal("Échec de la connexion à la base de données :", err)
	}

	// Migration automatique : crée la table Client si elle n'existe pas
	err = db.AutoMigrate(&models.Client{}, &models.Plat{}, &models.Panier{}, &models.Reservation{}, &models.Commande{}, &models.Paiement{}, &models.Notification{}, &models.CommandePlat{}, &models.PanierPlat{})
	if err != nil {
		log.Fatal("Erreur lors de la migration de la base de données", err)
	}
}

// Middleware pour autoriser les requêtes CORS
func enableCors(w http.ResponseWriter) {
	w.Header().Set("Access-Control-Allow-Origin", "*") // Autorise toutes les origines
	w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(w) // Active CORS pour cette route

	if r.Method == http.MethodOptions {
		return // Répond aux pré-vols (OPTIONS)
	}

	var client models.Client
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(&client)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// Recherche du client en base avec email + mot de passe
	var storedClient models.Client
	if err := db.Where("email = ? AND mot_de_passe = ?", client.Email, client.MotDePasse).First(&storedClient).Error; err != nil {
		http.Error(w, "Identifiants incorrects", http.StatusUnauthorized)
		return
	}

	// Connexion réussie
	w.WriteHeader(http.StatusOK)
	fmt.Fprintln(w, "Connexion réussie")
}

func signupHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(w) // Active CORS pour cette route

	if r.Method == http.MethodOptions {
		return // Répond aux requêtes pré-vol (OPTIONS)
	}

	var client models.Client
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(&client)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// Vérifie que l'email n'existe pas déjà
	var existingClient models.Client
	if err := db.Where("email = ?", client.Email).First(&existingClient).Error; err == nil {
		http.Error(w, "Email déjà utilisé", http.StatusConflict)
		return
	}

	// Ajoute le client dans la base
	if err := db.Create(&client).Error; err != nil {
		http.Error(w, "Échec de l'inscription", http.StatusInternalServerError)
		return
	}

	// Succès
	w.WriteHeader(http.StatusCreated)
	fmt.Fprintln(w, "Inscription réussie")
}

func main() {
	// Routes pour login et signup
	http.HandleFunc("/login", loginHandler)
	http.HandleFunc("/signup", signupHandler)

	// Démarre le serveur HTTP sur le port 8080
	log.Println("Serveur démarré sur le port 8080...")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
