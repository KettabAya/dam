import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// ----- Modèle Student (pour le JSON de PHP) -----
class Student {
  final int id;
  final String name;
  final String email;
  final int? groupId;

  Student({
    required this.id,
    required this.name,
    required this.email,
    this.groupId,
  });

  // JSON -> Student
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      groupId: json['group_id'] == null
          ? null
          : int.parse(json['group_id'].toString()),
    );
  }

  // (optionnel) Student -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'group_id': groupId,
    };
  }
}

/// ----- Page PendingRegistrations (Stateful pour utiliser Future) -----
class PendingRegistrationsPage extends StatefulWidget {
  const PendingRegistrationsPage({super.key});

  @override
  State<PendingRegistrationsPage> createState() =>
      _PendingRegistrationsPageState();
}

class _PendingRegistrationsPageState extends State<PendingRegistrationsPage> {
  late Future<List<Student>> _futureStudents;

  @override
  void initState() {
    super.initState();
    _futureStudents = fetchPendingStudents();
  }

  Future<List<Student>> fetchPendingStudents() async {
    // IMPORTANT : 10.0.2.2 = localhost pour l'émulateur Android
    final url = Uri.parse(
      'http://192.168.1.13/campus_connect_api/get_pending_students.php',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> list = data['students'] ?? [];
      return list.map((e) => Student.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load students: HTTP ${response.statusCode}');
    }
  }

  // ----- Approve d'un étudiant -----
  Future<void> approveStudent(int id, int groupId) async {
    final url = Uri.parse(
      'http://192.168.1.13/campus_connect_api/approve_student.php',
    );

    try {
      final response = await http.post(
        url,
        body: {
          'id': id.toString(),
          'group_id': groupId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // on recharge la liste
          setState(() {
            _futureStudents = fetchPendingStudents();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student approved')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${data['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('HTTP error ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2F5F),
      body: SafeArea(
        child: Column(
          children: [
            // bande bleue : flèche + logo centré
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 80,
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            // partie blanche arrondie
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: FutureBuilder<List<Student>>(
                  future: _futureStudents,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final students = snapshot.data ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        const Center(
                          child: Text(
                            'Pending Registrations',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              const Text(
                                'Waitlist',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${students.length} Students',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final student = students[index];
                              return StudentCard(
                                student: student,
                                onApprove: (groupId) =>
                                    approveStudent(student.id, groupId),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ----- Carte d’un étudiant -----
class StudentCard extends StatefulWidget {
  final Student student;
  final Function(int) onApprove;

  const StudentCard({
    super.key,
    required this.student,
    required this.onApprove,
  });

  @override
  State<StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> {
  int _selectedGroup = 1;

  String _buildInitials(String name) {
    // simple fonction pour générer les initiales à partir du nom complet
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    } else {
      return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
          .toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = _buildInitials(widget.student.name);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE0E7FF),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Color(0xFF0D2F5F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NOM / PRÉNOM plus grands
                    Text(
                      widget.student.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.student.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Dropdown pour choisir le groupe
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButton<int>(
                  value: _selectedGroup,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  items: [1, 2, 3, 4, 5, 6].map((int val) {
                    return DropdownMenuItem<int>(
                      value: val,
                      child: Text('Group $val'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedGroup = newValue;
                      });
                    }
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () => widget.onApprove(_selectedGroup),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Approve',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
