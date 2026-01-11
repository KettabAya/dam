import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyMarksPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const MyMarksPage({super.key, required this.user});

  @override
  State<MyMarksPage> createState() => _MyMarksPageState();
}

class _MyMarksPageState extends State<MyMarksPage> {
  List<dynamic> _marks = [];
  bool _isLoading = true;
  double _average = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchMarks();
  }

  Future<void> _fetchMarks() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
         Uri.parse('http://192.168.1.13/campus_connect_api/student_marks.php'),
         body: {'student_id': widget.user['id'].toString()}
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> loadedMarks = data['marks'] ?? [];
          
          // Calculate Average
          double total = 0;
          if (loadedMarks.isNotEmpty) {
             for (var m in loadedMarks) {
               total += double.tryParse(m['value'].toString()) ?? 0;
             }
             _average = total / loadedMarks.length;
          }

          setState(() {
            _marks = loadedMarks;
          });
        }
      }
    } catch (e) {
      print("Error fetching marks: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('My Marks'),
        backgroundColor: const Color(0xFFF5F7FB),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Average Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CURRENT AVERAGE', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _average.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(width: 4),
                        const Text('/ 20', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            
            // List
            Expanded(
              child: _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : _marks.isEmpty 
                 ? const Center(child: Text('No marks yet.'))
                 : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _marks.length,
                    itemBuilder: (context, index) {
                      final mark = _marks[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.grade, color: Colors.blue),
                          ),
                          title: Text(mark['course_name'] ?? 'Course'),
                          subtitle: Text(mark['code'] ?? ''),
                          trailing: Text(
                            '${mark['value']}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                 ),
            )
          ],
        ),
      ),
    );
  }
}
