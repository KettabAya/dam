import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MySchedulePage extends StatefulWidget {
  final Map<String, dynamic> user;
  const MySchedulePage({super.key, required this.user});

  @override
  State<MySchedulePage> createState() => _MySchedulePageState();
}

class _MySchedulePageState extends State<MySchedulePage> {
  String? _timetableUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTimetable();
  }

  Future<void> _fetchTimetable() async {
    setState(() => _isLoading = true);
    try {
      final groupId = widget.user['group_id'];
      if (groupId == null) {
         setState(() => _isLoading = false);
         return;
      }

      final response = await http.get(
         Uri.parse('http://192.168.1.13/campus_connect_api/get_timetable.php?group_id=$groupId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _timetableUrl = data['timetable_url'];
          });
        }
      }
    } catch (e) {
      print("Error fetching timetable: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Timetable'), backgroundColor: const Color(0xFFF5F7FB)),
      backgroundColor: const Color(0xFFF5F7FB),
      body: _isLoading 
         ? const Center(child: CircularProgressIndicator()) 
         : _timetableUrl == null || _timetableUrl!.isEmpty
            ? const Center(child: Text("No timetable uploaded for your group."))
            : Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // If it's a full URL, use Image.network. If it's just a filename, assume local or base url.
                      // For simplicity, assuming user pasted a full URL or we prepend base.
                      // We will use Image.network and handle errors.
                       Image.network(
                         _timetableUrl!,
                         loadingBuilder: (ctx, child, loadingProgress) {
                           if (loadingProgress == null) return child;
                           return const CircularProgressIndicator();
                         },
                         errorBuilder: (ctx, error, stackTrace) => const Column(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Icon(Icons.broken_image, size: 50, color: Colors.grey),
                             Text("Could not load image. Link might be invalid."),
                           ],
                         ),
                       ),
                       const SizedBox(height: 20),
                       Text("Timetable URL: $_timetableUrl", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
    );
  }
}
