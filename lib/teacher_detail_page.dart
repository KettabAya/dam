import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'teachers_page.dart';

class TeacherDetailPage extends StatefulWidget {
  final Teacher teacher;

  const TeacherDetailPage({super.key, required this.teacher});

  @override
  State<TeacherDetailPage> createState() => _TeacherDetailPageState();
}

class _TeacherDetailPageState extends State<TeacherDetailPage> {
  // Fields for editing
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _departmentController;

  // Toggle state
  bool _isEditing = false;
  bool _isLoading = false;

  bool groupA = true;
  bool groupB = false;
  bool groupC = true;
  bool groupEvening = false;

  bool courseAdvAlgo = true;
  bool courseSoftArch = false;
  bool courseML = false;
  bool courseMobile = false;
  bool courseNetwork = false;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.teacher.name);
    _emailController = TextEditingController(text: widget.teacher.email);
    _departmentController = TextEditingController(text: widget.teacher.department);
    
    // Ideally, we should initialize booleans from widget.teacher properties if they existed.
    // Since they don't exist in the current Teacher model, we default to the hardcoded values 
    // or you could fetch them from a separate API call here.
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    super.dispose();
  }
  
  Future<void> _saveTeacher() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://192.168.1.13/campus_connect_api/update_teacher.php');
    
    try {
      final response = await http.post(url, body: {
        'id': widget.teacher.id.toString(),
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'department': _departmentController.text.trim(),
        // Send booleans as 'true'/'false' strings
        'groupA': groupA.toString(),
        'groupB': groupB.toString(),
        'groupC': groupC.toString(),
        'groupEvening': groupEvening.toString(),
        'courseAdvAlgo': courseAdvAlgo.toString(),
        'courseSoftArch': courseSoftArch.toString(),
        'courseML': courseML.toString(),
        'courseMobile': courseMobile.toString(),
        'courseNetwork': courseNetwork.toString(),
      });

      print('Update Teacher Response: ${response.body}');

      if (response.statusCode == 200) {
         final data = response.body.isNotEmpty ? response.body : '{}';
         // Check for success marker
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Replied: $data')),
        );

        if (data.toString().toLowerCase().contains("success")) {
           setState(() {
            _isEditing = false;
          });
        }
       
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to save. HTTP Error: ${response.statusCode}')),
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

  Future<void> _deleteTeacher() async {
      final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: const Text('Are you sure you want to delete this teacher?'),
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

      final url = Uri.parse('http://192.168.1.13/campus_connect_api/delete_teacher.php');
      try {
        final response = await http.post(url, body: {
          'id': widget.teacher.id.toString(),
        });

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Teacher deleted.')),
          );
          Navigator.pop(context, true); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete. Error: ${response.statusCode}')),
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
    // final teacher = widget.teacher; // Use controllers for display when editing

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F7FB),
        foregroundColor: Colors.black,
        title: const Text(
          'Teacher Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20, 
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          )
        ],
      ),
      body: SafeArea(
        child: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header carte avec nom et matière
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isEditing) ...[
                      TextField(
                         controller: _nameController,
                         decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                         controller: _departmentController,
                         decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                         controller: _emailController,
                         decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                      ),
                    ] else ...[
                      Text(
                        _nameController.text, // Use controller text to reflect local edits
                        style: const TextStyle(
                          fontSize: 22, 
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _departmentController.text,
                        style: const TextStyle(
                          fontSize: 17, 
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _emailController.text,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ]
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Professional Summary
              const Text(
                'Professional Summary',
                style: TextStyle(
                  fontSize: 19, 
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  'Specialist in computational geometry and randomised algorithms.',
                  style: TextStyle(
                    fontSize: 16, 
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Groups
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Groups',
                    style: TextStyle(
                      fontSize: 19, 
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_isEditing)
                  const Text('(Select to assign)', style: TextStyle(fontSize: 12, color: Colors.grey))
                ],
              ),
              const SizedBox(height: 10),
              // While editing, we allow toggling. 
              // While viewing, we disable toggling (read-only) or allow? The UI implies these are settings.
              // Let's allow toggling only in Edit mode for better UX, or always? 
              // Original request: "make these pages editable". Let's restrict to edit mode.
              AbsorbPointer(
                absorbing: !_isEditing,
                child: Column(
                  children: [
                    _SelectableRow(
                      isSelected: groupA,
                      label: 'Group A (Computer Science)',
                      onChanged: (v) {
                        setState(() => groupA = v);
                      },
                    ),
                    _SelectableRow(
                      isSelected: groupB,
                      label: 'Group B (Information Systems)',
                      onChanged: (v) {
                        setState(() => groupB = v);
                      },
                    ),
                    _SelectableRow(
                      isSelected: groupC,
                      label: 'Group C (Design)',
                      onChanged: (v) {
                        setState(() => groupC = v);
                      },
                    ),
                    _SelectableRow(
                      isSelected: groupEvening,
                      label: 'Evening Fast-Track',
                      onChanged: (v) {
                        setState(() => groupEvening = v);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Courses
              const Text(
                'Courses',
                style: TextStyle(
                  fontSize: 19, 
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              AbsorbPointer(
                absorbing: !_isEditing,
                child: Column(
                  children: [
                    _SelectableRow(
                      isSelected: courseAdvAlgo,
                      label: 'Advanced Algorithms',
                      onChanged: (v) {
                        setState(() => courseAdvAlgo = v);
                      },
                    ),
                    _SelectableRow(
                      isSelected: courseSoftArch,
                      label: 'Software Architecture',
                      onChanged: (v) {
                        setState(() => courseSoftArch = v);
                      },
                    ),
                    _SelectableRow(
                      isSelected: courseML,
                      label: 'Machine Learning Basics',
                      onChanged: (v) {
                        setState(() => courseML = v);
                      },
                    ),
                    _SelectableRow(
                      isSelected: courseMobile,
                      label: 'Mobile App Development',
                      onChanged: (v) {
                        setState(() => courseMobile = v);
                      },
                    ),
                    _SelectableRow(
                      isSelected: courseNetwork,
                      label: 'Network Security',
                      onChanged: (v) {
                        setState(() => courseNetwork = v);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              if (_isEditing)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: _saveTeacher, 
                  child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
                ),
              
              const SizedBox(height: 16),
              
              TextButton(
                  onPressed: _deleteTeacher, 
                  child: const Text('Delete Teacher', style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// petit widget pour une ligne sélectionnable
class _SelectableRow extends StatelessWidget {
  final bool isSelected;
  final String label;
  final ValueChanged<bool> onChanged;

  const _SelectableRow({
    super.key,
    required this.isSelected,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
    isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB);
    final bgColor =
    isSelected ? const Color(0xFFE0E7FF) : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.4),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (v) => onChanged(v ?? false),
        activeColor: const Color(0xFF4F46E5), // Make sure this color is visible
        checkColor: Colors.white,
        checkboxShape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 17, // 15 -> 17
            fontWeight: FontWeight.w500,
          ),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
