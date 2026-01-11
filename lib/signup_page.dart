import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'splash_page.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final String _registerUrl =
      'http://192.168.1.13/campus_connect_api/register.php';

  final int _groupId = 1; 

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _yearController = TextEditingController(); 
  
  String _selectedRole = 'student'; 

  Future<void> _onSignup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final dob = _dobController.text.trim(); 
    final year = _yearController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || dob.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (_selectedRole == 'student' && year.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter academic year for student')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(_registerUrl),
        body: {
          'name': name,
          'email': email,
          'password': password,
          'role': _selectedRole,
          'group_id': _groupId.toString(),
          'academic_year': year, 
        },
      );

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        throw Exception('Invalid JSON: ${response.body}');
      }

      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Registration failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2F5F),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SplashPage())),
                  ),
                  Center(
                    child: SizedBox(
                      height: 80, // Reduced height
                      child: Image.asset('assets/images/imgpagelogin.png', fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: true,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + MediaQuery.of(context).padding.bottom),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Create new Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    Center(
                      child: TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage())),
                        child: const Text('Already Registered? Log in here.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text('NAME', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 10)),
                    const SizedBox(height: 4),
                    _buildCompactField(controller: _nameController, hint: 'Jiara Martins'),

                    const SizedBox(height: 8),
                    const Text('EMAIL', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 10)),
                    const SizedBox(height: 4),
                    _buildCompactField(controller: _emailController, hint: 'hello@reallygreatsite.com'),

                    const SizedBox(height: 8),
                    const Text('PASSWORD', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 10)),
                    const SizedBox(height: 4),
                    _buildCompactField(controller: _passwordController, hint: '******', obscure: true),

                    const SizedBox(height: 8),
                    const Text('DATE OF BIRTH', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 10)),
                    const SizedBox(height: 4),
                    _buildCompactField(controller: _dobController, hint: 'DD/MM/YYYY'),

                    const SizedBox(height: 8),
                    const Text('ROLE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 10)),
                    const SizedBox(height: 4),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(color: const Color(0xFFE3E3E3), borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedRole,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 13, color: Colors.black),
                          items: const [
                            DropdownMenuItem(value: 'student', child: Text('Student')),
                            DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                          ],
                          onChanged: (String? newValue) {
                            if (newValue != null) setState(() => _selectedRole = newValue);
                          },
                        ),
                      ),
                    ),

                    if (_selectedRole == 'student') ...[
                      const SizedBox(height: 8),
                      const Text('ACADEMIC YEAR', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 10)),
                      const SizedBox(height: 4),
                      _buildCompactField(controller: _yearController, hint: '1, 2, 3', keyboardType: TextInputType.number),
                    ],

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D2F5F),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _onSignup,
                        child: const Text('Sign up', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactField({required TextEditingController controller, required String hint, bool obscure = false, TextInputType? keyboardType}) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          filled: true,
          fillColor: const Color(0xFFE3E3E3),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
