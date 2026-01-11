import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AttendancePage extends StatefulWidget {
  final String courseId;
  const AttendancePage({super.key, required this.courseId});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<dynamic> _students = [];
  bool _isLoading = true;
  final Map<String, bool> _presence = {};

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
              _presence[s['id'].toString()] = false; // Default absent
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

  Future<void> _saveAttendance() async {
      // Logic to save attendance
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Attendance Saved (Mock)")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance"), backgroundColor: const Color(0xFF0D2F5F), foregroundColor: Colors.white),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Mark Presence for Week 1", style: Theme.of(context).textTheme.titleMedium),
          ),
          Expanded(
            child: _isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                final id = student['id'].toString();
                return CheckboxListTile(
                  title: Text(student['name'] ?? ''),
                  value: _presence[id],
                  onChanged: (val) {
                    setState(() {
                      _presence[id] = val ?? false;
                    });
                  },
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(onPressed: _saveAttendance, child: const Text("SAVE ATTENDANCE")),
          )
        ],
      )
    );
  }
}
