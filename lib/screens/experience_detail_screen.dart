import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';

class ExperienceDetailScreen extends StatelessWidget {
  const ExperienceDetailScreen({required this.experience, super.key});

  final Experience experience;

  @override
  Widget build(BuildContext context) {
    String period = '${experience.startedAt.toString()} - ${(experience.endedAt?.toString() ?? "-")}'; 

    return Scaffold(
      appBar: AppBar(title: Text(experience.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (experience.thumbnail.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  experience.thumbnail,
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
              experience.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _InfoRow(label: 'Description', value: experience.description),
            _InfoRow(label: 'Category', value: experience.category),
            _InfoRow(label: 'Period', value: period),
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
