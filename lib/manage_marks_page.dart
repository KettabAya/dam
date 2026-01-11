import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ManageMarksPage extends StatefulWidget {
  final String courseId;
  final String courseName;
  const ManageMarksPage({super.key, required this.courseId, required this.courseName});

  @override
  State<ManageMarksPage> createState() => _ManageMarksPageState();
}

class _ManageMarksPageState extends State<ManageMarksPage> {
  List<dynamic> _students = [];
  bool _isLoading = true;
  // Map to store controllers for each student ID
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
         Uri.parse('http://192.168.1.13/campus_connect_api/course_students.php'),
         body: {'course_id': widget.courseId}
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _students = data['students'] ?? [];
            for (var s in _students) {
              _controllers[s['id'].toString()] = TextEditingController(text: s['mark']?.toString() ?? '');
            }
          });
        }
      }
    } catch (e) {
      print("Error fetching students: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAllMarks() async {
    // Collect all marks
    List<Map<String, dynamic>> marksData = [];
    _controllers.forEach((studentId, controller) {
      if (controller.text.isNotEmpty) {
        marksData.add({
          'student_id': studentId,
          'value': controller.text
        });
      }
    });

    if (marksData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No marks to save")));
        return;
    }

    try {
      // Sending one by one or batch. Let's do batch if PHP supports it, otherwise one by one.
      // User asked for "simple pattern", so maybe one by one loop is safer if backend is simple.
      // But let's try sending JSON encoded list.
      
      final response = await http.post(
         Uri.parse('http://192.168.1.13/campus_connect_api/save_marks_batch.php'),
         body: {
           'course_id': widget.courseId,
           'marks': jsonEncode(marksData)
         }
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All Marks Saved Successfully")));
        } else {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${data['message']}")));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.courseName, style: const TextStyle(fontSize: 16)),
            // Group name would ideally come from previous screen or API, assuming we have it.
            // For now, simpler to show just course name as req.
          ],
        ),
        backgroundColor: const Color(0xFF0D2F5F),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? const Center(child: Text("No students found."))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("Grading Students", style: Theme.of(context).textTheme.titleLarge),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          final id = student['id'].toString();
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  CircleAvatar(child: Text(student['name']?[0] ?? 'S')),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(student['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(id, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: _controllers[id],
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        hintText: '0-20',
                                        isDense: true,
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D2F5F),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: Colors.white
                        ),
                        onPressed: _saveAllMarks, 
                        child: const Text("SAVE ALL MARKS")
                      ),
                    )
                  ],
                ),
    );
  }
}
