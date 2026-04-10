import 'package:flutter/material.dart';
import 'PetDatabaseHelper.dart';
import 'AddPetPage.dart';

/// This is the main Pet page.
/// It shows a list of all pets stored in the database.
/// Tapping a pet from the list shows its details on the right side (tablet)
/// or opens a new screen (phone).
/// From the details view the user can update or delete the pet.
class PetPage extends StatefulWidget {
  const PetPage({super.key});

  @override
  State<PetPage> createState() => _PetPageState();
}

class _PetPageState extends State<PetPage> {

  // This list holds all the pets we load from the database
  List<Map<String, dynamic>> _pets = [];

  // This holds the pet the user has selected used for the tablet layout
  Map<String, dynamic>? _selectedPet;

  // Controllers for the detail/edit fields shown when a pet is selected
  final _nameController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _speciesController = TextEditingController();
  final _colourController = TextEditingController();
  final _ownerIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load the pets from the database as soon as the page opens
    _loadPets();
  }

  /// Loads all pets from the database and refreshes what is shown on screen
  Future<void> _loadPets() async {
    // Get the list of all pets from the database helper
    final pets = await PetDatabaseHelper.instance.getAllPets();

    // Update the state so Flutter redraws the list
    setState(() {
      _pets = pets;
    });
  }

  /// Returns true if the screen is wide enough to be considered a tablet
  bool _isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  /// Fills the detail form fields with the selected pet's data
  void _fillDetailFields(Map<String, dynamic> pet) {
    // Copy each field value into its matching controller
    _nameController.text = pet['name'] ?? '';
    _birthdayController.text = pet['birthday'] ?? '';
    _speciesController.text = pet['species'] ?? '';
    _colourController.text = pet['colour'] ?? '';
    _ownerIdController.text = pet['ownerId'] ?? '';
  }

  /// Called when the user taps a pet in the list
  void _onPetTapped(Map<String, dynamic> pet) {
    if (_isTablet(context)) {
      // On a tablet — show the detail panel on the right side
      setState(() {
        _selectedPet = pet;
        // Fill in the edit fields with this pet's data
        _fillDetailFields(pet);
      });
    } else {
      // On a phone — show the detail in a dialog (same page, no navigation)
      _fillDetailFields(pet);
      setState(() {
        _selectedPet = pet;
      });
      // Show the detail dialog for phone users
      _showDetailDialog(pet);
    }
  }

  /// Shows a dialog with the pet's details on phone screens
  void _showDetailDialog(Map<String, dynamic> pet) {
    showDialog(
      context: context,
      // barrierDismissible lets the user tap outside to close without changes
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          // Title shows the pet's name
          title: Text(pet['name'] ?? 'Pet Details'),
          content: SingleChildScrollView(
            child: _buildDetailForm(),
          ),
          actions: [
            // Delete button — removes this pet from the list and database
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deletePet();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
            // Update button — saves changes to the database
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updatePet();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  /// Saves updated pet data to the database
  Future<void> _updatePet() async {
    // Make sure we actually have a pet selected
    if (_selectedPet == null) return;

    // Check that all fields have something in them before saving
    if (_nameController.text.isEmpty ||
        _birthdayController.text.isEmpty ||
        _speciesController.text.isEmpty ||
        _colourController.text.isEmpty ||
        _ownerIdController.text.isEmpty) {
      // Tell the user they left something empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields before updating')),
      );
      return;
    }

    // Build the updated pet map — keep the same id so we update the right row
    final updatedPet = {
      'id': _selectedPet!['id'],
      'name': _nameController.text,
      'birthday': _birthdayController.text,
      'species': _speciesController.text,
      'colour': _colourController.text,
      'ownerId': _ownerIdController.text,
    };

    // Send the update to the database helper
    await PetDatabaseHelper.instance.updatePet(updatedPet);

    // Show a confirmation message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pet updated!'),
          backgroundColor: Colors.blue,
        ),
      );
    }

    // Clear the selection and refresh the list
    setState(() {
      _selectedPet = null;
    });
    await _loadPets();
  }

  /// Deletes the currently selected pet from the database
  Future<void> _deletePet() async {
    // Make sure we actually have a pet selected before deleting
    if (_selectedPet == null) return;

    // Show a confirmation dialog so the user doesn't delete by accident
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pet?'),
        content: Text('Are you sure you want to delete ${_selectedPet!['name']}?'),
        actions: [
          // User changed their mind — do nothing
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          // User confirms — go ahead with the delete
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // Only delete if the user pressed the Delete button
    if (confirmed == true) {
      // Delete from database using the selected pet's id
      await PetDatabaseHelper.instance.deletePet(_selectedPet!['id']);

      // Show a confirmation message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet deleted.'),
            backgroundColor: Colors.red,
          ),
        );
      }

      // Clear the selected pet and refresh the list
      setState(() {
        _selectedPet = null;
      });
      await _loadPets();
    }
  }

  /// Builds the editable form fields shown in the detail panel or dialog
  Widget _buildDetailForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        // Pet Name field
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Pet Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.pets),
          ),
        ),

        const SizedBox(height: 12),

        // Birthday field
        TextField(
          controller: _birthdayController,
          decoration: const InputDecoration(
            labelText: 'Birthday (YYYY-MM-DD)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.cake),
          ),
        ),

        const SizedBox(height: 12),

        // Species field
        TextField(
          controller: _speciesController,
          decoration: const InputDecoration(
            labelText: 'Species',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
        ),

        const SizedBox(height: 12),

        // Colour field
        TextField(
          controller: _colourController,
          decoration: const InputDecoration(
            labelText: 'Colour',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.palette),
          ),
        ),

        const SizedBox(height: 12),

        // Owner ID field
        TextField(
          controller: _ownerIdController,
          decoration: const InputDecoration(
            labelText: 'Owner ID',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          keyboardType: TextInputType.number,
        ),

      ],
    );
  }

  /// Builds the list of pets shown on the left side (or full screen on phone)
  Widget _buildPetList() {
    // Show a message if there are no pets yet
    if (_pets.isEmpty) {
      return const Center(
        child: Text(
          'No pets yet.\nPress + to add one.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Build a scrollable list with one row per pet
    return ListView.builder(
      itemCount: _pets.length,
      itemBuilder: (context, index) {
        final pet = _pets[index];

        return ListTile(
          // Paw icon on the left of each row
          leading: const Icon(Icons.pets, color: Colors.blue),
          // Pet name as the main text
          title: Text(pet['name'] ?? ''),
          // Species shown as smaller text below the name
          subtitle: Text('${pet['species']} · ${pet['colour']}'),
          // Arrow icon on the right to hint the row is tappable
          trailing: const Icon(Icons.chevron_right),
          // Highlight the row that is currently selected on tablet
          tileColor: _selectedPet != null && _selectedPet!['id'] == pet['id']
              ? Colors.blue.withOpacity(0.1)
              : null,
          // When the user taps the row call _onPetTapped
          onTap: () => _onPetTapped(pet),
        );
      },
    );
  }

  /// Builds the detail panel shown on the right side of the screen on tablets
  Widget _buildTabletDetailPanel() {
    // If nothing is selected yet, show a placeholder message
    if (_selectedPet == null) {
      return const Center(
        child: Text(
          'Select a pet to see its details',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Show the editable form and the Update / Delete buttons
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // Header showing which pet we are looking at
          Text(
            _selectedPet!['name'] ?? '',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // The editable form fields
          _buildDetailForm(),

          const SizedBox(height: 24),

          // Update button — saves any changes the user made
          ElevatedButton(
            onPressed: _updatePet,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Update Pet', style: TextStyle(fontSize: 16)),
          ),

          const SizedBox(height: 12),

          // Delete button — removes this pet from the list and database
          OutlinedButton(
            onPressed: _deletePet,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Delete Pet', style: TextStyle(fontSize: 16)),
          ),

        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up all the text controllers when this page is closed
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
        title: const Text('Pets'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Help button — shows instructions when pressed
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('How to use'),
                  content: const Text(
                    '1. Press the + button to add a new pet.\n\n'
                        '2. Tap a pet in the list to view or edit its details.\n\n'
                        '3. Use the Update button to save changes.\n\n'
                        '4. Use the Delete button to remove a pet.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      // Choose the layout based on screen width (phone or tablet)
      body: _isTablet(context)

      // Tablet layout — list on the left, detail on the right
          ? Row(
        children: [
          // Left side: the pet list (takes 1/3 of the width)
          Expanded(
            flex: 1,
            child: _buildPetList(),
          ),

          // A thin line separating the two sides
          const VerticalDivider(width: 1),

          // Right side: the detail / edit panel (takes 2/3 of the width)
          Expanded(
            flex: 2,
            child: _buildTabletDetailPanel(),
          ),
        ],
      )

      // Phone layout — just show the list full screen
          : _buildPetList(),

      // Floating + button that opens the Add Pet page
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () async {
          // Wait for the Add Pet page to close
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPetPage()),
          );

          // If a new pet was added (result == true), refresh the list
          if (result == true) {
            _loadPets();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}