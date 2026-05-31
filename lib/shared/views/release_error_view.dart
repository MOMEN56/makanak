import 'package:flutter/material.dart';
import 'package:makanak/shared/widgets/release_error_view_body.dart';

class ReleaseErrorView extends StatelessWidget {
  const ReleaseErrorView({super.key, required this.onReturnHome});

  final VoidCallback onReturnHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ReleaseErrorViewBody(onReturnHome: onReturnHome),
    );
  }
}
