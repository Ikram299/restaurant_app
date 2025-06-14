package handlers

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"restaurant-app/backend/models" // Assurez-vous que ce chemin est correct

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// DishHandler regroupe les dépendances et les méthodes pour les opérations CRUD sur les plats.
type DishHandler struct {
	DB         *gorm.DB
	AdminToken string
	UploadDir  string
	ServerURL  string
}

// NewDishHandler crée une nouvelle instance de DishHandler.
func NewDishHandler(db *gorm.DB, adminToken, uploadDir, serverURL string) *DishHandler {
	return &DishHandler{
		DB:         db,
		AdminToken: adminToken,
		UploadDir:  uploadDir,
		ServerURL:  serverURL,
	}
}

// parsePrice est une fonction utilitaire pour analyser le prix depuis une chaîne.
// Elle gère les virgules comme séparateur décimal si nécessaire.
func parsePrice(priceStr string) (float64, error) {
	priceStr = strings.Replace(priceStr, ",", ".", -1)
	var price float64
	_, err := fmt.Sscanf(priceStr, "%f", &price)
	return price, err
}

// respondWithJSON est une fonction utilitaire pour envoyer des réponses JSON.
func respondWithJSON(w http.ResponseWriter, status int, payload interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(payload); err != nil {
		log.Printf("Erreur lors de l'encodage de la réponse JSON: %v", err)
	}
}

// respondWithError est une fonction utilitaire pour envoyer des réponses d'erreur JSON.
func respondWithError(w http.ResponseWriter, status int, message string) {
	respondWithJSON(w, status, map[string]string{"message": message})
}

// CreateDishHandler crée un nouveau plat (accès admin), y compris l'upload d'images.
// Méthode: POST /admin/dishes
func (dh *DishHandler) CreateDishHandler(w http.ResponseWriter, r *http.Request) {
	// CORS et OPTIONS sont gérés par le middleware externe.
	if r.Method != http.MethodPost {
		respondWithError(w, http.StatusMethodNotAllowed, "Méthode non autorisée.")
		return
	}

	err := r.ParseMultipartForm(10 << 20) // Taille max du fichier: 10 Mo
	if err != nil {
		log.Printf("Erreur lors du parsing du formulaire multipart: %v", err)
		respondWithError(w, http.StatusBadRequest, fmt.Sprintf("Erreur lors du parsing du formulaire: %v", err))
		return
	}

	// Récupère les valeurs des champs du formulaire
	name := r.FormValue("name")
	category := r.FormValue("category")
	priceStr := r.FormValue("price")
	description := r.FormValue("description")

	log.Printf("Données de plat reçues - Nom: '%s', Catégorie: '%s', Prix: '%s', Description: '%s'",
		name, category, priceStr, description)

	if name == "" || category == "" || priceStr == "" || description == "" {
		respondWithError(w, http.StatusBadRequest, "Tous les champs (nom, catégorie, prix, description) sont obligatoires.")
		return
	}

	price, err := parsePrice(priceStr)
	if err != nil {
		log.Printf("Erreur de conversion du prix '%s': %v", priceStr, err)
		respondWithError(w, http.StatusBadRequest, "Format de prix invalide.")
		return
	}

	file, handler, err := r.FormFile("image") // 'image' est le nom du champ de fichier attendu par Flutter
	var imagePath string
	if err == nil {
		defer file.Close()
		fileName := uuid.New().String() + filepath.Ext(handler.Filename)
		filePath := filepath.Join(dh.UploadDir, fileName)

		dst, err := os.Create(filePath)
		if err != nil {
			log.Printf("Échec de la création du fichier image '%s': %v", filePath, err)
			respondWithError(w, http.StatusInternalServerError, "Échec de la création du fichier image sur le serveur.")
			return
		}
		defer dst.Close()

		if _, err := io.Copy(dst, file); err != nil {
			log.Printf("Échec de la copie du fichier image vers '%s': %v", filePath, err)
			respondWithError(w, http.StatusInternalServerError, "Échec de la copie du fichier image.")
			return
		}
		imagePath = fmt.Sprintf("%s/uploads/%s", dh.ServerURL, fileName)
		log.Printf("Image uploadée et enregistrée: %s", imagePath)
	} else if err != http.ErrMissingFile {
		log.Printf("Erreur lors de l'upload de l'image (non-missing file): %v", err)
		respondWithError(w, http.StatusBadRequest, fmt.Sprintf("Erreur lors de l'upload de l'image: %v", err))
		return
	}

	// Crée une instance du modèle Plat
	newPlat := models.Plat{
		Name:        name,
		Category:    category,
		Price:       price,
		Description: description,
		ImagePath:   imagePath,
	}

	if err := dh.DB.Create(&newPlat).Error; err != nil {
		log.Printf("Erreur DB lors de l'ajout du plat: %v", err)
		respondWithError(w, http.StatusInternalServerError, fmt.Sprintf("Erreur lors de l'ajout du plat à la base de données: %v", err))
		return
	}

	respondWithJSON(w, http.StatusCreated, newPlat)
	log.Printf("Plat ajouté avec succès: '%s' (ID: %s)", newPlat.Name, newPlat.ID)
}

// GetDishesHandler récupère tous les plats (accès public).
// Méthode: GET /dishes
func (dh *DishHandler) GetDishesHandler(w http.ResponseWriter, r *http.Request) {
	// CORS et OPTIONS sont gérés par le middleware externe.
	if r.Method != http.MethodGet {
		respondWithError(w, http.StatusMethodNotAllowed, "Méthode non autorisée.")
		return
	}

	var plats []models.Plat
	if err := dh.DB.Find(&plats).Error; err != nil {
		log.Printf("Erreur DB lors de la récupération des plats: %v", err)
		respondWithError(w, http.StatusInternalServerError, fmt.Sprintf("Échec de la récupération des plats: %v", err))
		return
	}
	respondWithJSON(w, http.StatusOK, plats)
}

// UpdateDishHandler met à jour un plat existant (accès admin).
// Méthode: PUT /admin/dishes/{id}
func (dh *DishHandler) UpdateDishHandler(w http.ResponseWriter, r *http.Request) {
	// CORS et OPTIONS sont gérés par le middleware externe.
	if r.Method != http.MethodPut {
		respondWithError(w, http.StatusMethodNotAllowed, "Méthode non autorisée.")
		return
	}

	parts := strings.Split(r.URL.Path, "/")
	if len(parts) < 4 || parts[3] == "" { // Attendu: /admin/dishes/{id}
		respondWithError(w, http.StatusBadRequest, "ID plat manquant dans l'URL.")
		return
	}
	platID := parts[3]

	err := r.ParseMultipartForm(10 << 20) // Taille max du fichier: 10 Mo
	if err != nil {
		log.Printf("Erreur lors du parsing du formulaire multipart: %v", err)
		respondWithError(w, http.StatusBadRequest, fmt.Sprintf("Erreur lors du parsing du formulaire: %v", err))
		return
	}

	var existingPlat models.Plat
	if err := dh.DB.First(&existingPlat, "ID = ?", platID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			respondWithError(w, http.StatusNotFound, "Plat non trouvé.")
			return
		}
		log.Printf("Erreur DB lors de la récupération du plat (ID: %s): %v", platID, err)
		respondWithError(w, http.StatusInternalServerError, "Erreur de base de données.")
		return
	}

	// Met à jour les champs
	if name := r.FormValue("name"); name != "" {
		existingPlat.Name = name
	}
	if category := r.FormValue("category"); category != "" {
		existingPlat.Category = category
	}
	if priceStr := r.FormValue("price"); priceStr != "" {
		if price, err := parsePrice(priceStr); err == nil {
			existingPlat.Price = price
		} else {
			respondWithError(w, http.StatusBadRequest, "Format de prix invalide.")
			return
		}
	}
	if description := r.FormValue("description"); description != "" {
		existingPlat.Description = description
	}
	// Permet de mettre à jour l'image_url si une chaîne vide est envoyée (pour effacer l'image),
	// ou si une nouvelle URL d'image est fournie.
	// Si le champ 'image_url' n'est pas fourni dans le formulaire, il ne sera pas mis à jour.
	if imageUrl := r.FormValue("image_url"); r.Form.Has("image_url") { // Vérifie si le champ est présent
		existingPlat.ImagePath = imageUrl
	}

	file, handler, err := r.FormFile("image")
	if err == nil { // Une nouvelle image a été uploadée
		defer file.Close()
		// Supprime l'ancienne image si elle existe et est gérée par le serveur
		if existingPlat.ImagePath != "" && strings.HasPrefix(existingPlat.ImagePath, dh.ServerURL+"/uploads/") {
			oldFileName := strings.TrimPrefix(existingPlat.ImagePath, dh.ServerURL+"/uploads/")
			oldFilePath := filepath.Join(dh.UploadDir, oldFileName)
			if _, statErr := os.Stat(oldFilePath); statErr == nil {
				if removeErr := os.Remove(oldFilePath); removeErr != nil {
					log.Printf("Erreur lors de la suppression de l'ancienne image %s: %v", oldFilePath, removeErr)
				} else {
					log.Printf("Ancienne image supprimée: %s", oldFilePath)
				}
			}
		}

		// Enregistre la nouvelle image
		fileName := uuid.New().String() + filepath.Ext(handler.Filename)
		filePath := filepath.Join(dh.UploadDir, fileName)
		dst, err := os.Create(filePath)
		if err != nil {
			log.Printf("Échec de la création du nouveau fichier image '%s': %v", filePath, err)
			respondWithError(w, http.StatusInternalServerError, "Échec de la création du nouveau fichier image sur le serveur.")
			return
		}
		defer dst.Close()
		if _, err := io.Copy(dst, file); err != nil {
			log.Printf("Échec de la copie du nouveau fichier image vers '%s': %v", filePath, err)
			respondWithError(w, http.StatusInternalServerError, "Échec de la copie du nouveau fichier image.")
			return
		}
		existingPlat.ImagePath = fmt.Sprintf("%s/uploads/%s", dh.ServerURL, fileName)
	} else if err != http.ErrMissingFile { // Si ce n'est pas une erreur "fichier manquant", c'est une autre erreur d'upload
		log.Printf("Erreur lors de l'upload de la nouvelle image (non-missing file): %v", err)
		respondWithError(w, http.StatusBadRequest, fmt.Sprintf("Erreur lors de l'upload de la nouvelle image: %v", err))
		return
	}

	if err := dh.DB.Save(&existingPlat).Error; err != nil {
		log.Printf("Erreur DB lors de la mise à jour du plat (ID: %s): %v", platID, err)
		respondWithError(w, http.StatusInternalServerError, fmt.Sprintf("Échec de la mise à jour du plat: %v", err))
		return
	}

	respondWithJSON(w, http.StatusOK, existingPlat)
}

// DeleteDishHandler supprime un plat par son ID (accès admin).
// Méthode: DELETE /admin/dishes/{id}
func (dh *DishHandler) DeleteDishHandler(w http.ResponseWriter, r *http.Request) {
	// CORS et OPTIONS sont gérés par le middleware externe.
	if r.Method != http.MethodDelete {
		respondWithError(w, http.StatusMethodNotAllowed, "Méthode non autorisée.")
		return
	}

	parts := strings.Split(r.URL.Path, "/")
	if len(parts) < 4 || parts[3] == "" { // Attendu: /admin/dishes/{id}
		respondWithError(w, http.StatusBadRequest, "ID plat manquant dans l'URL.")
		return
	}
	platID := parts[3]

	var plat models.Plat
	if err := dh.DB.First(&plat, "ID = ?", platID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			respondWithError(w, http.StatusNotFound, "Plat non trouvé.")
			return
		}
		log.Printf("Erreur DB lors de la récupération du plat pour suppression (ID: %s): %v", platID, err)
		respondWithError(w, http.StatusInternalServerError, "Erreur de base de données.")
		return
	}

	// Supprime le fichier image associé s'il existe et est géré par le serveur
	if plat.ImagePath != "" && strings.HasPrefix(plat.ImagePath, dh.ServerURL+"/uploads/") {
		oldFileName := strings.TrimPrefix(plat.ImagePath, dh.ServerURL+"/uploads/")
		oldFilePath := filepath.Join(dh.UploadDir, oldFileName)
		if _, err := os.Stat(oldFilePath); err == nil {
			if removeErr := os.Remove(oldFilePath); removeErr != nil {
				log.Printf("Erreur lors de la suppression de l'image %s: %v", oldFilePath, removeErr)
			} else {
				log.Printf("Image supprimée: %s", oldFilePath)
			}
		}
	}

	if err := dh.DB.Delete(&models.Plat{}, "ID = ?", platID).Error; err != nil {
		log.Printf("Erreur DB lors de la suppression du plat (ID: %s): %v", platID, err)
		respondWithError(w, http.StatusInternalServerError, fmt.Sprintf("Échec de la suppression du plat: %v", err))
		return
	}
	w.WriteHeader(http.StatusNoContent)
	log.Printf("Plat supprimé avec succès: '%s' (ID: %s)", plat.Name, plat.ID)
}
