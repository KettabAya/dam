import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SchedulesFilesPage extends StatefulWidget {
  const SchedulesFilesPage({super.key});

  @override
  State<SchedulesFilesPage> createState() => _SchedulesFilesPageState();
}

class _SchedulesFilesPageState extends State<SchedulesFilesPage> {
  // CORRECT BACKEND URLs
  final String _getGroupsUrl = 'http://192.168.1.13/campus_connect_api/manage_groups.php';
  final String _getTimetableUrl = 'http://192.168.1.13/campus_connect_api/get_timetable.php';
  final String _updateTimetableUrl = 'http://192.168.1.13/campus_connect_api/manage_timetables.php';
  final String _getFilesUrl = 'http://192.168.1.13/campus_connect_api/get_group_files.php';
  final String _addFileUrl = 'http://192.168.1.13/campus_connect_api/upload_group_file.php';

  List<dynamic> _groups = [];
  String? _selectedGroupId;
  String _timetableUrl = ''; 
  List<dynamic> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    try {
       // Using manage_groups.php which requires 'action'
      final response = await http.post(Uri.parse(_getGroupsUrl), body: {'action': 'read'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _groups = data['groups'];
            if (_groups.isNotEmpty) {
              _selectedGroupId = _groups[0]['id'].toString();
              _fetchGroupDetails();
            } else {
              _isLoading = false;
            }
          });
        }
      }
    } catch (e) {
      print('Error fetching groups: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchGroupDetails() async {
    if (_selectedGroupId == null) return;
    setState(() => _isLoading = true);

    try {
      // 1. Get Timetable
      final timetableResp = await http.post(
        Uri.parse(_getTimetableUrl),
        body: {'group_id': _selectedGroupId},
      );
      if (timetableResp.statusCode == 200) {
        final tData = jsonDecode(timetableResp.body);
        if (tData['success'] == true) {
          _timetableUrl = tData['timetable_url'] ?? '';
        } else {
          _timetableUrl = '';
        }
      }

      // 2. Get Files
      final filesResp = await http.post(
        Uri.parse(_getFilesUrl),
        body: {'group_id': _selectedGroupId},
      );
      if (filesResp.statusCode == 200) {
        final fData = jsonDecode(filesResp.body);
        if (fData['success'] == true) {
          _files = fData['files'];
        } else {
          _files = [];
        }
      }
    } catch (e) {
      print('Error details: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateTimetable() async {
    final TextEditingController urlController = TextEditingController(text: _timetableUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Timetable'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(labelText: 'Image URL (e.g., http://...)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await http.post(Uri.parse(_updateTimetableUrl), body: {
                'group_id': _selectedGroupId,
                'timetable_url': urlController.text
              });
              _fetchGroupDetails();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _addFile() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController pathController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Group File'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'File Name')),
            TextField(controller: pathController, decoration: const InputDecoration(labelText: 'File URL / Path')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await http.post(Uri.parse(_addFileUrl), body: {
                'group_id': _selectedGroupId,
                'filename': nameController.text,
                'filepath': pathController.text,
              });
              _fetchGroupDetails();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2F5F),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Schedules & Files',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // BODY
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F7FB),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SELECT GROUP
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('SELECT GROUP', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            _groups.isEmpty
                                ? const Text("Loading groups...")
                                : Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedGroupId,
                                        isExpanded: true,
                                        items: _groups.map<DropdownMenuItem<String>>((g) {
                                          return DropdownMenuItem<String>(
                                            value: g['id'].toString(),
                                            child: Text(g['name']),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          setState(() => _selectedGroupId = val);
                                          _fetchGroupDetails();
                                        },
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // TIMETABLE
                      Row(
                        children: const [
                          Icon(Icons.event_note, size: 18, color: Colors.purple),
                          SizedBox(width: 6),
                          Text('Timetable', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 180,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: _timetableUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: Image.network(_timetableUrl, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image)),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.event_available, size: 40, color: Color(0xFF4F46E5)),
                                        SizedBox(height: 12),
                                        Text('No Timetable Url', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: _updateTimetable,
                              icon: const Icon(Icons.edit, size: 18, color: Color(0xFF4F46E5)),
                              label: const Text('Update Timetable Version', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // SHARED FILES
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Shared Files', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          TextButton(
                            onPressed: _addFile,
                            child: const Text('+ Add File', style: TextStyle(fontSize: 13, color: Color(0xFF4F46E5), fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      _files.isEmpty 
                        ? const Center(child: Text("No files shared yet."))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _files.length,
                            itemBuilder: (context, index) {
                              final f = _files[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32, height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.insert_drive_file, size: 20, color: Colors.blue),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(f['filename'] ?? 'File', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                          Text(f['uploaded_at'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.cloud_download_outlined, size: 18, color: Colors.grey),
                                  ],
                                ),
                              );
                            },
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
