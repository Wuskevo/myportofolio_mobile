import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/credential.dart';
import 'package:myportofolio_mobile/screens/credential_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class CredentialFormPage extends StatefulWidget {
  const CredentialFormPage({super.key});

  @override
  State<CredentialFormPage> createState() => _CredentialFormState();
}

class _CredentialFormState extends State<CredentialFormPage> {
  final _formKey = GlobalKey<FormState>();

  // value sent to the API -> label shown to the user
  static const Map<String, String> _categories = {
    'certification': 'Certification',
    'award': 'Award',
    'competition': 'Competition',
    'scholarship': 'Scholarship',
  };

  String _title = '';
  String _description = '';
  String _category = 'certification';
  String _issuer = '';
  DateTime _dateReceived = DateTime.now();
  DateTime? _expiryDate;
  String _credentialUrl = '';
  bool _isSubmitting = false;

  String _fmt(DateTime d) => d.toIso8601String().split('T').first;

  bool _isValidHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Future<void> _pickDateReceived() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateReceived,
      firstDate: DateTime(2007),
      lastDate: DateTime(2126),
    );
    if (picked == null) return;
    setState(() {
      _dateReceived = picked;
      final expiry = _expiryDate;
      if (expiry != null && expiry.isBefore(picked)) _expiryDate = null;
    });
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? _dateReceived,
      firstDate: _dateReceived,
      lastDate: DateTime(2126),
    );
    if (picked == null) return;
    setState(() {
      _expiryDate = picked;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ensureLoggedIn(context);
    if (!ok || !mounted) return;

    final apiClient = context.read<ApiClient>();
    final authState = context.read<AuthState>();
    final token = authState.token;
    if (token == null) return;
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isSubmitting = true;
    });

    try {
      await apiClient.createCredential(
        Credential(
          title: _title.trim(),
          description: _description.trim(),
          category: _category,
          issuer: _issuer.trim(),
          dateReceived: _dateReceived,
          expiryDate: _expiryDate,
          credentialUrl: _credentialUrl.trim(),
        ),
        token: token,
      );
      if (!mounted) return;
      await _showSuccessDialog();
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await authState.logout();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
          ),
        );
        if (!mounted) return;
        await ensureLoggedIn(context);
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to save (status ${e.statusCode}).')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not reach the server: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    final viewList = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Credential added successfully!'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Title: $_title'),
              Text('Category: ${_categories[_category]}'),
              Text('Issuer: $_issuer'),
              Text('Received: ${_fmt(_dateReceived)}'),
              Text(
                'Expires: ${_expiryDate == null ? 'No expiry' : _fmt(_expiryDate!)}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Add another'),
            onPressed: () => Navigator.pop(dialogContext, false),
          ),
          TextButton(
            child: const Text('View list'),
            onPressed: () => Navigator.pop(dialogContext, true),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (viewList ?? false) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CredentialListScreen()),
      );
      return;
    }
    _formKey.currentState!.reset();
    setState(() {
      _title = '';
      _description = '';
      _category = 'certification';
      _issuer = '';
      _credentialUrl = '';
      _dateReceived = DateTime.now();
      _expiryDate = null;
    });
  }

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint ?? label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
    );
  }

  Widget _dateTile({
    required String label,
    required String value,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListTile(
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        title: Text(label),
        subtitle: Text(value),
        trailing: trailing ?? const Icon(Icons.calendar_today),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Credential Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  decoration: _decoration('Credential Title'),
                  onChanged: (value) => _title = value,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a credential title.'
                      : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  maxLines: 5,
                  decoration: _decoration('Credential Description'),
                  onChanged: (value) => _description = value,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a credential description.'
                      : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: DropdownButtonFormField<String>(
                  decoration: _decoration('Credential Category'),
                  initialValue: _category,
                  items: _categories.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) _category = value;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  decoration: _decoration(
                    'Issuer',
                    hint: 'Organization or event',
                  ),
                  onChanged: (value) => _issuer = value,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter the issuer.'
                      : null,
                ),
              ),
              _dateTile(
                label: 'Date received',
                value: _fmt(_dateReceived),
                onTap: _pickDateReceived,
              ),
              _dateTile(
                label: 'Expiry date (optional)',
                value: _expiryDate == null ? 'No expiry' : _fmt(_expiryDate!),
                onTap: _pickExpiryDate,
                trailing: _expiryDate == null
                    ? const Icon(Icons.calendar_today)
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _expiryDate = null),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  keyboardType: TextInputType.url,
                  decoration: _decoration(
                    'Credential URL (Optional)',
                    hint: 'https://example.com/verify',
                  ),
                  onChanged: (value) => _credentialUrl = value,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return null;
                    return _isValidHttpUrl(text)
                        ? null
                        : 'Enter a valid URL (http:// or https://).';
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
