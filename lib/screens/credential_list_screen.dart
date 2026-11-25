import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/credential.dart';
import 'package:myportofolio_mobile/screens/credential_detail_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class CredentialListScreen extends StatefulWidget {
  const CredentialListScreen({super.key});

  @override
  State<CredentialListScreen> createState() => _CredentialListScreenState();
}

class _CredentialListScreenState extends State<CredentialListScreen> {
  late Future<List<Credential>> _credentialsFuture;

  @override
  void initState() {
    super.initState();
    _credentialsFuture = context.read<ApiClient>().getCredentials();
  }

  Future<void> _reload() async {
    final future = context.read<ApiClient>().getCredentials();
    setState(() {
      _credentialsFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements: Credentials')),
      drawer: const LeftDrawer(),
      body: FutureBuilder<List<Credential>>(
        future: _credentialsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Failed to load credentials: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final credentials = snapshot.data ?? const <Credential>[];
          if (credentials.isEmpty) {
            return RefreshIndicator(
              onRefresh: _reload,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: const Center(child: Text('No credentials found.')),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              itemCount: credentials.length,
              itemBuilder: (context, index) {
                final credential = credentials[index];
                return Card(
                  child: ListTile(
                    title: Text(credential.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          credential.category,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          credential.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CredentialDetailScreen(credential: credential),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
