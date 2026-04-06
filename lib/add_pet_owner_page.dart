import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'database_helper.dart';

/// This page lets the user fill in a form to add a new pet owner.
/// It validates all required fields before saving to the database.
/// It uses EncryptedSharedPreferences to save the last entered data
/// so the user can copy it next time they add a new customer.
class AddPetOwnerPage extends StatefulWidget {
  const AddPetOwnerPage({super.key});

  @override
  State<AddPetOwnerPage> createState() => _AddPetOwnerPageState();
}

class _AddPetOwnerPageState extends State<AddPetOwnerPage> {

  // Controllers to read what the user types in each field
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _insuranceController = TextEditingController();

  // Used to validate the form fields
  final _formKey = GlobalKey<FormState>();

  // This is used to save and load encrypted data
  final _prefs = EncryptedSharedPreferences();

  @override
  void initState() {
    super.initState();
    // Ask the user if they want to copy previous data when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _askToCopyPreviousData();
    });
  }

  /// Loads the previously saved customer data from EncryptedSharedPreferences
  Future<void> _askToCopyPreviousData() async {
    // Check if there is any previously saved data
    final savedFirstName = await _prefs.getString('firstName');

    // Only show the dialog if there is saved data
    if (savedFirstName.isNotEmpty && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Copy Previous Customer?'),
          content: const Text(
            'Would you like to copy the information from the previous customer?',
          ),
          actions: [
            // Start with blank fields
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Start Blank'),
            ),
            // Copy the previous customer data into the fields
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _loadPreviousData();
              },
              child: const Text('Copy Previous'),
            ),
          ],
        ),
      );
    }
  }

  /// Fills the form fields with the previously saved customer data
  Future<void> _loadPreviousData() async {
    final firstName = await _prefs.getString('firstName');
    final lastName = await _prefs.getString('lastName');
    final address = await _prefs.getString('address');
    final dob = await _prefs.getString('dateOfBirth');
    final insurance = await _prefs.getString('insuranceNumber');

    // Put the saved data into the text fields
    setState(() {
      _firstNameController.text = firstName;
      _lastNameController.text = lastName;
      _addressController.text = address;
      _dobController.text = dob;
      _insuranceController.text = insurance;
    });
  }

  /// Saves the current form data to EncryptedSharedPreferences
  Future<void> _saveToPrefs() async {
    await _prefs.setString('firstName', _firstNameController.text);
    await _prefs.setString('lastName', _lastNameController.text);
    await _prefs.setString('address', _addressController.text);
    await _prefs.setString('dateOfBirth', _dobController.text);
    await _prefs.setString('insuranceNumber', _insuranceController.text);
  }

  /// Saves the new pet owner to the database
  Future<void> _saveOwner() async {
    // Check all required fields are filled
    if (_formKey.currentState!.validate()) {

      // Save this customer's data to prefs for next time
      await _saveToPrefs();

      // Create a map with all the owner's data
      final newOwner = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'address': _addressController.text,
        'dateOfBirth': _dobController.text,
        'insuranceNumber': _insuranceController.text,
      };

      // Insert into database
      await DatabaseHelper.instance.insertOwner(newOwner);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet owner added successfully!'),
            backgroundColor: Colors.teal,
          ),
        );

        // Go back to the list page
        Navigator.pop(context, true);
      }
    }
  }

  @override
  void dispose() {
    // Clean up controllers when the page is closed
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _insuranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Pet Owner'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // First Name field
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a first name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Last Name field
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a last name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Address field
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Date of Birth field
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date of birth';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Insurance Number field (optional)
              TextFormField(
                controller: _insuranceController,
                decoration: const InputDecoration(
                  labelText: 'Pet Insurance # (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shield),
                ),
              ),

              const SizedBox(height: 30),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveOwner,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Add Customer',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}