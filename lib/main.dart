import 'package:flutter/material.dart';
import 'package:makanak/core/services/service_locator.dart';
import 'package:makanak/makanak_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setupServiceLocator();
  runApp(const MakanakApp());
}
