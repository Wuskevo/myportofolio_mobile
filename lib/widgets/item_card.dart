import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/credential_form_screen.dart';
import 'package:myportofolio_mobile/screens/credential_list_screen.dart';
import 'package:myportofolio_mobile/screens/experience_list_screen.dart';
import 'package:myportofolio_mobile/screens/experience_form_screen.dart';
import 'package:myportofolio_mobile/screens/project_form_screen.dart';
import 'package:myportofolio_mobile/screens/home_page_screen.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () async {
          switch (item.name) {
            case ('View Projects'):
              Navigator.pop(context); // closes the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectListScreen(),
                ),
              );
            case ('Add Project'):
              final bool ok = await ensureLoggedIn(context);
              if (!ok || !context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProjectFormPage()),
              );
            case 'View Experiences':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExperienceListScreen()),
              );
            case 'Add Experience':
              final bool ok = await ensureLoggedIn(context);
              if (!ok || !context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExperienceFormPage()),
              );
            case 'View Credentials':
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CredentialListScreen()),
              );
            case 'Add Credential':
              final bool ok = await ensureLoggedIn(context);
              if (!ok || !context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CredentialFormPage()),
              );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 30.0),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
