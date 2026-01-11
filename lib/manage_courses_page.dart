import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ManageCoursesPage extends StatefulWidget {
  const ManageCoursesPage({super.key});

  @override
  State<ManageCoursesPage> createState() => _ManageCoursesPageState();
}

class _ManageCoursesPageState extends State<ManageCoursesPage> {
  // CORRECT BACKEND URLs
  final String _fetchCoursesUrl = 'http://192.168.1.13/campus_connect_api/manage_courses.php';
  // Using existing admin/teacher management files
  final String _fetchTeachersUrl = 'http://192.168.1.13/campus_connect_api/get_approved_teachers.php';
  final String _fetchGroupsUrl = 'http://192.168.1.13/campus_connect_api/manage_groups.php';
  // New assignment script
  final String _assignCourseUrl = 'http://192.168.1.13/campus_connect_api/assign_course.php';

  List<dynamic> _courses = [];
  List<dynamic> _teachers = [];
  List<dynamic> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchCourses(),
      _fetchTeachers(),
      _fetchGroups(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchCourses() async {
    try {
      final response = await http.post(Uri.parse(_fetchCoursesUrl), body: {'action': 'read'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _courses = data['courses'] ?? [];
        }
      }
    } catch (e) {
      print("Error courses: $e");
    }
  }

  Future<void> _fetchTeachers() async {
    try {
      final response = await http.get(Uri.parse(_fetchTeachersUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _teachers = data['teachers'] ?? [];
        }
      }
    } catch (e) {
      print("Error teachers: $e");
    }
  }

  Future<void> _fetchGroups() async {
    try {
      // manage_groups.php usually expects an action
      final response = await http.post(Uri.parse(_fetchGroupsUrl), body: {'action': 'read'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _groups = data['groups'] ?? [];
        }
      }
    } catch (e) {
      print("Error groups: $e");
    }
  }

  Future<void> _createCourse(String name, String code) async {
    try {
      await http.post(
        Uri.parse(_fetchCoursesUrl),
        body: {'action': 'create', 'name': name, 'code': code},
      );
      _fetchCourses(); 
    } catch (e) {
      print("Error creating: $e");
    }
  }

  Future<void> _deleteCourse(String id) async {
    try {
      await http.post(
        Uri.parse(_fetchCoursesUrl),
        body: {'action': 'delete', 'id': id},
      );
      _fetchCourses();
    } catch (e) {
      print("Error deleting: $e");
    }
  }

  Future<void> _assignCourse(String courseId, String teacherId, String groupId) async {
    try {
      final response = await http.post(
        Uri.parse(_assignCourseUrl),
        body: {'course_id': courseId, 'teacher_id': teacherId, 'group_id': groupId},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Assigned successfully!')));
        _fetchCourses(); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${data['message']}')));
      }
    } catch (e) {
      print("Error assigning: $e");
    }
  }

  void _showAssignDialog(dynamic course) {
     String? selectedTeacher;
     String? selectedGroup;
     
     // Optional: Pre-select if course has existing teacher/group
     // (Requires manage_courses.php to return these fields)

     showDialog(
       context: context,
       builder: (ctx) => StatefulBuilder(
         builder: (context, setStateDlg) {
           return AlertDialog(
             title: Text("Assign ${course['name']}"),
             content: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                 const Text("Select Teacher:", style: TextStyle(fontWeight: FontWeight.bold)),
                 DropdownButton<String>(
                   isExpanded: true,
                   hint: const Text("Choose Teacher"),
                   value: selectedTeacher,
                   items: _teachers.map<DropdownMenuItem<String>>((t) {
                     return DropdownMenuItem<String>(
                       value: t['id'].toString(),
                       child: Text(t['name']),
                     );
                   }).toList(),
                   onChanged: (val) => setStateDlg(() => selectedTeacher = val),
                 ),
                 const SizedBox(height: 16),
                 const Text("Select Group:", style: TextStyle(fontWeight: FontWeight.bold)),
                 DropdownButton<String>(
                   isExpanded: true,
                   hint: const Text("Choose Group"),
                   value: selectedGroup,
                   items: _groups.map<DropdownMenuItem<String>>((g) {
                     return DropdownMenuItem<String>(
                       value: g['id'].toString(),
                       child: Text(g['name']),
                     );
                   }).toList(),
                   onChanged: (val) => setStateDlg(() => selectedGroup = val),
                 ),
               ],
             ),
             actions: [
               TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
               ElevatedButton(
                 onPressed: () {
                   if (selectedTeacher != null && selectedGroup != null) {
                     _assignCourse(course['id'].toString(), selectedTeacher!, selectedGroup!);
                     Navigator.pop(ctx);
                   }
                 },
                 child: const Text("Assign"),
               ),
             ],
           );
         }
       ),
     );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Courses'),
        backgroundColor: const Color(0xFF0D2F5F),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D2F5F),
        onPressed: () {
           final nameCtrl = TextEditingController();
           final codeCtrl = TextEditingController();
           showDialog(
             context: context, 
             builder: (_) => AlertDialog(
               title: const Text("Add New Course"),
               content: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: "Course Name (e.g. Algorithms)")),
                   const SizedBox(height: 8),
                   TextField(controller: codeCtrl, decoration: const InputDecoration(hintText: "Course Code (e.g. CS101)")),
                 ],
               ),
               actions: [
                 TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                 ElevatedButton(
                   onPressed: () {
                     if (nameCtrl.text.isNotEmpty && codeCtrl.text.isNotEmpty) {
                       _createCourse(nameCtrl.text, codeCtrl.text);
                       Navigator.pop(context);
                     }
                   }, 
                   child: const Text("Add")
                 )
               ],
             )
           );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : _courses.isEmpty 
           ? const Center(child: Text("No courses found. Add one!"))
           : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                       backgroundColor: const Color(0xFFE0E7FF),
                       child: Text(
                         course['code'] != null && course['code'].length > 0 ? course['code'][0] : 'C',
                         style: const TextStyle(color: Color(0xFF0D2F5F), fontWeight: FontWeight.bold)
                       ),
                    ),
                    title: Text(course['name'] ?? 'Unnamed', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(course['code'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Assign Button
                        IconButton(
                          icon: const Icon(Icons.link, color: Colors.blue),
                          tooltip: 'Assign to Teacher/Group',
                          onPressed: () => _showAssignDialog(course),
                        ),
                        // Delete Button
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCourse(course['id'].toString()),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
