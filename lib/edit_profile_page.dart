import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barre du haut: bouton X + titre
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'UPDATE YOUR PERSONAL DETAILS',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.3,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Bloc "Academic Records"
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ligne titre + icône i + badge bouclier
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Color(0xFF4F46E5),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'ACADEMIC RECORDS (READ ONLY)',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.2,
                            color: Color(0xFF4F46E5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFD6E4FF),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.verified_user_outlined,
                            size: 22,
                            color: const Color(0xFFD6E4FF),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 2 colonnes: FULL NAME / STUDENT ID
                    Row(
                      children: const [
                        Expanded(
                          child: _LabelValue(
                            label: 'FULL NAME',
                            value: 'Jiara Martins',
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _LabelValue(
                            label: 'STUDENT ID',
                            value: 'HA-2025-0422',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 2 colonnes: GROUP / YEAR - FACULTY
                    Row(
                      children: const [
                        Expanded(
                          child: _LabelValue(
                            label: 'GROUP',
                            value: 'CS - Group A',
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _LabelValue(
                            label: 'YEAR / FACULTY',
                            value: 'Sophomore (Year 2)',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'CONTACT INFORMATION',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.4,
                  color: Colors.black45,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              // Phone
              const _ContactTile(
                icon: Icons.phone_in_talk_outlined,
                text: '+1 (555) 123-4567',
              ),
              const SizedBox(height: 10),

              // Email
              const _ContactTile(
                icon: Icons.mail_outline,
                text: 'iiara.martins@horizon.edu',
              ),
              const SizedBox(height: 10),

              // Address
              const _ContactTile(
                icon: Icons.location_on_outlined,
                text: '124 Campus Lane, Horizon Academy D',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Petit widget réutilisable pour label + valeur (FULL NAME, STUDENT ID...)
class _LabelValue extends StatelessWidget {
  final String label;
  final String value;

  const _LabelValue({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 1.1,
            color: Colors.black38,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

/// Tuile contact (icône dans un carré + texte), basée sur Container / Row
class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactTile({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 18,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
