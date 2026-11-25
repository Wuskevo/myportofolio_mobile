import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/item_card.dart';
import 'package:provider/provider.dart';

class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  ItemHomepage(this.name, this.icon, this.color);
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final String npm = "2506632892";
  final String nama = "Clement Kevin Tanadi";
  final String kelas = "PBP B";

  final List<ItemHomepage> items = [
    ItemHomepage("View Projects", Icons.folder, Colors.blue),
    ItemHomepage("View Experiences", Icons.calendar_month, Colors.blue),
    ItemHomepage("View Credentials", Icons.workspace_premium, Colors.blue),
    ItemHomepage("Add Project", Icons.add_circle, Colors.green),

    ItemHomepage("Add Experience", Icons.add_circle, Colors.green),

    ItemHomepage("Add Credential", Icons.add_circle, Colors.green),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            tooltip: 'Logout',
            color: Colors.white,
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final auth = context.read<AuthState>();
              final messenger = ScaffoldMessenger.of(context);
              if (!auth.isLoggedIn) {
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(content: Text('You are not logged in.')),
                  );
                return;
              }
              await auth.logout();
              if (!context.mounted) return;
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text('Logged out')));
            },
          ),
        ],
      ),
      drawer: const LeftDrawer(), // drawer
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InfoCard(title: 'NPM', content: npm),
                  InfoCard(title: 'Name', content: nama),
                  InfoCard(title: 'Class', content: kelas),
                ],
              ),
              const SizedBox(height: 16.0),
              Center(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Welcome to MyPortfolio Mobile!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    GridView.count(
                      primary: true,
                      padding: const EdgeInsets.all(20),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      children: items.map((ItemHomepage item) {
                        return ItemCard(item);
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Container(
        width: MediaQuery.of(context).size.width / 3.5,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text(content),
          ],
        ),
      ),
    );
  }
}
