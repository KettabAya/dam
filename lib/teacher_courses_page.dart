import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'manage_marks_page.dart';

class TeacherCoursesPage extends StatefulWidget {
  final String teacherId;
  const TeacherCoursesPage({super.key, required this.teacherId});

  @override
  State<TeacherCoursesPage> createState() => _TeacherCoursesPageState();
}

class _TeacherCoursesPageState extends State<TeacherCoursesPage> {
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
      // Assuming teacher_courses.php?teacher_id=... exists
      final response = await http.post(
         Uri.parse('http://192.168.1.13/campus_connect_api/teacher_courses.php'),
         body: {'teacher_id': widget.teacherId}
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
      appBar: AppBar(
        title: const Text('My Courses'),
        backgroundColor: const Color(0xFF0D2F5F),
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : _courses.isEmpty 
           ? const Center(child: Text("No courses assigned."))
           : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course['name'] ?? 'Course Name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('${course['code']} • Group: ${course['group_name'] ?? 'N/A'}', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                 // Upload File Logic (simplified)
                                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File upload not implemented yet')));
                              },
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Files'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D2F5F), foregroundColor: Colors.white),
                              onPressed: () {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(
                                    builder: (_) => ManageMarksPage(
                                      courseId: course['id'].toString(), 
                                      courseName: course['name'] ?? 'Course'
                                    )
                                  )
                                );
                              },
                              icon: const Icon(Icons.grade),
                              label: const Text('Marks'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
