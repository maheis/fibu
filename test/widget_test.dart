// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

import 'package:fibu/app.dart';
import 'package:fibu/app_controller.dart';
import 'package:fibu/repository/app_repository.dart';

void main() {
  testWidgets('Fibu app loads the overview page', (WidgetTester tester) async {
    final database = await databaseFactoryMemory.openDatabase('fibu_test.db');
    final controller = AppController(LocalAppRepository(database));
    await controller.load();

    await tester.pumpWidget(FibuApp(controller: controller));

    expect(find.text('Fibu'), findsOneWidget);
    expect(find.text('Gesamtguthaben'), findsOneWidget);
  });
}
