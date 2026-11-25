import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/screens/experience_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormState();
}

class _ExperienceFormState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  // value sent to the API -> label shown to the user
  static const Map<String, String> _categories = {
    'internship': 'Internship',
    'research': 'Research',
    'volunteer': 'Volunteer',
    'part-time': 'Part-Time',
    'full-time': 'Full-Time',
    'freelance': 'Freelance',
  };

  String _title = '';
  String _description = '';
  String _category = 'internship';
  String _thumbnailUrl = '';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isSubmitting = false;

  String _fmt(DateTime d) => d.toIso8601String().split('T').first;

  bool _isValidHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2007),
      lastDate: DateTime(2126),
    );
    if (picked == null) return;
    setState(() {
      _startDate = picked;
      final end = _endDate;
      if (end != null && end.isBefore(picked)) _endDate = null;
    });
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2126),
    );
    if (picked == null) return;
    setState(() {
      _endDate = picked;
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
      await apiClient.createExperience(
        Experience(
          title: _title.trim(),
          description: _description.trim(),
          category: _category,
          startedAt: _startDate,
          endedAt: _endDate,
          thumbnail: _thumbnailUrl.trim(),
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
        title: const Text('Experience added successfully!'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Title: $_title'),
              Text('Category: ${_categories[_category]}'),
              Text('Started: ${_fmt(_startDate)}'),
              Text('Ended: ${_endDate == null ? 'Ongoing' : _fmt(_endDate!)}'),
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
        MaterialPageRoute(builder: (_) => const ExperienceListScreen()),
      );
      return;
    }
    _formKey.currentState!.reset();
    setState(() {
      _title = '';
      _description = '';
      _category = 'internship';
      _thumbnailUrl = '';
      _startDate = DateTime.now();
      _endDate = null;
    });
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
        title: const Center(child: Text('Add Experience Form')),
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
                  decoration: InputDecoration(
                    hintText: 'Experience Title',
                    labelText: 'Experience Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onChanged: (value) => _title = value,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter an experience title.'
                      : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Experience Description',
                    labelText: 'Experience Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onChanged: (value) => _description = value,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter an experience description.'
                      : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Experience Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
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
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    hintText: 'https://example.com/image.png',
                    labelText: 'Thumbnail URL (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onChanged: (value) => _thumbnailUrl = value,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return null;
                    return _isValidHttpUrl(text)
                        ? null
                        : 'Enter a valid URL (http:// or https://).';
                  },
                ),
              ),
              _dateTile(
                label: 'Start date',
                value: _fmt(_startDate),
                onTap: _pickStartDate,
              ),
              _dateTile(
                label: 'End date (optional)',
                value: _endDate == null ? 'Ongoing / not set' : _fmt(_endDate!),
                onTap: _pickEndDate,
                trailing: _endDate == null
                    ? const Icon(Icons.calendar_today)
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _endDate = null),
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
