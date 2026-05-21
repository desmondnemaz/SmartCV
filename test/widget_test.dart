import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:smartcv_builder/features/editor/presentation/providers/cv_provider.dart';
import 'package:smartcv_builder/features/cover_letter/presentation/providers/cover_letter_provider.dart';
import 'package:smartcv_builder/features/settings/presentation/providers/theme_provider.dart';
import 'package:smartcv_builder/main.dart';

void main() {
  setUp(() async {
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    await Hive.openBox('cv_storage');
  });

  testWidgets('App starts and displays dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CVProvider()),
          ChangeNotifierProvider(create: (_) => CoverLetterProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.byType(MyApp), findsOneWidget);
  });
}
