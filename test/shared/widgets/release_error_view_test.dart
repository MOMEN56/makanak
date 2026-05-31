import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/shared/views/release_error_view.dart';

void main() {
  testWidgets('renders release error content and handles return action', (
    tester,
  ) async {
    var didTapReturnHome = false;

    await tester.pumpWidget(
      MaterialApp(
        home: ReleaseErrorView(onReturnHome: () => didTapReturnHome = true),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.text(AppStrings.releaseErrorTitle), findsOneWidget);
    expect(find.text(AppStrings.releaseErrorAction), findsOneWidget);

    await tester.tap(find.text(AppStrings.releaseErrorAction));
    await tester.pump();

    expect(didTapReturnHome, isTrue);
  });
}
