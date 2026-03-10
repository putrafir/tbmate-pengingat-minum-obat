import 'package:flutter/material.dart';

// --- Main Page Widget ---
class EditPhoneNumberPage extends StatelessWidget {
  const EditPhoneNumberPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. App Bar
      appBar: AppBar(
        // Background color is the green from the image
        backgroundColor: const Color(0xFF388E3C), // A shade of deep green
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Handle back button press (e.g., Navigator.pop(context))
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Ganti No. Handphone',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      // 2. Main Content Area (White/Cream background)
      body: Container(
        color: const Color(0xFFF9FFF6), // Very light cream/green tint
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: <Widget>[
              // Phone Number Input
              _buildPhoneNumberInput(),
              const SizedBox(height: 32),
              // Edit Button
              _buildEditButton(context),
            ],
          ),
        ),
      ),
 
    );
  }

  // --- Widget Builders ---

  Widget _buildPhoneNumberInput() {
    // This uses a TextFormField styled to look like the image
    return TextFormField(
      initialValue: '+62 813 1286 9846', // The example number
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        // The phone icon on the left
        prefixIcon: const Padding(
          padding: EdgeInsets.only(right: 12.0),
          child: Icon(
            Icons.call,
            color: Colors.black54,
            size: 24,
          ),
        ),
        // Removes the default label
        labelText: null,
        hintText: 'Masukkan nomor handphone baru',
        // Underscore line style
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black45, width: 1.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.green.shade700, width: 2.0),
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    // The main blue button
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Logic for handling the phone number update
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mengedit Nomor Handphone...')),
          );
        },
        style: ElevatedButton.styleFrom(
          // Blue color from the image
          backgroundColor: const Color(0xFF79D5F0), // A bright sky blue
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Rounded corners
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0, // Removes shadow for a flat look
        ),
        child: const Text(
          'Edit',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  
}

