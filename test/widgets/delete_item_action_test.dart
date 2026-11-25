import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/delete_item_action.dart';

void main() {
  testWidgets('canceling confirmation does not delete the item', (
    tester,
  ) async {
    var deleteCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              DeleteItemAction(
                itemName: 'Portfolio project',
                onDelete: (_) async {
                  deleteCalls++;
                },
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Delete item'));
    await tester.pumpAndSettle();
    expect(find.text('Delete "Portfolio project"?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(deleteCalls, 0);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('disables delete when the item has no ID', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              const DeleteItemAction(
                itemName: 'Portfolio project',
                onDelete: null,
              ),
            ],
          ),
        ),
      ),
    );

    final deleteButton = tester.widget<IconButton>(
      find.byWidgetPredicate(
        (widget) =>
            widget is IconButton &&
            widget.tooltip == 'Cannot delete item without an ID',
      ),
    );
    expect(deleteButton.onPressed, isNull);
  });
}
