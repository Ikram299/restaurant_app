package models

import "encoding/json" // Keep this import as it's used by UnmarshalJSON

type Client struct {
	ID               uint   `gorm:"primaryKey"` // This tag is understood by GORM even without direct gorm.Model import in this file
	Email            string `gorm:"unique;not null" json:"email"`
	NomClient        string `json:"nomClient"`
	PrenomClient     string `json:"prenomClient"`
	MotDePasse       string `gorm:"-" json:"motDePasse"`
	MotDePasseHashed string `gorm:"not null" json:"-"`
	NumTel           string `json:"numTel"`
	Adresse          string `json:"adresse"`
	IsAdmin          bool   `gorm:"default:false" json:"isAdmin"`
	// Relations
	Paniers       []Panier       `gorm:"foreignKey:ClientID"`
	Reservations  []Reservation  `gorm:"foreignKey:ClientID"`
	Commandes     []Commande     `gorm:"foreignKey:ClientID"`
	Notifications []Notification `gorm:"foreignKey:ClientID"`
}

// Your UnmarshalJSON function remains the same
func (c *Client) UnmarshalJSON(data []byte) error {
	type Alias Client
	aux := &struct {
		Alias
		IsAdmin interface{} `json:"isAdmin"`
	}{
		Alias: (Alias)(*c),
	}

	if err := json.Unmarshal(data, &aux); err != nil {
		return err
	}

	*c = (Client)(aux.Alias)

	if aux.IsAdmin != nil {
		switch v := aux.IsAdmin.(type) {
		case bool:
			c.IsAdmin = v
		case float64:
			c.IsAdmin = v != 0
		case int:
			c.IsAdmin = v != 0
		default:
			// Laisse la valeur par défaut (false) si le type n'est pas reconnu ou non géré
		}
	}
	return nil
}

// --- Autres structs pour les autres modèles ---
// (Ces structs sont correctes telles que vous les avez fournies)

type Plat struct {
	ID   uint `gorm:"primaryKey"`
	Nom  string
	Prix float64
}

type Panier struct {
	ID       uint `gorm:"primaryKey"`
	ClientID uint // Clé étrangère vers le client
	// Ajoutez d'autres champs au besoin
}

type Reservation struct {
	ID       uint `gorm:"primaryKey"`
	ClientID uint // Clé étrangère vers le client
	// Ajoutez d'autres champs au besoin
}

type Commande struct {
	ID       uint `gorm:"primaryKey"`
	ClientID uint // Clé étrangère vers le client
	// Ajoutez d'autres champs au besoin
}

type Paiement struct {
	ID         uint `gorm:"primaryKey"`
	CommandeID uint // Clé étrangère vers la commande
	// Ajoutez d'autres champs au besoin
}

type Notification struct {
	ID       uint `gorm:"primaryKey"`
	ClientID uint // Clé étrangère vers le client
	// Ajoutez d'autres champs au besoin
}

type CommandePlat struct {
	CommandeID uint `gorm:"primaryKey"`
	PlatID     uint `gorm:"primaryKey"`
	Quantite   int
}

type PanierPlat struct {
	PanierID uint `gorm:"primaryKey"`
	PlatID   uint `gorm:"primaryKey"`
	Quantite int
}
