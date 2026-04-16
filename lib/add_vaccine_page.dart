import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'vaccine_database_helper.dart';

/// This page lets the user add a new vaccine to the database.
///
/// It includes:
/// - TextFields for vaccine information
/// - Validation to make sure all fields are filled
/// - Snackbar messages
/// - AlertDialog asking whether to copy the previous vaccine data
/// - EncryptedSharedPreferences to save the last entered vaccine
class AddVaccinePage extends StatefulWidget {
  /// Creates the Add Vaccine page.
  const AddVaccinePage({super.key});

  @override
  State<AddVaccinePage> createState() => _AddVaccinePageState();
}

class _AddVaccinePageState extends State<AddVaccinePage> {
  /// Controller for the vaccine name field.
  final TextEditingController _nameController = TextEditingController();

  /// Controller for the dosage field.
  final TextEditingController _dosageController = TextEditingController();

  /// Controller for the lot number field.
  final TextEditingController _lotController = TextEditingController();

  /// Controller for the expiration date field.
  final TextEditingController _dateController = TextEditingController();

  /// Used to save and read encrypted shared preference values.
  final EncryptedSharedPreferences encryptedPrefs =
  EncryptedSharedPreferences();

  @override
  void initState() {
    super.initState();

    /// After the page is built, ask the user if they want to copy
    /// the previous vaccine entry.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _askCopyPrevious();
    });
  }

  /// Shows an AlertDialog asking whether the user wants to copy
  /// the previous vaccine information.
  ///
  /// If the user presses "Yes", the saved values are loaded from
  /// EncryptedSharedPreferences and placed into the TextFields.
  Future<void> _askCopyPrevious() async {
    bool? copy = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Copy Previous?"),
        content: const Text("Do you want to copy the previous vaccine data?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    /// Only continue if the user chose "Yes".
    if (copy == true) {
      try {
        _nameController.text = await encryptedPrefs.getString("name") ?? "";
        _dosageController.text =
            await encryptedPrefs.getString("dosage") ?? "";
        _lotController.text = await encryptedPrefs.getString("lot") ?? "";
        _dateController.text = await encryptedPrefs.getString("date") ?? "";

        /// Refresh the UI after filling the controllers.
        setState(() {});
      } catch (e) {
        /// On Windows desktop, encrypted shared preferences may fail.
        /// We catch the error so the page still works.
        debugPrint("EncryptedSharedPreferences read error: $e");
      }
    }
  }

  /// Validates the fields, inserts the vaccine into the database,
  /// saves the last entered values into encrypted preferences,
  /// shows a Snackbar, then returns to the previous page.
  Future<void> _saveVaccine() async {
    /// Make sure all fields have values before saving.
    if (_nameController.text.isEmpty ||
        _dosageController.text.isEmpty ||
        _lotController.text.isEmpty ||
        _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    /// Create a map containing the vaccine data to insert into the database.
    final Map<String, dynamic> vaccine = {
      'name': _nameController.text,
      'dosage': _dosageController.text,
      'lotNumber': _lotController.text,
      'expirationDate': _dateController.text,
    };

    /// Insert the vaccine into the vaccines table.
    await VaccineDatabaseHelper.instance.insertVaccine(vaccine);

    /// Save the latest vaccine information so it can be copied later.
    ///
    /// Wrapped in try/catch because encrypted shared preferences may not
    /// fully work on Windows desktop during testing.
    try {
      await encryptedPrefs.setString("name", _nameController.text);
      await encryptedPrefs.setString("dosage", _dosageController.text);
      await encryptedPrefs.setString("lot", _lotController.text);
      await encryptedPrefs.setString("date", _dateController.text);
    } catch (e) {
      debugPrint("EncryptedSharedPreferences write error: $e");
    }

    /// Avoid using context if the widget is no longer mounted.
    if (!mounted) return;

    /// Show success message.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vaccine added")),
    );

    /// Return to the vaccine list page.
    Navigator.pop(context);
  }

  @override
  void dispose() {
    /// Dispose controllers to free memory.
    _nameController.dispose();
    _dosageController.dispose();
    _lotController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Top app bar for this page.
      appBar: AppBar(
        title: const Text("Add Vaccine"),
      ),

      /// Main form area.
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Vaccine name input field.
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
              ),
            ),

            /// Dosage input field.
            TextField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: "Dosage",
              ),
            ),

            /// Lot number input field.
            TextField(
              controller: _lotController,
              decoration: const InputDecoration(
                labelText: "Lot Number",
              ),
            ),

            /// Expiration date input field.
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: "Expiration Date",
              ),
            ),

            /// Space before the save button.
            const SizedBox(height: 20),

            /// Button to save the vaccine data.
            ElevatedButton(
              onPressed: _saveVaccine,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}