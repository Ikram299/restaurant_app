import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http; // Importez le package http
import 'dart:convert'; // Nécessaire pour encoder/décoder JSON

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> with TickerProviderStateMixin {
  // Consistent color palette
  static const Color _backgroundColor = Color(0xFFD9E2E5);
  static const Color _primaryColor = Color(0xFF4A6572);
  static const Color _textColorDark = Color(0xFF333333);
  static const Color _textColorMedium = Color(0xFF666666);
  static const Color _cardColor = Colors.white;
  static const Color _accentColor = Color(0xFF7A9BA8);

  // Controllers for new input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  int _numberOfPeople = 2;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 0);
  bool _isSpecialEvent = false;
  bool _wantReminder = true;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _notesController.dispose();
    _eventDescriptionController.dispose();
    _nameController.dispose();   // Dispose new controllers
    _emailController.dispose();  // Dispose new controllers
    _phoneController.dispose();  // Dispose new controllers
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              onSurface: _textColorDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: _primaryColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              onSurface: _textColorDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: _primaryColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

 // ... (existing code)

// ... (existing code above)

Future<void> _confirmReservation() async {
  final String clientName = _nameController.text.trim();
  final String clientEmail = _emailController.text.trim();
  final String clientPhone = _phoneController.text.trim();

  // Validations... (keep your existing validations)
  if (clientName.isEmpty || clientEmail.isEmpty || clientPhone.isEmpty) {
    _showSnackBar('Veuillez renseigner vos coordonnées (Nom, Email, Téléphone).', Colors.red);
    return;
  }
  if (!clientEmail.contains('@') || !clientEmail.contains('.')) {
    _showSnackBar('Veuillez entrer une adresse email valide.', Colors.red);
    return;
  }
  if (_numberOfPeople <= 0) {
    _showSnackBar('Veuillez sélectionner au moins une personne.', Colors.red);
    return;
  }
  if (_isSpecialEvent && _eventDescriptionController.text.trim().isEmpty) {
    _showSnackBar('Veuillez décrire votre événement spécial.', Colors.red);
    return;
  }

  const String apiUrl = 'http://192.168.11.105:8080/api/reservations';

  // Combine selected date and time into a single DateTime object (local time)
  final DateTime localCombinedDateTime = DateTime(
    _selectedDate.year,
    _selectedDate.month,
    _selectedDate.day,
    _selectedTime.hour,
    _selectedTime.minute,
  );

  // CONVERT TO UTC BEFORE FORMATTING TO ISO 8601 STRING
  // This ensures the 'Z' (for UTC) is appended, which your Go backend expects.
  final DateTime utcCombinedDateTime = localCombinedDateTime.toUtc();

  // Format to ISO 8601 string (e.g., "2025-06-24T19:00:00.000Z")
  final String formattedReservationDateTime = utcCombinedDateTime.toIso8601String(); // <-- THIS IS THE KEY FIX

  Map<String, dynamic> reservationData = {
    'client_name': clientName,
    'client_email': clientEmail,
    'client_phone': clientPhone,
    'num_guests': _numberOfPeople,
    'reservation_date': formattedReservationDateTime, // Use the correctly formatted UTC string
    'reservation_time': _selectedTime.format(context), // Keep this if needed for display/other logic, but Go only needs reservation_date now
    'is_special_event': _isSpecialEvent,
    'event_description': _isSpecialEvent ? _eventDescriptionController.text.trim() : '',
    'special_notes': _notesController.text.trim(),
    'wants_reminder': _wantReminder,
  };

  // *******************************************************************
  print('DEBUG FLUTTER: Données de réservation envoyées: ${json.encode(reservationData)}');
  // *******************************************************************

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(reservationData),
    );

    if (response.statusCode == 201) {
      _showSnackBar('Réservation effectuée avec succès !', Colors.green);
      _showConfirmationDialog();
    } else {
      print('DEBUG FLUTTER: Échec de la création de la réservation. Statut: ${response.statusCode}');
      print('DEBUG FLUTTER: Corps de la réponse: ${response.body}');
      _showSnackBar(
        'Échec de la réservation: ${response.statusCode} - ${response.body}',
        Colors.red,
      );
    }
  } catch (e) {
    print('DEBUG FLUTTER: Erreur lors de l\'envoi de la requête: $e');
    _showSnackBar('Erreur de connexion: Impossible de joindre le serveur. $e', Colors.red);
  }
}

// ... (rest of your code below)
 void _showConfirmationDialog() {
  String reservationDetails = """
    Nom: ${_nameController.text.trim()}
    Email: ${_emailController.text.trim()}
    Téléphone: ${_phoneController.text.trim()}
    Nombre de personnes: $_numberOfPeople
    Date: ${DateFormat.yMMMMd('fr_FR').format(_selectedDate)}
    Heure: ${_selectedTime.format(context)}
    Événement spécial: ${_isSpecialEvent ? 'Oui (${_eventDescriptionController.text.trim()})' : 'Non'}
    Notes: ${_notesController.text.trim().isNotEmpty ? _notesController.text.trim() : 'Aucune'}
    Rappel: ${_wantReminder ? 'Oui' : 'Non'}
    """;

  // Define your colors if they are not global constants, or ensure they are accessible here
  // For demonstration, let's assume _primaryColor, _cardColor, _backgroundColor, _textColorDark, _textColorMedium are defined.
  // If not, you'll need to define them, e.g.:
  // static const Color _primaryColor = Colors.blue;
  // static const Color _cardColor = Colors.white;
  // static const Color _backgroundColor = Colors.grey;
  // static const Color _textColorDark = Colors.black87;
  // static const Color _textColorMedium = Colors.grey;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 16,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              // Replace with your actual color variables if they are not directly available.
              colors: [
                _cardColor, // Assuming _cardColor is defined
                _backgroundColor.withOpacity(0.3), // Assuming _backgroundColor is defined
              ],
            ),
          ),
          // Wrap the Column with SingleChildScrollView to allow scrolling if content overflows
          child: SingleChildScrollView( // <--- ADDED THIS WIDGET
            child: Column(
              mainAxisSize: MainAxisSize.min, // Keep mainAxisSize.min
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1), // Assuming _primaryColor is defined
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: _primaryColor, // Assuming _primaryColor is defined
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Réservation Confirmée !',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: _textColorDark, // Assuming _textColorDark is defined
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Votre table est réservée. Nous avons hâte de vous accueillir !',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: _textColorMedium, // Assuming _textColorMedium is defined
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _backgroundColor.withOpacity(0.3), // Assuming _backgroundColor is defined
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    reservationDetails,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _textColorMedium, // Assuming _textColorMedium is defined
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Ferme la boîte de dialogue
                      // Optionnel: Vider les champs ou revenir à la page précédente
                      // Navigator.of(context).pop(); // Pour revenir à l'écran précédent
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor, // Assuming _primaryColor is defined
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Parfait !',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: _backgroundColor,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: _primaryColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 72, bottom: 16),
              title: const Text(
                'Réserver une table',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: _textColorDark,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card with restaurant info
                      _buildWelcomeCard(),
                      const SizedBox(height: 32),

                      // Contact Info Section (NEW)
                      _buildAnimatedSection(
                        'Vos coordonnées',
                        Icons.person_outline,
                        _buildContactInfoFields(),
                        -1, // Use a different index or remove it if animations are not strictly sequential
                      ),
                      const SizedBox(height: 28),

                      // People Selection
                      _buildAnimatedSection(
                        'Nombre de convives',
                        Icons.people_outline,
                        _buildPeoplePicker(),
                        0,
                      ),
                      const SizedBox(height: 28),

                      // Date & Time
                      _buildAnimatedSection(
                        'Quand souhaitez-vous venir ?',
                        Icons.schedule,
                        _buildDateTimePickers(),
                        1,
                      ),
                      const SizedBox(height: 28),

                      // Special Event
                      _buildAnimatedSection(
                        'Occasion spéciale',
                        Icons.celebration_outlined,
                        _buildSpecialEventSection(),
                        2,
                      ),
                      const SizedBox(height: 28),

                      // Notes
                      _buildAnimatedSection(
                        'Vos préférences',
                        Icons.edit_note,
                        _buildNotesField(),
                        3,
                      ),
                      const SizedBox(height: 28),

                      // Reminder
                      _buildAnimatedSection(
                        'Notifications',
                        Icons.notifications_outlined,
                        _buildReminderSwitch(),
                        4,
                      ),
                      const SizedBox(height: 40),

                      // Confirm Button
                      _buildConfirmButton(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets existants inchangés ---
  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryColor,
            _accentColor,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Réservation Express',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      'Configurez votre expérience parfaite',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection(String title, IconData icon, Widget content, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: _primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _textColorDark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                content,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeoplePicker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuantityButton(
            icon: Icons.remove,
            onPressed: () => setState(() => _numberOfPeople = _numberOfPeople > 1 ? _numberOfPeople - 1 : 1),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryColor.withOpacity(0.1), _accentColor.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  '$_numberOfPeople',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: _primaryColor,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  _numberOfPeople == 1 ? 'personne' : 'personnes',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textColorMedium,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            onPressed: () => setState(() => _numberOfPeople++),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _primaryColor.withOpacity(0.2)),
          ),
          child: Icon(icon, color: _primaryColor, size: 24),
        ),
      ),
    );
  }

  Widget _buildDateTimePickers() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPickerTile(
            icon: Icons.calendar_today_outlined,
            title: 'Date',
            subtitle: DateFormat.yMMMMd('fr_FR').format(_selectedDate),
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 16),
          _buildPickerTile(
            icon: Icons.access_time,
            title: 'Heure',
            subtitle: _selectedTime.format(context),
            onTap: () => _selectTime(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _backgroundColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: _primaryColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: _textColorMedium,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textColorDark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: _textColorMedium, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialEventSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Célébrez avec nous',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textColorDark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Anniversaire, fête, événement spécial...',
                      style: TextStyle(
                        fontSize: 13,
                        color: _textColorMedium,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 1.2,
                child: Switch(
                  value: _isSpecialEvent,
                  onChanged: (value) => setState(() => _isSpecialEvent = value),
                  activeColor: _primaryColor,
                  activeTrackColor: _primaryColor.withOpacity(0.3),
                ),
              ),
            ],
          ),
          if (_isSpecialEvent) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _eventDescriptionController,
              decoration: InputDecoration(
                hintText: 'Décrivez votre événement... (ex: Anniversaire de M. Dupont)',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontFamily: 'Poppins'),
                fillColor: _backgroundColor.withOpacity(0.3),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              minLines: 2,
              maxLines: 3,
              style: const TextStyle(fontSize: 15, color: _textColorDark, fontFamily: 'Poppins'),
              cursorColor: _primaryColor,
            ),
          ],
        ],
      ),
    );
  }

  // --- NOUVELLE FONCTION pour les champs d'informations de contact ---
  Widget _buildContactInfoFields() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(_nameController, 'Votre Nom Complet', Icons.person),
          const SizedBox(height: 16),
          _buildTextField(_emailController, 'Votre Email', Icons.email, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _buildTextField(_phoneController, 'Votre Numéro de Téléphone', Icons.phone, keyboardType: TextInputType.phone),
        ],
      ),
    );
  }

  // --- FONCTION UTILITAIRE pour les champs de texte ---
  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: _textColorDark, fontFamily: 'Poppins'),
      cursorColor: _primaryColor,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontFamily: 'Poppins'),
        fillColor: _backgroundColor.withOpacity(0.3),
        filled: true,
        prefixIcon: Icon(icon, color: _primaryColor.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
  // --- Fin des fonctions utilitaires et nouvelles ---


  Widget _buildNotesField() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _notesController,
        decoration: InputDecoration(
          hintText: 'Allergies, préférences de placement, demandes spéciales...',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontFamily: 'Poppins'),
          fillColor: _backgroundColor.withOpacity(0.3),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        minLines: 3,
        maxLines: 5,
        style: const TextStyle(fontSize: 15, color: _textColorDark, fontFamily: 'Poppins'),
        cursorColor: _primaryColor,
      ),
    );
  }

  Widget _buildReminderSwitch() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_active, color: _primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rappel de réservation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textColorDark,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Recevez un rappel par e-mail',
                  style: TextStyle(
                    fontSize: 13,
                    color: _textColorMedium,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.2,
            child: Switch(
              value: _wantReminder,
              onChanged: (value) => setState(() => _wantReminder = value),
              activeColor: _primaryColor,
              activeTrackColor: _primaryColor.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryColor, _accentColor],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _confirmReservation,
          borderRadius: BorderRadius.circular(20),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  'Confirmer ma réservation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}