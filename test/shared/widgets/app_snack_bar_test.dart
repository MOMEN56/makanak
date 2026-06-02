import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makanak/shared/widgets/app_snack_bar.dart';

void main() {
  testWidgets('network snackbar is red and hides the badge', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
    );

    final context = tester.element(find.byType(Scaffold));
    AppSnackBar.showNetwork(
      context: context,
      message: 'تعذر الاتصال بالإنترنت',
    );

    await tester.pumpAndSettle();

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));

    expect(snackBar.backgroundColor, AppSnackBar.errorBackgroundColor);
    expect(find.text('تعذر الاتصال بالإنترنت'), findsOneWidget);
    expect(find.byType(InkWell), findsNothing);
  });
}