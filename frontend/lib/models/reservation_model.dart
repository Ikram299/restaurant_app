import 'package:flutter/material.dart'; // Nécessaire pour TimeOfDay si utilisé directement
import 'package:intl/intl.dart'; // Importez intl pour le formatage des dates et heures
import 'package:uuid/uuid.dart'; // Pour générer des UUIDs côté Flutter si besoin, mais le backend le fait déjà

class Reservation {
  String? id; // L'ID de la réservation (sera généré par le backend Go)
  String nomClient;
  String emailClient;
  String numTelClient;
  int nombreConvives;
  DateTime dateReservation; // Stockée comme objet DateTime
  DateTime heureReservation; // Stockée comme objet DateTime (mais seul l'heure est importante)
  bool evenementSpecial;
  String? descriptionEvenement;
  String? notesSpeciales;
  bool rappelDemande;
  String status; // Ex: "En attente", "Confirmée", "Annulée", "Terminée"

  Reservation({
    this.id,
    required this.nomClient,
    required this.emailClient,
    required this.numTelClient,
    required this.nombreConvives,
    required this.dateReservation,
    required this.heureReservation,
    required this.evenementSpecial,
    this.descriptionEvenement,
    this.notesSpeciales,
    required this.rappelDemande,
    this.status = 'En attente', // Statut par défaut à la création
  });

  // Méthode pour convertir l'objet Reservation en une Map (pour l'envoyer au backend Go en JSON)
  // C'est ici que le formatage de la date et de l'heure est CRUCIAL
  Map<String, dynamic> toMap() {
    return {
      'id': id, // L'ID peut être null pour la création, mais sera inclus pour la mise à jour/suppression
      'nomClient': nomClient,
      'emailClient': emailClient,
      'numTelClient': numTelClient,
      'nombreConvives': nombreConvives,
      // Formatage de la date en 'YYYY-MM-DD' (ex: "2025-06-12")
      'dateReservation': DateFormat('yyyy-MM-dd').format(dateReservation),
      // Formatage de l'heure en 'HH:MM' (ex: "14:30")
      'heureReservation': DateFormat('HH:mm').format(heureReservation),
      'evenementSpecial': evenementSpecial,
      'descriptionEvenement': descriptionEvenement,
      'notesSpeciales': notesSpeciales,
      'rappelDemande': rappelDemande,
      'status': status,
    };
  }

  // Constructeur factory pour créer un objet Reservation à partir d'une Map (reçue du backend Go)
  factory Reservation.fromMap(Map<String, dynamic> map) {
    // Parsing de la date et de l'heure
    DateTime parsedDate = DateTime.parse(map['dateReservation']);
    // Pour l'heure, nous avons besoin de la combiner avec une date pour créer un DateTime valide
    // On utilise la date du jour ou une date arbitraire pour créer l'objet DateTime de l'heure
    // car TimeOfDay n'est pas directement parsable en DateTime sans une date.
    // L'important est que l'heure elle-même (HH:MM) soit correcte.
    DateTime parsedTime = DateFormat('HH:mm').parse(map['heureReservation']);

    return Reservation(
      id: map['id'],
      nomClient: map['nomClient'],
      emailClient: map['emailClient'],
      numTelClient: map['numTelClient'],
      nombreConvives: map['nombreConvives'],
      dateReservation: parsedDate,
      // Ici, on crée un DateTime en utilisant l'année, mois, jour de la date de réservation
      // et l'heure et la minute de l'heure parsée.
      heureReservation: DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        parsedTime.hour,
        parsedTime.minute,
      ),
      evenementSpecial: map['evenementSpecial'] ?? false, // Gère les valeurs null pour les booléens
      descriptionEvenement: map['descriptionEvenement'],
      notesSpeciales: map['notesSpeciales'],
      rappelDemande: map['rappelDemande'] ?? false, // Gère les valeurs null pour les booléens
      status: map['status'],
    );
  }
}