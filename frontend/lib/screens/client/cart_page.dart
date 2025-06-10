import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define your colors for consistency
    final Color primaryAppColor = const Color(0xFF4A6572);
    final Color accentColor = const Color(0xFFFF9800);
    final Color backgroundColor = const Color(0xFFD9E2E5);

    // Dummy cart items for demonstration, structured to match the image display
    // Only one item is shown in the image, so we'll simulate that.
    final List<Map<String, dynamic>> cartItems = [
      {
        'name': 'Salade César Signature',
        'price': 12.99,
        'imageUrl': 'https://plus.unsplash.com/premium_photo-1664392002995-4ee10b7f91e5?q=80&w=2014&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      },
      // You can add more items here to see them in the list, e.g.:
      // {
      //   'name': 'Filet de Saumon Grillé',
      //   'price': 25.50,
      //   'imageUrl': 'https://plus.unsplash.com/premium_photo-1723478417559-2349252a3dda?q=80&w=1966&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      // },
    ];

    // Assuming a fixed delivery fee for this example
    const double deliveryFee = 5.00;
    double subtotal = cartItems.fold(0.0, (sum, item) => sum + item['price']);
    double totalToPay = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0, // AppBar shadow removed to match image
        title: Text(
          'Votre Panier',
          style: GoogleFonts.poppins(
            color: primaryAppColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false, // Title aligned to the left as in the image
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryAppColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 20),
                        Text(
                          'Votre panier est vide',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Ajoutez des plats pour passer commande !',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(context, item, primaryAppColor, accentColor);
                    },
                  ),
          ),
          // --- Order Summary and Checkout Button ---
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white, // White background for the summary section
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, -5), // Shadow upwards
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sous-total',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '${subtotal.toStringAsFixed(2)} €', // Euro symbol
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Frais de livraison',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '${deliveryFee.toStringAsFixed(2)} €', // Euro symbol
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30, thickness: 1), // Separator line
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total à payer',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryAppColor,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          totalToPay.toStringAsFixed(2),
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Custom Euro icon (using Text for simplicity, FontAwesomeIcon for more control)
                        Text(
                          '€', // Using a Text widget for the Euro symbol
                          style: GoogleFonts.poppins(
                            fontSize: 20, // Slightly smaller to look like an icon
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement checkout logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Procéder au paiement...', style: GoogleFonts.poppins()),
                        backgroundColor: primaryAppColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor, // Orange color from your image
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 7,
                    shadowColor: accentColor.withOpacity(0.4),
                  ),
                  icon: const Icon(Icons.credit_card, color: Colors.white, size: 24), // Payment icon
                  label: Text(
                    'Procéder au Paiement',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, Map<String, dynamic> item, Color primaryColor, Color accentColor) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      color: Colors.white, // Card background color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item['imageUrl'],
                width: 80, // Slightly larger image to match the provided image
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 17, // Adjusted font size to match image
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 1, // Only one line for the name as in the image
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8), // Spacing between name and price
                  Text(
                    '${item['price'].toStringAsFixed(2)} €', // Display price with Euro symbol
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, // Slightly less bold than name
                      fontSize: 15, // Adjusted font size
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 28), // Larger delete icon
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item['name']} supprimé du panier', style: GoogleFonts.poppins()),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
                // TODO: Implement actual item removal from cart in your state management
              },
            ),
          ],
        ),
      ),
    );
  }
}