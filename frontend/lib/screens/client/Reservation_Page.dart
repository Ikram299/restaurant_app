import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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

  void _confirmReservation() {
    if (_numberOfPeople <= 0) {
      _showSnackBar('Veuillez sélectionner au moins une personne.', Colors.red);
      return;
    }
    if (_isSpecialEvent && _eventDescriptionController.text.trim().isEmpty) {
      _showSnackBar('Veuillez décrire votre événement spécial.', Colors.red);
      return;
    }

    String reservationDetails = """
    Nombre de personnes: $_numberOfPeople
    Date: ${DateFormat.yMMMMd('fr_FR').format(_selectedDate)}
    Heure: ${_selectedTime.format(context)}
    Événement spécial: ${_isSpecialEvent ? 'Oui (${_eventDescriptionController.text})' : 'Non'}
    Notes: ${_notesController.text.isNotEmpty ? _notesController.text : 'Aucune'}
    Rappel: ${_wantReminder ? 'Oui' : 'Non'}
    """;

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
                colors: [
                  _cardColor,
                  _backgroundColor.withOpacity(0.3),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: _primaryColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Réservation Confirmée !',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: _textColorDark,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Votre table est réservée. Nous avons hâte de vous accueillir !',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: _textColorMedium,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _backgroundColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    reservationDetails,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _textColorMedium,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
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
