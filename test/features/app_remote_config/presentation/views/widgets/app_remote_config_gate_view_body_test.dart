import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makanak/features/app_remote_config/app_remote_config_strings.dart';
import 'package:makanak/features/app_remote_config/domain/entities/app_access_result.dart';
import 'package:makanak/features/app_remote_config/domain/repos/app_remote_config_repo.dart';
import 'package:makanak/features/app_remote_config/presentation/manager/app_remote_config_cubit/app_remote_config_cubit.dart';
import 'package:makanak/features/app_remote_config/presentation/manager/app_remote_config_cubit/app_remote_config_state.dart';
import 'package:makanak/features/app_remote_config/presentation/views/app_remote_config_gate_view.dart';

void main() {
  group('AppRemoteConfigGateView', () {
    late _TestAppRemoteConfigCubit cubit;

    setUp(() {
      cubit = _TestAppRemoteConfigCubit();
    });

    tearDown(() async {
      await cubit.close();
    });

    testWidgets('shows loading content before access is resolved', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildTestApp(cubit));

      expect(find.text(AppRemoteConfigStrings.loadingTitle), findsOneWidget);
      expect(find.text('home child'), findsNothing);
    });

    testWidgets('shows the app child when access is allowed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildTestApp(cubit));

      cubit.setResolved(const AppAccessResult.allowed());
      await tester.pump();

      expect(find.text('home child'), findsOneWidget);
      expect(find.text(AppRemoteConfigStrings.maintenanceTitle), findsNothing);
    });

    testWidgets('shows the maintenance blocker when access is blocked', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildTestApp(cubit));

      const maintenanceMessage = 'Maintenance mode is active.';
      cubit.setResolved(
        const AppAccessResult(
          status: AppAccessStatus.maintenance,
          message: maintenanceMessage,
        ),
      );
      await tester.pump();

      expect(
        find.text(AppRemoteConfigStrings.maintenanceTitle),
        findsOneWidget,
      );
      expect(find.text(maintenanceMessage), findsOneWidget);
      expect(find.text('home child'), findsNothing);
    });
  });
}

Widget _buildTestApp(AppRemoteConfigCubit cubit) {
  return BlocProvider<AppRemoteConfigCubit>.value(
    value: cubit,
    child: const MaterialApp(
      home: AppRemoteConfigGateView(child: Scaffold(body: Text('home child'))),
    ),
  );
}

class _TestAppRemoteConfigCubit extends AppRemoteConfigCubit {
  _TestAppRemoteConfigCubit() : super(_FakeAppRemoteConfigRepo());

  void setResolved(AppAccessResult result) {
    emit(AppRemoteConfigResolved(result));
  }
}

class _FakeAppRemoteConfigRepo implements AppRemoteConfigRepo {
  @override
  Future<AppAccessResult> checkAppAccess() async {
    return const AppAccessResult.allowed();
  }
}
