import 'package:flutter/material.dart';
import 'vaccine_database_helper.dart';

/// This page displays the details of a selected vaccine.
///
/// It allows the user to:
/// - View vaccine information
/// - Update vaccine data
/// - Delete the vaccine
class VaccineDetailPage extends StatefulWidget {

  /// The selected vaccine data passed from the list page
  final Map<String, dynamic> vaccine;

  /// Constructor requiring a vaccine map
  const VaccineDetailPage({super.key, required this.vaccine});

  @override
  State<VaccineDetailPage> createState() => _VaccineDetailPageState();
}

class _VaccineDetailPageState extends State<VaccineDetailPage> {

  /// Controller for vaccine name field
  late TextEditingController _nameController;

  /// Controller for dosage field
  late TextEditingController _dosageController;

  /// Controller for lot number field
  late TextEditingController _lotController;

  /// Controller for expiration date field
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();

    /// Initialize controllers with existing vaccine data
    _nameController = TextEditingController(text: widget.vaccine['name']);
    _dosageController = TextEditingController(text: widget.vaccine['dosage']);
    _lotController = TextEditingController(text: widget.vaccine['lotNumber']);
    _dateController =
        TextEditingController(text: widget.vaccine['expirationDate']);
  }

  /// Updates the vaccine in the database
  ///
  /// Validates fields before updating.
  /// Shows a Snackbar after successful update.
  Future<void> _updateVaccine() async {

    /// Check if any field is empty
    if (_nameController.text.isEmpty ||
        _dosageController.text.isEmpty ||
        _lotController.text.isEmpty ||
        _dateController.text.isEmpty) {

      /// Show error message if validation fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    /// Create updated vaccine data map
    final updatedVaccine = {
      'id': widget.vaccine['id'],
      'name': _nameController.text,
      'dosage': _dosageController.text,
      'lotNumber': _lotController.text,
      'expirationDate': _dateController.text,
    };

    /// Update database record
    await VaccineDatabaseHelper.instance.updateVaccine(updatedVaccine);

    /// Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vaccine updated')),
    );

    /// Return to previous page
    Navigator.pop(context);
  }

  /// Deletes the selected vaccine from the database
  ///
  /// Shows confirmation dialog before deletion.
  Future<void> _deleteVaccine() async {

    /// Ask user for confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vaccine'),
        content: const Text('Are you sure you want to delete this vaccine?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    /// If user confirms deletion
    if (confirm == true) {

      /// Delete vaccine from database
      await VaccineDatabaseHelper.instance
          .deleteVaccine(widget.vaccine['id']);

      /// Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vaccine deleted')),
      );

      /// Return to previous page
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// App bar showing page title
      appBar: AppBar(
        title: const Text('Vaccine Details'),
      ),

      /// Main content area
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// Input field for vaccine name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),

            /// Input field for dosage
            TextField(
              controller: _dosageController,
              decoration: const InputDecoration(labelText: 'Dosage'),
            ),

            /// Input field for lot number
            TextField(
              controller: _lotController,
              decoration: const InputDecoration(labelText: 'Lot Number'),
            ),

            /// Input field for expiration date
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Expiration Date'),
            ),

            /// Space before buttons
            const SizedBox(height: 20),

            /// Button to update vaccine
            ElevatedButton(
              onPressed: _updateVaccine,
              child: const Text('Update'),
            ),

            /// Space between buttons
            const SizedBox(height: 10),

            /// Button to delete vaccine
            ElevatedButton(
              onPressed: _deleteVaccine,
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}