import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'PetDatabaseHelper.dart';

/// This page shows a form that lets the user enter a new pet's information.
/// When the form is submitted the pet is saved to the database.
/// It also saves the data with EncryptedSharedPreferences so the user
/// can choose to copy the previous pet's info next time.
class AddPetPage extends StatefulWidget {
  const AddPetPage({super.key});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {

  // Controllers read whatever the user types into each text field
  final _nameController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _speciesController = TextEditingController();
  final _colourController = TextEditingController();
  final _ownerIdController = TextEditingController();

  // This key is used by the Form widget to validate all fields at once
  final _formKey = GlobalKey<FormState>();

  // This object lets us save and load data in an encrypted way on the device
  final _prefs = EncryptedSharedPreferences();

  @override
  void initState() {
    super.initState();

    // Wait until the page is built before showing the dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _askToCopyPreviousPet();
    });
  }

  /// Checks if there is previous pet data saved and asks the user what to do
  Future<void> _askToCopyPreviousPet() async {
    // Try to load the pet name that was saved last time
    final savedName = await _prefs.getString('petName');

    // Only show the dialog if there actually is some saved data
    if (savedName.isNotEmpty && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Copy Previous Pet?'),
          content: const Text(
            'Would you like to copy the information from the last pet you added?',
          ),
          actions: [
            // User chooses to start with empty fields
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Start Blank'),
            ),
            // User chooses to copy the previous pet's data into the fields
            TextButton(
              onPressed: () async {
                // Close the dialog first
                Navigator.pop(context);
                // Then load the saved data into the fields
                await _loadPreviousPetData();
              },
              child: const Text('Copy Previous'),
            ),
          ],
        ),
      );
    }
  }

  /// Loads the previously saved pet data into all the text fields
  Future<void> _loadPreviousPetData() async {
    // Read each saved value from encrypted storage
    final name = await _prefs.getString('petName');
    final birthday = await _prefs.getString('petBirthday');
    final species = await _prefs.getString('petSpecies');
    final colour = await _prefs.getString('petColour');
    final ownerId = await _prefs.getString('petOwnerId');

    // Put each value into its matching text field on screen
    setState(() {
      _nameController.text = name;
      _birthdayController.text = birthday;
      _speciesController.text = species;
      _colourController.text = colour;
      _ownerIdController.text = ownerId;
    });
  }

  /// Saves the current form data to EncryptedSharedPreferences for next time
  Future<void> _savePetToPrefs() async {
    // Save each field value with a unique key
    await _prefs.setString('petName', _nameController.text);
    await _prefs.setString('petBirthday', _birthdayController.text);
    await _prefs.setString('petSpecies', _speciesController.text);
    await _prefs.setString('petColour', _colourController.text);
    await _prefs.setString('petOwnerId', _ownerIdController.text);
  }

  /// Validates the form and saves the new pet to the database
  Future<void> _savePet() async {
    // Check if all required fields are filled — validate() returns false if not
    if (_formKey.currentState!.validate()) {

      // Save the data to encrypted prefs so it can be copied next time
      await _savePetToPrefs();

      // Build the map of data to insert into the database.
      final newPet = {
        'name': _nameController.text,
        'birthday': _birthdayController.text,
        'species': _speciesController.text,
        'colour': _colourController.text,
        'ownerId': _ownerIdController.text,
      };

      // Insert the pet into the database using the helper
      await PetDatabaseHelper.instance.insertPet(newPet);

      // Show a quick success message at the bottom of the screen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet added successfully!'),
            backgroundColor: Colors.blue,
          ),
        );

        // Go back to the pet list page and tell it to refresh (result = true)
        Navigator.pop(context, true);
      }
    }
  }

  @override
  void dispose() {
    // Always clean up controllers when the page is closed to avoid memory leaks
    _nameController.dispose();
    _birthdayController.dispose();
    _speciesController.dispose();
    _colourController.dispose();
    _ownerIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Title shown at the top of this page
        title: const Text('Add New Pet'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      // SingleChildScrollView lets the user scroll if the keyboard appears
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          // The form key lets us validate all fields at once
          key: _formKey,
          child: Column(
            children: [

              // Pet Name field — required
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Pet Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pets),
                ),
                // Validator runs when the user presses Submit
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the pet\'s name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Birthday field — required, user types in YYYY-MM-DD format
              TextFormField(
                controller: _birthdayController,
                decoration: const InputDecoration(
                  labelText: 'Birthday (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the pet\'s birthday';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Species field — required (e.g. cat, dog, bird)
              TextFormField(
                controller: _speciesController,
                decoration: const InputDecoration(
                  labelText: 'Species (e.g. cat, dog, bird)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the pet\'s species';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Colour field — required
              TextFormField(
                controller: _colourController,
                decoration: const InputDecoration(
                  labelText: 'Colour',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.palette),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the pet\'s colour';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Owner ID field — required, links this pet to its owner
              TextFormField(
                controller: _ownerIdController,
                decoration: const InputDecoration(
                  labelText: 'Owner ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                // Only numbers are expected here since owner IDs are integers
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the owner ID';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // Submit button — calls _savePet() when pressed
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _savePet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Add Pet',
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