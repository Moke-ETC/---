import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/sales_provider.dart';
import 'screens/splash_screen.dart';

void main() => runApp(
  ChangeNotifierProvider(
    create: (_) => SalesProvider(),
    child: const MyApp(),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'የኢትዮጵያ ምግብ ሽያጭ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
