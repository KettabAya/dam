import 'package:flutter/material.dart';
import 'students_page.dart'; // pour utiliser la classe Student

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _groupController,
              decoration:
              const InputDecoration(labelText: 'Group (ex: G1)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _yearController,
              decoration: const InputDecoration(
                  labelText: 'Academic year (ex: 1)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isEmpty ||
                    _emailController.text.isEmpty ||
                    _groupController.text.isEmpty ||
                    _yearController.text.isEmpty) {
                  return;
                }

                final String name = _nameController.text;
                final String email = _emailController.text;
                final String group = _groupController.text;
                final int year =
                    int.tryParse(_yearController.text) ?? 1;

                // Générer les initiales
                final parts = name.trim().split(' ');
                String initials = '';
                for (var p in parts) {
                  if (p.isNotEmpty) {
                    initials += p[0].toUpperCase();
                  }
                }
                if (initials.length > 2) {
                  initials = initials.substring(0, 2);
                }

                final newStudent = Student(
                  id: 0, // Temporary ID for new students
                  name: name,
                  initials: initials,
                  group: group,
                  email: email,
                  year: year,
                  role: 'student', // Default role
                );

                Navigator.pop(context, newStudent);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
