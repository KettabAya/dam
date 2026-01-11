import 'package:flutter/material.dart';
import 'splash_page.dart';
import 'teacher_courses_page.dart';

class TeacherHomePage extends StatelessWidget {
  final Map<String, dynamic> user;

  const TeacherHomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2F5F),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const Text('Teacher Portal', style: TextStyle(fontSize: 14, color: Colors.white70)),
             Text('Hello, ${user['name'] ?? 'Teacher'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SplashPage())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActionCard(
              context,
              title: 'My Courses',
              subtitle: 'Manage marks & files',
              icon: Icons.class_,
              color: Colors.blueAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TeacherCoursesPage(teacherId: user['id'].toString())),
                );
              },
            ),
            const SizedBox(height: 16),
             _buildActionCard(
              context,
              title: 'Schedule',
              subtitle: 'Check your timetable',
              icon: Icons.calendar_today,
              color: Colors.orangeAccent,
              onTap: () {
                // Future: Implement Teacher Schedule
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Timetable feature coming soon')));
              },
            ),
             const SizedBox(height: 16),
            _buildActionCard(
              context,
              title: 'Profile',
              subtitle: 'View personal info',
              icon: Icons.person,
              color: Colors.purpleAccent,
              onTap: () {
                  // Future: Profile
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
