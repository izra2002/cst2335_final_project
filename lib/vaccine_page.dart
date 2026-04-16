import 'package:flutter/material.dart';
import 'vaccine_database_helper.dart';
import 'add_vaccine_page.dart';
import 'vaccine_detail_page.dart';

/// This page displays all vaccines stored in the database.
///
/// It allows the user to:
/// - View all vaccines in a ListView
/// - Add a new vaccine
/// - Tap a vaccine to view/update/delete details
/// - View instructions through an AlertDialog
class VaccinePage extends StatefulWidget {

  /// Constructor for VaccinePage
  const VaccinePage({super.key});

  @override
  State<VaccinePage> createState() => _VaccinePageState();
}

class _VaccinePageState extends State<VaccinePage> {

  /// List that holds all vaccine records fetched from the database
  List<Map<String, dynamic>> vaccines = [];

  @override
  void initState() {
    super.initState();

    /// Load vaccines when the page is initialized
    _loadVaccines();
  }

  /// Fetches all vaccines from the database and updates the UI
  Future<void> _loadVaccines() async {
    final data = await VaccineDatabaseHelper.instance.getAllVaccines();

    /// Update state with fetched data
    setState(() {
      vaccines = data;
    });
  }

  /// Navigates to the Add Vaccine page
  ///
  /// After returning, reloads the list to reflect new data
  void _goToAddPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddVaccinePage()),
    );

    /// Refresh the list after adding a new vaccine
    _loadVaccines();
  }

  /// Navigates to the Vaccine Detail page
  ///
  /// [vaccine] is the selected vaccine data
  /// After returning, reloads the list to reflect updates/deletions
  void _goToDetail(Map<String, dynamic> vaccine) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VaccineDetailPage(vaccine: vaccine),
      ),
    );

    /// Refresh the list after update or delete
    _loadVaccines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// App bar with title and instructions button
      appBar: AppBar(
        title: const Text('Vaccines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),

            /// Displays instructions dialog when pressed
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Instructions'),
                  content: const Text(
                      'Add vaccines, tap to edit or delete them.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),

      /// Main body displaying either empty message or list of vaccines
      body: vaccines.isEmpty
          ? const Center(child: Text('No vaccines yet'))
          : ListView.builder(
        itemCount: vaccines.length,
        itemBuilder: (context, index) {

          /// Get vaccine at current index
          final vaccine = vaccines[index];

          return ListTile(
            title: Text(vaccine['name']),
            subtitle: Text('Dosage: ${vaccine['dosage']}'),

            /// Open detail page when tapped
            onTap: () => _goToDetail(vaccine),
          );
        },
      ),

      /// Floating button to add new vaccine
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddPage,
        child: const Icon(Icons.add),
      ),
    );
  }
}