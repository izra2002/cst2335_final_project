import 'package:flutter/material.dart';
import 'database_helper.dart';

/// This page shows the full details of a selected pet owner.
/// The user can update the owner's information or delete them
/// from the database using the buttons at the bottom.
class PetOwnerDetailPage extends StatefulWidget {

  /// The pet owner data passed from the list page
  final Map<String, dynamic> owner;

  const PetOwnerDetailPage({super.key, required this.owner});

  @override
  State<PetOwnerDetailPage> createState() => _PetOwnerDetailPageState();
}

class _PetOwnerDetailPageState extends State<PetOwnerDetailPage> {

  // Controllers pre-filled with the owner's existing data
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;
  late TextEditingController _insuranceController;

  // Used to validate the form fields
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Fill the fields with the existing owner data
    _firstNameController = TextEditingController(text: widget.owner['firstName']);
    _lastNameController = TextEditingController(text: widget.owner['lastName']);
    _addressController = TextEditingController(text: widget.owner['address']);
    _dobController = TextEditingController(text: widget.owner['dateOfBirth']);
    _insuranceController = TextEditingController(text: widget.owner['insuranceNumber'] ?? '');
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

  /// Updates the pet owner's information in the database
  Future<void> _updateOwner() async {
    if (_formKey.currentState!.validate()) {

      // Create a map with the updated data
      final updatedOwner = {
        'id': widget.owner['id'],
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'address': _addressController.text,
        'dateOfBirth': _dobController.text,
        'insuranceNumber': _insuranceController.text,
      };

      // Save to database
      await DatabaseHelper.instance.updateOwner(updatedOwner);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet owner updated successfully!'),
            backgroundColor: Colors.teal,
          ),
        );
        // Go back and refresh the list
        Navigator.pop(context, true);
      }
    }
  }

  /// Deletes the pet owner from the database
  Future<void> _deleteOwner() async {
    // Show confirmation dialog before deleting
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: const Text('Are you sure you want to delete this pet owner?'),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          // Confirm delete button
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.deleteOwner(widget.owner['id']);
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Go back to list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pet owner deleted!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Owner Details'),
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

              // Update button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _updateOwner,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Update Customer',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Delete button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _deleteOwner,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Delete Customer',
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