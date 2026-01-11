import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ManageGroupsPage extends StatefulWidget {
  const ManageGroupsPage({super.key});

  @override
  State<ManageGroupsPage> createState() => _ManageGroupsPageState();
}

class _ManageGroupsPageState extends State<ManageGroupsPage> {
  List<dynamic> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.13/campus_connect_api/manage_groups.php'),
        body: {'action': 'read'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _groups = data['groups'] ?? [];
          });
        }
      }
    } catch (e) {
      print("Error fetching groups: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createGroup(String name) async {
    try {
      await http.post(
        Uri.parse('http://192.168.1.13/campus_connect_api/manage_groups.php'),
        body: {'action': 'create', 'name': name},
      );
      _fetchGroups();
    } catch (e) {
      print("Error creating group: $e");
    }
  }

  Future<void> _deleteGroup(String id) async {
    try {
      await http.post(
        Uri.parse('http://192.168.1.13/campus_connect_api/manage_groups.php'),
        body: {'action': 'delete', 'id': id},
      );
      _fetchGroups();
    } catch (e) {
      print("Error deleting group: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Groups'),
        backgroundColor: const Color(0xFF0D2F5F),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D2F5F),
        onPressed: () {
           final controller = TextEditingController();
           showDialog(
             context: context, 
             builder: (_) => AlertDialog(
               title: const Text("Add New Group"),
               content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Group Name (e.g. L3 TI)")),
               actions: [
                 TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                 ElevatedButton(
                   onPressed: () {
                     if (controller.text.isNotEmpty) {
                       _createGroup(controller.text);
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
        : _groups.isEmpty 
           ? const Center(child: Text("No groups found."))
           : ListView.builder(
              itemCount: _groups.length,
              itemBuilder: (context, index) {
                final group = _groups[index];
                return ListTile(
                  leading: const Icon(Icons.group),
                  title: Text(group['name'] ?? 'Unnamed Group'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteGroup(group['id'].toString()),
                  ),
                );
              },
            ),
    );
  }
}
