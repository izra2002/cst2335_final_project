import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'add_pet_owner_page.dart';
import 'pet_owner_detail_page.dart';

// This page is the main Pet Owner page.
// It shows a list of all pet owners stored in the database.
// On a phone it opens the detail page in a new screen.
// On a tablet it shows the list and detail side by side.
class PetOwnerPage extends StatefulWidget {
  const PetOwnerPage({super.key});

  @override
  State<PetOwnerPage> createState() => _PetOwnerPageState();
}

class _PetOwnerPageState extends State<PetOwnerPage> {

  // This list holds all the pet owners loaded from the database
  List<Map<String, dynamic>> _owners = [];

  // This holds the currently selected owner for the tablet layout
  Map<String, dynamic>? _selectedOwner;

  @override
  void initState() {
    super.initState();
    // Load owners from database when the page first opens
    _loadOwners();
  }

  // Gets all pet owners from the database and updates the list on screen
  Future<void> _loadOwners() async {
    final owners = await DatabaseHelper.instance.getAllOwners();
    setState(() {
      _owners = owners;
    });
  }

  // Checks if the screen is wide enough to be a tablet
  bool _isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  // Handles tapping an owner from the list
  Future<void> _onOwnerTapped(Map<String, dynamic> owner) async {
    if (_isTablet(context)) {
      // On tablet just update the selected owner on the right side
      setState(() {
        _selectedOwner = owner;
      });
    } else {
      // On phone navigate to a new full screen detail page
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PetOwnerDetailPage(owner: owner),
        ),
      );
      // Refresh list if something changed
      if (result == true) {
        _loadOwners();
      }
    }
  }

  // Builds the list of pet owners
  Widget _buildList() {
    return _owners.isEmpty
        ? const Center(
      child: Text(
        'No pet owners yet.\nPress + to add one.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    )
        : ListView.builder(
      itemCount: _owners.length,
      itemBuilder: (context, index) {
        final owner = _owners[index];
        return ListTile(
          leading: const Icon(Icons.person, color: Colors.teal),
          title: Text('${owner['firstName']} ${owner['lastName']}'),
          subtitle: Text(owner['address'] ?? ''),
          trailing: const Icon(Icons.chevron_right),
          // Highlight selected owner on tablet
          tileColor: _selectedOwner != null &&
              _selectedOwner!['id'] == owner['id']
              ? Colors.teal.withOpacity(0.1)
              : null,
          onTap: () => _onOwnerTapped(owner),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Owners'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          // Help button in the top right corner
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Show instructions dialog when help is pressed
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('How to use'),
                  content: const Text(
                    '1. Press the + button to add a new pet owner.\n\n'
                        '2. Tap a customer in the list to view or edit their details.\n\n'
                        '3. You can update or delete a customer from the details page.',
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

      // Check if tablet or phone and build the correct layout
      body: _isTablet(context)
          ? Row(
        children: [
          // Left side - the list takes up 1/3 of the screen
          Expanded(
            flex: 1,
            child: _buildList(),
          ),

          // Divider between list and detail
          const VerticalDivider(width: 1),

          // Right side - the detail page takes up 2/3 of the screen
          Expanded(
            flex: 2,
            child: _selectedOwner == null
                ? const Center(
              child: Text(
                'Select a pet owner to see details',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
                : PetOwnerDetailPage(owner: _selectedOwner!),
          ),
        ],
      )
      // Phone layout - just show the list
          : _buildList(),

      // + button to go to the Add Pet Owner page
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        onPressed: () async {
          // Wait for the add page to close
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPetOwnerPage()),
          );
          // If a new owner was added refresh the list
          if (result == true) {
            _loadOwners();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}