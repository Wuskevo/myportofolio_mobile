import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class DeleteItemAction extends StatefulWidget {
  const DeleteItemAction({
    required this.itemName,
    required this.onDelete,
    super.key,
  });

  final String itemName;
  final Future<void> Function(String token)? onDelete;

  @override
  State<DeleteItemAction> createState() => _DeleteItemActionState();
}

class _DeleteItemActionState extends State<DeleteItemAction> {
  bool _isDeleting = false;

  Future<void> _confirmAndDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete "${widget.itemName}"?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;

    final authState = context.read<AuthState>();
    final token = authState.token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in before deleting items.')),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _isDeleting = true;
    });

    try {
      await widget.onDelete!(token);
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401) {
        var message = 'Session expired. Please log in again.';
        try {
          await authState.logout();
        } catch (logoutError) {
          message = 'Session expired; logout request failed: $logoutError';
        }
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(content: Text(message)));
        await ensureLoggedIn(context);
      } else if (error.statusCode == 403) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('You do not have permission to delete this item.'),
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete item (status ${error.statusCode}).',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Could not reach the server: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canDelete = widget.onDelete != null;
    return IconButton(
      tooltip: canDelete ? 'Delete item' : 'Cannot delete item without an ID',
      onPressed: !canDelete || _isDeleting ? null : _confirmAndDelete,
      icon: _isDeleting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.delete_outline),
    );
  }
}
