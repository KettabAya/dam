import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TeacherFilesPage extends StatefulWidget {
  final String courseId;
  const TeacherFilesPage({super.key, required this.courseId});

  @override
  State<TeacherFilesPage> createState() => _TeacherFilesPageState();
}

class _TeacherFilesPageState extends State<TeacherFilesPage> {
  List<dynamic> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFiles();
  }

  Future<void> _fetchFiles() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.13/campus_connect_api/get_course_files.php?course_id=${widget.courseId}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _files = data['files'] ?? [];
          });
        }
      }
    } catch (e) {
      print("Error fetching files: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadFile() async {
    // Simple version: Just send a text filename for now since actual file picking requires external packages not "basic"
    // If user insists on "simple", we simulate or ask to implement package later.
    // For now, we mock the POST request structure for "uploading" (maybe just linking a URL).
    
    final controller = TextEditingController();
    showDialog(
      context: context, 
      builder: (_) => AlertDialog(
        title: const Text("Upload File (Link)"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "File URL or Name")),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if(controller.text.isNotEmpty) {
                 await http.post(
                   Uri.parse('http://192.168.1.13/campus_connect_api/upload_course_file.php'),
                   body: {'course_id': widget.courseId, 'filename': controller.text, 'filepath': 'http://example.com/file'}
                 );
                 Navigator.pop(context);
                 _fetchFiles();
              }
            },
            child: const Text("Upload")
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Course Files"), backgroundColor: const Color(0xFF0D2F5F), foregroundColor: Colors.white),
      body: Column(
        children: [
           Padding(
             padding: const EdgeInsets.all(16.0),
             child: SizedBox(
               width: double.infinity,
               child: ElevatedButton.icon(
                 onPressed: _uploadFile,
                 icon: const Icon(Icons.upload_file),
                 label: const Text("Upload New File"),
                 style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
               ),
             ),
           ),
           Expanded(
             child: _isLoading 
             ? const Center(child: CircularProgressIndicator()) 
             : _files.isEmpty 
               ? const Center(child: Text("No files uploaded yet."))
               : ListView.builder(
                   itemCount: _files.length,
                   itemBuilder: (context, index) {
                     final file = _files[index];
                     return Card(
                       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                       child: ListTile(
                         leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
                         title: Text(file['filename'] ?? 'Unknown File'),
                         subtitle: Text(file['uploaded_at'] ?? ''),
                         trailing: TextButton(
                           onPressed: () {
                             // Open logic
                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Opening ${file['filepath']}...")));
                           },
                           child: const Text("OPEN"),
                         ),
                       ),
                     );
                   },
                 ),
           )
        ],
      ),
    );
  }
}
