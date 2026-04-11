import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'veterinarian.dart';
import 'vet_database.dart';

/// The main landing page for the Veterinarian section.
class VeterinarianPage extends StatefulWidget {
  const VeterinarianPage({super.key});

  @override
  State<VeterinarianPage> createState() => _VeterinarianPageState();
}

class _VeterinarianPageState extends State<VeterinarianPage> {
  List<Veterinarian> _vets = [];
  Veterinarian? _selectedVet;
  bool _showForm = false;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _loadVets();
  }

  /// Loads all veterinarians from the database into [_vets].
  Future<void> _loadVets() async {
    final vets = await VetDatabase.instance.getAllVets();
    setState(() => _vets = vets);
  }

  void _openAddForm() {
    setState(() {
      _selectedVet = null;
      _isAdding = true;
      _showForm = true;
    });
  }

  void _openDetail(Veterinarian vet) {
    setState(() {
      _selectedVet = vet;
      _isAdding = false;
      _showForm = true;
    });
  }

  /// Shows the help AlertDialog with instructions.
  void _showHelp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('How to use this page'),
        content: const Text(
          '• Tap "Add Veterinarian" to add a new vet to the database.\n\n'
              '• Fill in the name, date of birth, home address, and the university where they graduated.\n\n'
              '• Tap any veterinarian in the list to view or edit their details.\n\n'
              '• Use the Update button to save changes, or the Delete button to remove them.\n\n'
              '• Your last entered details will be offered as a starting point next time you add a vet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Veterinarians'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: _showHelp,
          ),
        ],
      ),
      body: isWide ? _buildWideLayout() : _buildNarrowLayout(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isWide ? _openAddForm : () => _navigateToForm(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Add Veterinarian'),
      ),
    );
  }

  /// Builds a two-column layout for wide screens (tablet/desktop).
  Widget _buildWideLayout() {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: _buildVetList(onTap: _openDetail),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _showForm
              ? VetForm(
            key: ValueKey(_selectedVet?.id ?? 'new'),
            vet: _selectedVet,
            isAdding: _isAdding,
            onSaved: (message) {
              _loadVets();
              setState(() {
                _showForm = false;
                _selectedVet = null;
              });
              _showSnackbar(message);
            },
            onDeleted: () {
              _loadVets();
              setState(() {
                _showForm = false;
                _selectedVet = null;
              });
              _showSnackbar('Veterinarian removed.');
            },
          )
              : const Center(
            child: Text(
              'Select a veterinarian or tap "Add Veterinarian".',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a simple list layout for narrow screens (phone).
  Widget _buildNarrowLayout() {
    return _buildVetList(
      onTap: (vet) => _navigateToForm(context, vet),
    );
  }

  /// Builds the scrollable list of veterinarians.
  Widget _buildVetList({required Function(Veterinarian) onTap}) {
    if (_vets.isEmpty) {
      return const Center(
        child: Text('No veterinarians yet. Tap "Add Veterinarian" to begin.'),
      );
    }
    return ListView.builder(
      itemCount: _vets.length,
      itemBuilder: (context, index) {
        final vet = _vets[index];
        return ListTile(
          leading: const Icon(Icons.medical_services),
          title: Text(vet.name),
          subtitle: Text(vet.university),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onTap(vet),
        );
      },
    );
  }

  /// Navigates to the [VetForm] as a full screen (phone mode).
  Future<void> _navigateToForm(BuildContext context, Veterinarian? vet) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => VetFormPage(vet: vet),
      ),
    );
    if (result != null) {
      _loadVets();
      _showSnackbar(result);
    }
  }

  /// Shows a [SnackBar] with the given [message].
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

// ═══════════════════════════════════════════════
// VetFormPage — wraps VetForm for phone navigation
// ═══════════════════════════════════════════════

/// A full-screen page wrapping [VetForm] for use on narrow (phone) screens.
class VetFormPage extends StatelessWidget {
  final Veterinarian? vet;

  const VetFormPage({super.key, this.vet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(vet == null ? 'Add Veterinarian' : 'Veterinarian Details'),
      ),
      body: VetForm(
        vet: vet,
        isAdding: vet == null,
        onSaved: (message) => Navigator.pop(context, message),
        onDeleted: () => Navigator.pop(context, 'Veterinarian removed.'),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// VetForm — the shared add/edit/detail form
// ═══════════════════════════════════════════════

/// A form widget for adding, viewing, or editing a [Veterinarian].
class VetForm extends StatefulWidget {
  final Veterinarian? vet;
  final bool isAdding;
  final Function(String message) onSaved;
  final VoidCallback onDeleted;

  const VetForm({
    super.key,
    required this.vet,
    required this.isAdding,
    required this.onSaved,
    required this.onDeleted,
  });

  @override
  State<VetForm> createState() => _VetFormState();
}

class _VetFormState extends State<VetForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _birthdayController;
  late TextEditingController _addressController;
  late TextEditingController _universityController;

  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.vet?.name ?? '');
    _birthdayController = TextEditingController(text: widget.vet?.birthday ?? '');
    _addressController = TextEditingController(text: widget.vet?.address ?? '');
    _universityController = TextEditingController(text: widget.vet?.university ?? '');

    if (widget.isAdding) {
      _offerPreviousData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthdayController.dispose();
    _addressController.dispose();
    _universityController.dispose();
    super.dispose();
  }

  /// Saves the current form values to EncryptedSharedPreferences.
  Future<void> _saveToPrefs() async {
    await _prefs.setString('vet_name', _nameController.text);
    await _prefs.setString('vet_birthday', _birthdayController.text);
    await _prefs.setString('vet_address', _addressController.text);
    await _prefs.setString('vet_university', _universityController.text);
  }

  /// Loads previous values from EncryptedSharedPreferences.
  Future<Map<String, String>> _loadFromPrefs() async {
    return {
      'name': await _prefs.getString('vet_name') ?? '',
      'birthday': await _prefs.getString('vet_birthday') ?? '',
      'address': await _prefs.getString('vet_address') ?? '',
      'university': await _prefs.getString('vet_university') ?? '',
    };
  }

  /// If previous data exists, asks the user whether to pre-fill the form.
  Future<void> _offerPreviousData() async {
    final data = await _loadFromPrefs();
    if (data['name']!.isEmpty) return;

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Copy previous entry?'),
        content: Text(
          'Would you like to copy the details from the previously added veterinarian?\n\nName: ${data['name']}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Start blank'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _nameController.text = data['name']!;
                _birthdayController.text = data['birthday']!;
                _addressController.text = data['address']!;
                _universityController.text = data['university']!;
              });
            },
            child: const Text('Copy details'),
          ),
        ],
      ),
    );
  }

  /// Validates the form and saves or updates the veterinarian.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await _saveToPrefs();

    final vet = Veterinarian(
      id: widget.vet?.id,
      name: _nameController.text.trim(),
      birthday: _birthdayController.text.trim(),
      address: _addressController.text.trim(),
      university: _universityController.text.trim(),
    );

    if (widget.isAdding) {
      await VetDatabase.instance.insertVet(vet);
      widget.onSaved('Veterinarian added successfully.');
    } else {
      await VetDatabase.instance.updateVet(vet);
      widget.onSaved('Veterinarian updated successfully.');
    }
  }

  /// Shows a confirmation dialog, then deletes the veterinarian.
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove veterinarian?'),
        content: Text(
          'Are you sure you want to remove ${widget.vet!.name} from the system? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await VetDatabase.instance.deleteVet(widget.vet!.id!);
      widget.onDeleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.isAdding ? 'New Veterinarian' : 'Veterinarian Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Please enter a name.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _birthdayController,
              decoration: const InputDecoration(
                labelText: 'Date of Birth (YYYY-MM-DD)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
              ),
              keyboardType: TextInputType.datetime,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a date of birth.';
                }
                final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                if (!regex.hasMatch(value.trim())) {
                  return 'Please use the format YYYY-MM-DD.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Home Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
                hintText: 'e.g. 12 Maple Avenue, London',
              ),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Please enter an address.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _universityController,
              decoration: const InputDecoration(
                labelText: 'University Attended',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) =>
              value == null || value.trim().isEmpty
                  ? 'Please enter the university name.'
                  : null,
            ),
            const SizedBox(height: 28),
            if (widget.isAdding)
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save),
                label: const Text('Add Veterinarian'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              )
            else ...[
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save),
                label: const Text('Update'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _confirmDelete,
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Delete', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}