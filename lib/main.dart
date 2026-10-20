import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/couple_provider.dart';
import 'providers/bond_provider.dart';
import 'providers/memories_provider.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set edge-to-edge transparent system overlay for modern Android look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => CoupleProvider()),
        ChangeNotifierProvider(create: (_) => BondProvider()),
        ChangeNotifierProvider(create: (_) => MemoriesProvider()),
      ],
      child: const IgniteApp(),
    ),
  );
}

class IgniteApp extends StatelessWidget {
  const IgniteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isAfterDark = context.watch<AppProvider>().isAfterDark;

    return MaterialApp(
      title: 'IGNITE Couple Games',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.normalTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: isAfterDark ? ThemeMode.dark : ThemeMode.light,
      home: const MainScreen(),
    );
  }
}