import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'students_page.dart'; // pour réutiliser Student

class StudentDetailPage extends StatefulWidget {
  final Student student;

  const StudentDetailPage({super.key, required this.student});

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _groupController;
  late TextEditingController _yearController;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.name);
    _emailController = TextEditingController(text: widget.student.email);
    // Remove 'G' prefix if present for editing, or handle as string
    _groupController = TextEditingController(text: widget.student.group); 
    _yearController = TextEditingController(text: widget.student.year.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _groupController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://192.168.1.13/campus_connect_api/update_student.php');
    
    // Simple validation
    // For group, we just send whatever is in the text field. 
    // Backend expects 'group_id' or string. 
    // The PHP script I wrote assigns to 'group_id' column.
    
    try {
      final response = await http.post(url, body: {
        'id': widget.student.id.toString(),
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'group_id': _groupController.text.trim(), // Assuming backend saves this as string or int
        'year': _yearController.text.trim(),
      });

      print('Update Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = response.body.isNotEmpty ? response.body : '{}';
        if (data.contains("success")) {
           // Basic check for success string if JSON parsing is hard/mixed
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Changes saved successfully!')),
            );
            setState(() {
              _isEditing = false;
            });
        } else {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Saved? Response: $data')),
            );
            setState(() {
              _isEditing = false;
            });
        }
       
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to save. HTTP Error: ${response.statusCode}, Body: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteStudent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
       setState(() {
        _isLoading = true;
      });

      final url = Uri.parse('http://192.168.1.13/campus_connect_api/delete_student.php');
      try {
        final response = await http.post(url, body: {
          'id': widget.student.id.toString(),
        });

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student deleted.')),
          );
          Navigator.pop(context, true); // Return true to refresh list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete. HTTP Error: ${response.statusCode}')),
          );
        }
      } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F7FB),
        foregroundColor: Colors.black,
        title: const Text(
          'Student Details',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                // Reset fields if cancelling edit? Optional.
              });
            },
          )
        ],
      ),
      body: SafeArea(
        child: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(0xFF4F46E5),
                    child: Text(
                      widget.student.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // NAME
                  if (_isEditing)
                    TextField(
                      controller: _nameController,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    )
                  else
                    Text(
                      widget.student.name, // Display widget original or controller text? Controller text usually better for immediate feedback if we updated locally
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${widget.student.id}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'EMAIL ADDRESS',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: _isEditing ? 50 : 44,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: _isEditing ? 0 : 12),
                    decoration: _isEditing ? null : BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _isEditing 
                    ? TextField(
                        controller: _emailController,
                         decoration: const InputDecoration(
                          hintText: 'Email',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      )
                    : Text(
                      widget.student.email,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GROUP',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                             Container(
                              height: _isEditing ? 50 : 44,
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: _isEditing ? 0 : 12),
                              decoration: _isEditing ? null : BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _isEditing 
                              ? TextField(
                                  controller: _groupController,
                                   decoration: const InputDecoration(
                                    hintText: 'Group (e.g. G6)',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                )
                              : Text(
                                widget.student.group,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ACADEMIC YEAR',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: _isEditing ? 50 : 44,
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: _isEditing ? 0 : 12),
                              decoration: _isEditing ? null : BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _isEditing 
                              ? TextField(
                                  controller: _yearController,
                                   decoration: const InputDecoration(
                                    hintText: 'Year',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                )
                              : Text(
                                widget.student.year.toString(),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  if (_isEditing)
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: _saveStudent,
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: _deleteStudent,
                    child: const Text(
                      'Delete Student',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
