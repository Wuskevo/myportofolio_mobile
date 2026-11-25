import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/credential.dart';

class CredentialDetailScreen extends StatelessWidget {
  const CredentialDetailScreen({required this.credential, super.key});

  final Credential credential;

  @override
  Widget build(BuildContext context) {
    String period =
        '${credential.dateReceived.toString()} - ${(credential.expiryDate?.toString() ?? "-")}';

    return Scaffold(
      appBar: AppBar(title: Text(credential.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((credential.image ?? '').isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  credential.image!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => SizedBox(
                    height: 120,
                    child: Center(child: Icon(Icons.broken_image, size: 48)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              credential.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _InfoRow(label: 'Description', value: credential.description),
            _InfoRow(label: 'Category', value: credential.category),
            _InfoRow(label: 'Issuer', value: credential.issuer),
            _InfoRow(label: 'Validity', value: period),
            _InfoRow(label: 'Credential URL', value: credential.credentialUrl),
            _InfoRow(
              label: 'Credential Image URL',
              value: credential.image ?? "-",
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 4),
          SelectableText(value),
        ],
      ),
    );
  }
}
