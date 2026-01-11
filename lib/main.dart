import 'package:flutter/material.dart';
import 'splash_page.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'students_page.dart';
import 'pending_registrations_page.dart';
import 'student_detail_page.dart'; // pour les routes nommées

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      // première page
      home: const SplashPage(),

      // routes optionnelles si tu veux les appeler par nom
      routes: {
        '/login': (context) => LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/students': (context) => const StudentsPage(),
        '/pending': (context) => const PendingRegistrationsPage(),
        // StudentDetailPage reste avec MaterialPageRoute + objet Student
      },
    );
  }
}
