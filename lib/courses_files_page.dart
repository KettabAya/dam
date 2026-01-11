import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CoursesFilesPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const CoursesFilesPage({super.key, required this.user});

  @override
  State<CoursesFilesPage> createState() => _CoursesFilesPageState();
}

class _CoursesFilesPageState extends State<CoursesFilesPage> {
  List<dynamic> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
         Uri.parse('http://192.168.1.13/campus_connect_api/student_courses.php'),
         body: {'student_id': widget.user['id'].toString()}
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _courses = data['courses'] ?? [];
          });
        }
      }
    } catch (e) {
      print("Error fetching courses: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('My Courses'), backgroundColor: const Color(0xFFF5F7FB)),
      body: _isLoading 
         ? const Center(child: CircularProgressIndicator()) 
         : _courses.isEmpty
            ? const Center(child: Text("No courses assigned to your group."))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  final course = _courses[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                         padding: const EdgeInsets.all(10),
                         decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(12)),
                         child: const Icon(Icons.book, color: Colors.purple),
                      ),
                      title: Text(course['name'] ?? 'Course'),
                      subtitle: Text('${course['code']} • ${course['teacher_name'] ?? 'Unknown Teacher'}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                         // Optional: Show files for this course (reuse Teacher upload list? Logic needed)
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course Files detail not linked yet.')));
                      },
                    ),
                  );
                },
              ),
    );
  }
}
