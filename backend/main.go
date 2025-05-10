package main

import (
	"log"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	// Initialisation du routeur Gin avec les middlewares par défaut
	r := gin.Default()

	// Appliquer le middleware CORS pour gérer les requêtes inter-domaines
	r.Use(cors.Default())

	// Définir la route /api/bonjour
	r.GET("/api/bonjour", func(c *gin.Context) {
		// Répondre avec un message JSON
		c.JSON(200, gin.H{
			"message": "Bonjour depuis le backend Go !",
		})
	})

	// Lancer le serveur sur le port 8080, et gérer les erreurs
	if err := r.Run(":8080"); err != nil {
		log.Fatalf("Erreur lors du démarrage du serveur : %v", err)
	}
}
