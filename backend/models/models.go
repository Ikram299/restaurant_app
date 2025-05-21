package models

import "gorm.io/gorm"

type Client struct {
	gorm.Model
	Email        string `gorm:"primaryKey"`
	NomClient    string
	PrenomClient string
	MotDePasse   string
	NumTel       string
	Adresse      string
}

type Plat struct {
	IdPlat      uint `gorm:"primaryKey"`
	NomPlat     string
	Description string
	Prix        float64
	Categorie   string
}

type Panier struct {
	IdPanier     uint `gorm:"primaryKey"`
	Email        string
	DateCreation string // ou time.Time si tu veux gérer les dates proprement
}

type Reservation struct {
	IdReservation   uint `gorm:"primaryKey"`
	DateReservation string
	Heure           string
	NombrePersonnes int
}

type Commande struct {
	IdCommande   uint `gorm:"primaryKey"`
	DateCommande string
	Montant      float64
}

type Paiement struct {
	IdPaiement      uint `gorm:"primaryKey"`
	MontantPaiement float64
	DatePaiement    string
}

type Notification struct {
	IdNotification uint `gorm:"primaryKey"`
	Message        string
	DateEnvoi      string
	Canal          string
}

type CommandePlat struct {
	ID                uint `gorm:"primaryKey"`
	CommandeID        uint
	PlatID            uint
	QuantiteCommandee int
}

type PanierPlat struct {
	ID                   uint `gorm:"primaryKey"`
	PanierID             uint
	PlatID               uint
	QuantiteSelectionnee int
}
