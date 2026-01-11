import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'pending_registrations_page.dart';
import 'students_page.dart';
import 'teachers_page.dart';
import 'schedules_files_page.dart';
import 'manage_groups_page.dart';
import 'manage_courses_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool loading = true;
  String? error;

  int teachers = 0;
  int students = 0;
  int pendingStudents = 0;

  @override
  void initState() {
    super.initState();
    fetchDashboardCounts();
  }

  Future<void> fetchDashboardCounts() async {
    final url = Uri.parse(
      'http://192.168.1.13/campus_connect_api/get_dashboard_counts.php',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            loading = false;
            error = null;
            teachers = data['teachers'] ?? 0;
            students = data['students'] ?? 0;
            pendingStudents = data['pending_students'] ?? 0;
          });
        } else {
             // Fallback if keys missing
             setState(() { loading = false; });
        }
      } else {
        setState(() {
          loading = false;
          error = 'HTTP error ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2F5F),
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D2F5F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               if (loading) const Center(child: CircularProgressIndicator(color: Colors.white)),
               if (error != null) Text('Error loading stats: $error', style: const TextStyle(color: Colors.redAccent)),
               
               const SizedBox(height: 10),
               
               Expanded(
                 child: GridView.count(
                   crossAxisCount: 2,
                   mainAxisSpacing: 12,
                   crossAxisSpacing: 12,
                   childAspectRatio: 1.1,
                   children: [
                      _buildCard(
                        icon: Icons.person_outline,
                        title: 'Teachers',
                        value: '$teachers',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeachersPage())),
                      ),
                      _buildCard(
                        icon: Icons.school_outlined,
                        title: 'Students',
                        value: '$students',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentsPage())),
                      ),
                      _buildCard(
                        icon: Icons.how_to_reg,
                        title: 'Pending',
                        value: '$pendingStudents',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PendingRegistrationsPage())),
                      ),
                      _buildCard(
                        icon: Icons.groups,
                        title: 'Groups',
                        value: 'Manage',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageGroupsPage())),
                      ),
                      _buildCard(
                        icon: Icons.book,
                        title: 'Courses',
                        value: 'Manage',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageCoursesPage())),
                      ),
                      _buildCard(
                        icon: Icons.calendar_today,
                        title: 'Timetables',
                        value: 'Update',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SchedulesFilesPage())),
                      ),
                   ],
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required IconData icon, required String title, required String value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0,2))],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF0D2F5F)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
