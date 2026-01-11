import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER BLEU AVEC TITRE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'CAMPUS SCHEDULE',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.1,
                          color: Color(0xFFCBD5F5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // CONTENU BLANC PAR-DESSOUS
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CARTE "AI COACH"
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'AI COACH',
                                  style: TextStyle(
                                    fontSize: 11,
                                    letterSpacing: 1.0,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Ready to analyze your schedule for tips.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Get Advice',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ONGLET SIMPLIFIÉ (pas de vraie logique de filtre)
                    Row(
                      children: [
                        _ChipTab(
                          label: 'All Alerts',
                          isActive: true,
                        ),
                        const SizedBox(width: 8),
                        const _ChipTab(
                          label: 'Upcoming',
                          isActive: false,
                        ),
                        const SizedBox(width: 8),
                        const _ChipTab(
                          label: 'Done',
                          isActive: false,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // TITRE "PLANNING"
                    const Text(
                      'PLANNING',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: Colors.black38,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // LISTE DES NOTIFICATIONS
                    const _NotificationCard(
                      badgeText: 'EX',
                      badgeColor: Color(0xFFF97373),
                      typeText: 'EXAM',
                      title: 'Math Final Exam',
                      dateText: 'May 15',
                      extraText: 'Maths',
                    ),
                    const _NotificationCard(
                      badgeText: 'HW',
                      badgeColor: Color(0xFFFACC6B),
                      typeText: 'HOMEWORK',
                      title: 'UI/UX Prototype',
                      dateText: 'May 10',
                      extraText: 'CS',
                    ),
                    const _NotificationCard(
                      badgeText: 'EV',
                      badgeColor: Color(0xFF93C5FD),
                      typeText: 'EVENT',
                      title: 'AI Guest Lecture',
                      dateText: 'May 12',
                      extraText: '',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipTab extends StatelessWidget {
  final String label;
  final bool isActive;

  const _ChipTab({
    super.key,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isActive ? const Color(0xFF0F172A) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String badgeText;
  final Color badgeColor;
  final String typeText;
  final String title;
  final String dateText;
  final String extraText;

  const _NotificationCard({
    super.key,
    required this.badgeText,
    required this.badgeColor,
    required this.typeText,
    required this.title,
    required this.dateText,
    required this.extraText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Badge EX / HW / EV
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: badgeColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Texte principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      typeText,
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '•',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    if (extraText.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      const Text(
                        '•',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        extraText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // petit bouton état
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Icons.radio_button_unchecked,
              size: 18,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
