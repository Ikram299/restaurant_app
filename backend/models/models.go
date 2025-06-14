package models

import (
	"encoding/json"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Client struct (Modèle client pour la base de données)
type Client struct {
	ID               string         `gorm:"type:uuid;primaryKey" json:"ID"` // CORRECTION: ID client (UUID string)
	Email            string         `gorm:"uniqueIndex;not null" json:"email"`
	NomClient        string         `json:"nomClient"`
	PrenomClient     string         `json:"prenomClient"`
	MotDePasse       string         `gorm:"-" json:"motDePasse"`                 // Champ temporaire pour la réception du mot de passe en clair (non stocké en DB)
	MotDePasseHashed string         `gorm:"column:mot_de_passe_hashed" json:"-"` // Champ pour le mot de passe haché stocké en base de données
	NumTel           string         `json:"numTel"`
	Adresse          string         `json:"adresse"`
	IsAdmin          bool           `gorm:"default:false" json:"isAdmin"` // Indique si l'utilisateur est administrateur
	Paniers          []Panier       `gorm:"foreignKey:ClientID"`
	Reservations     []Reservation  `gorm:"foreignKey:ClientID"`
	Commandes        []Commande     `gorm:"foreignKey:ClientID"`
	Notifications    []Notification `gorm:"foreignKey:ClientID"`
}

// UnmarshalJSON pour Client (Gère la désérialisation de 'isAdmin' qui peut être bool ou nombre)
func (c *Client) UnmarshalJSON(data []byte) error {
	type Alias Client
	aux := &struct {
		Alias
		IsAdmin interface{} `json:"isAdmin"` // Utilise interface{} pour décoder des booléens ou des nombres
	}{
		Alias: (Alias)(*c),
	}

	if err := json.Unmarshal(data, &aux); err != nil {
		return err
	}

	*c = (Client)(aux.Alias)

	// Convertit la valeur de 'isAdmin' en booléen si elle est un nombre ou un booléen
	if aux.IsAdmin != nil {
		switch v := aux.IsAdmin.(type) {
		case bool:
			c.IsAdmin = v
		case float64: // JSON décode les nombres en float64
			c.IsAdmin = v != 0
		case int: // Pour le cas où certains clients envoient un int direct
			c.IsAdmin = v != 0
		default:
			// Laisse la valeur par défaut (false) ou la valeur existante si le type n'est pas reconnu
		}
	}
	return nil
}

// BeforeCreate hook pour Client (Génère un UUID avant la création)
func (c *Client) BeforeCreate(tx *gorm.DB) (err error) {
	if c.ID == "" { // Génère un UUID seulement si l'ID n'est pas déjà défini
		c.ID = uuid.New().String()
	}
	return
}

type Plat struct {
	ID          string    `gorm:"primaryKey;type:uuid" json:"ID"` // ID plat (UUID string)
	Name        string    `json:"name"`
	Category    string    `json:"category"`
	Price       float64   `json:"price"`
	Description string    `json:"description"`
	ImagePath   string    `json:"imageUrl"` // IMPORTANT: Le tag JSON doit être "imageUrl"
	CreatedAt   time.Time `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt   time.Time `gorm:"autoUpdateTime" json:"updated_at"`
}

// BeforeCreate hook pour Plat (Génère un UUID avant la création)
func (p *Plat) BeforeCreate(tx *gorm.DB) (err error) {
	if p.ID == "" {
		p.ID = uuid.New().String()
	}
	return
}

// Reservation struct (Modèle de réservation pour la base de données)
type Reservation struct {
	ID               string    `gorm:"type:uuid;primaryKey" json:"ID"` // ID réservation (UUID string)
	ClientID         string    `gorm:"type:uuid" json:"client_id"`     // Clé étrangère vers le client (si lié à un client connecté)
	ClientName       string    `gorm:"not null" json:"client_name"`
	ClientEmail      string    `gorm:"not null" json:"client_email"`
	ClientPhone      string    `gorm:"not null" json:"client_phone"`
	NumGuests        int       `gorm:"not null" json:"num_guests"`
	ReservationDate  time.Time `gorm:"not null" json:"reservation_date"`
	Status           string    `gorm:"default:'En attente';type:varchar(20)" json:"status"` // Statut de la réservation
	SpecialNotes     string    `json:"special_notes"`
	IsSpecialEvent   bool      `gorm:"default:false" json:"is_special_event"`
	EventDescription string    `json:"event_description"`
	WantsReminder    bool      `gorm:"default:true" json:"wants_reminder"`
	CreatedAt        time.Time `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt        time.Time `gorm:"autoUpdateTime" json:"updated_at"`
}

// BeforeCreate hook pour Reservation (Génère un UUID avant la création)
func (r *Reservation) BeforeCreate(tx *gorm.DB) (err error) {
	if r.ID == "" {
		r.ID = uuid.New().String()
	}
	return
}

// Panier struct (Modèle de panier pour la base de données)
type Panier struct {
	ID        string    `gorm:"type:uuid;primaryKey" json:"ID"`                  // ID panier (UUID string)
	ClientID  string    `gorm:"type:uuid;not null;uniqueIndex" json:"client_id"` // ID client (clé étrangère)
	CreatedAt time.Time `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt time.Time `gorm:"autoUpdateTime" json:"updated_at"`
}

// BeforeCreate hook pour Panier (Génère un UUID avant la création)
func (p *Panier) BeforeCreate(tx *gorm.DB) (err error) {
	if p.ID == "" {
		p.ID = uuid.New().String()
	}
	return
}

// Commande struct (Modèle de commande pour la base de données)
type Commande struct {
	ID          string    `gorm:"type:uuid;primaryKey" json:"ID"`      // ID commande (UUID string)
	ClientID    string    `gorm:"type:uuid;not null" json:"client_id"` // ID client (clé étrangère)
	OrderDate   time.Time `json:"order_date"`
	TotalAmount float64   `json:"total_amount"`
	Status      string    `json:"status"` // Statut de la commande
	CreatedAt   time.Time `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt   time.Time `gorm:"autoUpdateTime" json:"updated_at"`
}

// BeforeCreate hook pour Commande (Génère un UUID avant la création)
func (c *Commande) BeforeCreate(tx *gorm.DB) (err error) {
	if c.ID == "" {
		c.ID = uuid.New().String()
	}
	return
}

// Paiement struct (Modèle de paiement pour la base de données)
type Paiement struct {
	ID          string    `gorm:"type:uuid;primaryKey" json:"ID"`        // ID paiement (UUID string)
	CommandeID  string    `gorm:"type:uuid;not null" json:"commande_id"` // ID commande (clé étrangère)
	Amount      float64   `json:"amount"`
	PaymentDate time.Time `json:"payment_date"`
	Method      string    `json:"method"` // Méthode de paiement
	Status      string    `json:"status"` // Statut du paiement
	CreatedAt   time.Time `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt   time.Time `gorm:"autoUpdateTime" json:"updated_at"`
}

// BeforeCreate hook pour Paiement (Génère un UUID avant la création)
func (p *Paiement) BeforeCreate(tx *gorm.DB) (err error) {
	if p.ID == "" {
		p.ID = uuid.New().String()
	}
	return
}

// Notification struct (Modèle de notification pour la base de données)
type Notification struct {
	ID        string    `gorm:"type:uuid;primaryKey" json:"ID"`      // ID notification (UUID string)
	ClientID  string    `gorm:"type:uuid;not null" json:"client_id"` // ID client (clé étrangère)
	Message   string    `json:"message"`
	IsRead    bool      `gorm:"default:false" json:"is_read"`
	CreatedAt time.Time `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt time.Time `gorm:"autoUpdateTime" json:"updated_at"`
}

// BeforeCreate hook pour Notification (Génère un UUID avant la création)
func (n *Notification) BeforeCreate(tx *gorm.DB) (err error) {
	if n.ID == "" {
		n.ID = uuid.New().String()
	}
	return
}

// CommandePlat (Table de jointure pour relation Many-to-Many entre Commande et Plat)
type CommandePlat struct {
	CommandeID string `gorm:"type:uuid;primaryKey" json:"commande_id"` // ID commande (clé primaire/étrangère)
	PlatID     string `gorm:"type:uuid;primaryKey" json:"plat_id"`     // ID plat (clé primaire/étrangère)
	Quantity   int    `json:"quantity"`
}

// PanierPlat (Table de jointure pour relation Many-to-Many entre Panier et Plat)
type PanierPlat struct {
	PanierID string `gorm:"type:uuid;primaryKey" json:"panier_id"` // ID panier (clé primaire/étrangère)
	PlatID   string `gorm:"type:uuid;primaryKey" json:"plat_id"`   // ID plat (clé primaire/étrangère)
	Quantity int    `json:"quantity"`
}
