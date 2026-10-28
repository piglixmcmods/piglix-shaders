import 'package:flutter/material.dart';

enum LegalType { privacy, terms, trademark, licenses }

class LegalPage extends StatelessWidget {
  final LegalType type;

  const LegalPage({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final title = _getTitle(type);
    final icon = _getIcon(type);

    return Scaffold(
      backgroundColor: const Color(0xFF040F0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF040F0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF10B981),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(icon, color: const Color(0xFF10B981), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFF0D251A), height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(type),
              const SizedBox(height: 20),
              ..._buildCards(type),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  '© 2026 Piglix Labs • All rights reserved',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle(LegalType t) {
    switch (t) {
      case LegalType.privacy:
        return 'Privacy Policy';
      case LegalType.terms:
        return 'Terms of Service';
      case LegalType.trademark:
        return 'Trademark & Legal Disclaimer';
      case LegalType.licenses:
        return 'Open Source Licenses';
    }
  }

  IconData _getIcon(LegalType t) {
    switch (t) {
      case LegalType.privacy:
        return Icons.security_outlined;
      case LegalType.terms:
        return Icons.description_outlined;
      case LegalType.trademark:
        return Icons.verified_user_outlined;
      case LegalType.licenses:
        return Icons.code_rounded;
    }
  }

  Widget _buildHeader(LegalType t) {
    switch (t) {
      case LegalType.trademark:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'UNOFFICIAL MINECRAFT\nCOMPANION APP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                height: 1.25,
              ),
            ),
          ],
        );
      case LegalType.privacy:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shader Generator for MCPE —\nPrivacy Policy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Piglix Labs • Last updated: October 1, 2026',
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      case LegalType.terms:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms of Service',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Piglix Labs • Last updated: October 1, 2026',
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      case LegalType.licenses:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Open Source Licenses & Attributions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Third-Party Software & Open-Source Projects',
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
    }
  }

  List<Widget> _buildCards(LegalType t) {
    switch (t) {
      case LegalType.trademark:
        return [
          _legalCard(
            title: 'Important Notice',
            content:
                'NOT AN OFFICIAL MINECRAFT PRODUCT. NOT APPROVED BY OR ASSOCIATED WITH MOJANG OR MICROSOFT.',
            highlight: true,
          ),
          _legalCard(
            title: 'Trademark Information',
            content:
                '• "Minecraft" is a registered trademark of Mojang Synergies AB.\n\n'
                '• All Minecraft assets, brands, and textures belong strictly to Mojang AB and Microsoft Corporation.\n\n'
                '• Shader Generator for MCPE is an independent, third-party utility created by fans for fans. It is not affiliated with, endorsed by, sponsored by, or otherwise connected to Mojang AB or Microsoft Corporation in any way.\n\n'
                '• This app complies with the Minecraft Commercial Usage Guidelines.',
          ),
          _legalCard(
            title: 'Commercial Guidelines Compliance',
            content:
                '• In accordance with Mojang Brand and Asset Guidelines, this application does not distribute core Minecraft game assets or binaries.\n\n'
                '• Shaders generated with this tool customize lighting and visual parameter definitions locally on the user\'s device without altering game executables.',
          ),
        ];

      case LegalType.privacy:
        return [
          _legalCard(
            title: 'Overview',
            content:
                'Piglix Labs ("we", "our", or "us") operates the Shader Generator for MCPE mobile application. This page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Application.',
          ),
          _legalCard(
            title: '1. Information Collection and Use',
            content:
                'Shader Generator for MCPE is designed as a standalone utility tool:\n\n'
                '• Zero Personal Data Collection: We do NOT collect, store, or sell any personally identifiable information (PII) such as your name, email, phone number, or physical location.\n\n'
                '• Local Processing: All shader configurations, lighting adjustments, and pack generations are processed directly and locally on your device.',
          ),
          _legalCard(
            title: '2. Device Storage & File Permissions',
            content:
                'The Application may request permission to access device storage solely for the purpose of exporting and saving generated shader .mcpack files directly to your device or Minecraft resource pack folder. We do not access, read, or modify any personal photos, private documents, or unrelated files.',
          ),
          _legalCard(
            title: '3. Third-Party Advertising & Services',
            content:
                'We may display advertisements to keep this application free for everyone. We use third-party advertising partners such as Google AdMob.\n\n'
                'These ad networks may collect anonymized device identifiers or ad interaction data according to their own privacy policies. For more info: https://policies.google.com/privacy',
          ),
          _legalCard(
            title: '4. Children\'s Privacy',
            content:
                'Our Application is intended for general audiences (ages 13 and above). We do not knowingly collect personal identifiable information from children under 13.',
          ),
          _legalCard(
            title: '5. Changes to This Policy',
            content:
                'We may update our Privacy Policy periodically. Any updates will be posted directly to this page with a revised "Last updated" date.',
          ),
          _legalCard(
            title: '6. Contact Us',
            content:
                'If you have questions regarding our Privacy Policy, contact us at:\n\n'
                'Email: realpiglix@gmail.com',
          ),
        ];

      case LegalType.terms:
        return [
          _legalCard(
            title: '1. Acceptance of Terms',
            content:
                'By downloading, installing, or using Shader Generator for MCPE, you agree to be bound by these Terms of Service. If you do not agree, do not use the application.',
          ),
          _legalCard(
            title: '2. User Responsibility',
            content:
                'You are solely responsible for the content you generate. You agree not to use this tool to modify files in ways that violate the End User License Agreement (EULA) of Minecraft or any third-party copyrights.',
          ),
          _legalCard(
            title: '3. Limitation of Liability',
            content:
                'The app is provided "AS IS". Piglix Labs assumes no liability for game crashes, data loss, or account issues resulting from the use of custom shaders generated by this tool.',
          ),
          _legalCard(
            title: '4. Intellectual Property',
            content:
                'The app\'s code and original UI are copyright Piglix Labs. Users retain rights to their custom shader configurations.',
          ),
          _legalCard(
            title: '5. Contact',
            content:
                'Email: realpiglix@gmail.com\nWebsite: https://piglixmcmods.dev',
          ),
        ];

      case LegalType.licenses:
        return [
          _legalCard(
            title: 'Flutter Framework',
            content:
                'License: BSD 3-Clause License\n'
                'Copyright 2014 The Flutter Authors. All rights reserved.',
          ),
          _legalCard(
            title: 'Packages & Third-Party Libraries',
            content:
                '• archive — Apache 2.0 / MIT\n'
                '• file_saver — MIT License\n'
                '• file_picker — MIT License\n'
                '• path_provider — BSD 3-Clause\n'
                '• flutter_colorpicker — MIT License\n'
                '• google_fonts — Apache 2.0\n'
                '• uuid — MIT License',
          ),
        ];
    }
  }

  Widget _legalCard({
    required String title,
    required String content,
    bool highlight = false,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF071911),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight
              ? const Color(0xFF10B981).withOpacity(0.6)
              : const Color(0xFF123424),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3.5,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFFC7D7CF),
              fontSize: 14,
              height: 1.55,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF040F0A),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF071911),
                border: Border(
                  bottom: BorderSide(color: Color(0xFF123424), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF10B981),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PIGLIX STUDIO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Shader Generator for MCPE',
                          style: TextStyle(
                            color: const Color(0xFF10B981).withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation List Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                children: [
                  _drawerTile(
                    context: context,
                    icon: Icons.shield_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Data usage & local privacy',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalPage(type: LegalType.privacy),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    context: context,
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    subtitle: 'Usage guidelines & liability',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalPage(type: LegalType.terms),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    context: context,
                    icon: Icons.verified_user_outlined,
                    title: 'Trademark & Disclaimers',
                    subtitle: 'Mojang brand policy & notices',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalPage(type: LegalType.trademark),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    context: context,
                    icon: Icons.code_rounded,
                    title: 'Open Source Licenses',
                    subtitle: 'MIT & third-party software',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalPage(type: LegalType.licenses),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Drawer Footer
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFF123424), width: 1),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Shader Generator for MCPE • v1.0.0',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2026 Piglix Labs • Unofficial Companion',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF071911),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF102E20), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF10B981), size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 11.5,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF10B981),
            size: 20,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
