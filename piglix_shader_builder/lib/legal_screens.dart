import 'package:flutter/material.dart';
import 'piglix_logo_data.dart';
import 'hero_sunset_bytes.dart';

enum LegalType { privacy, terms, trademark, licenses }

class LegalPage extends StatelessWidget {
  final LegalType type;

  const LegalPage({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final title = _getTitle(type);
    final icon = _getIcon(type);

    return Scaffold(
      backgroundColor: const Color(0xFF080D14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1722),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF22C55E),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(icon, color: const Color(0xFF22C55E), size: 20),
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
          child: Container(color: const Color(0xFF1E293B), height: 1),
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
        color: const Color(0xFF0E1722),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight
              ? const Color(0xFF22C55E).withOpacity(0.6)
              : const Color(0xFF1E293B),
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
                  color: const Color(0xFF22C55E),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF22C55E),
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
              color: Color(0xFF94A3B8),
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
    final topPadding = MediaQuery.paddingOf(context).top;
    return Drawer(
      backgroundColor: const Color(0xFF080D14),
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with cool sunset banner image & proper project name
          Container(
            height: 195 + topPadding,
            decoration: const BoxDecoration(
              color: Color(0xFF0E1722),
              border: Border(
                bottom: BorderSide(color: Color(0xFF1E293B), width: 1.2),
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(
                  kHeroSunsetBytes,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Image.asset(
                    'assets/hero_sunset.webp',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF0E1722),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.40),
                        const Color(0xFF080D14).withOpacity(0.55),
                        const Color(0xFF080D14),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, topPadding + 10, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0E1722).withOpacity(0.85),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF22C55E).withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'PIGLIX STUDIO',
                                  style: TextStyle(
                                    color: Color(0xFF4ADE80),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0E1722).withOpacity(0.75),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24, width: 1),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF22C55E),
                                width: 2.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF22C55E).withOpacity(0.45),
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.memory(kPiglixLogoBytes, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text(
                                      'Shader ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 19,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    Text(
                                      'Generator',
                                      style: TextStyle(
                                        color: Color(0xFF22C55E),
                                        fontSize: 19,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'FOR MINECRAFT PE • BEDROCK RTX',
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation List Items with minimal heading and proper spacing/padding
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
                  child: Text(
                    'LEGAL & POLICIES',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                _drawerTile(
                  icon: Icons.shield_outlined,
                  iconColor: const Color(0xFF2DD4BF),
                  title: 'Privacy Policy',
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
                  icon: Icons.description_outlined,
                  iconColor: const Color(0xFF818CF8),
                  title: 'Terms of Service',
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
                  icon: Icons.verified_user_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Trademark & Notices',
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
                  icon: Icons.code_rounded,
                  iconColor: const Color(0xFF94A3B8),
                  title: 'Open Source Licenses',
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

          // Drawer Footer: strictly "Created by Piglix Labs"
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF080D14),
              border: Border(
                top: BorderSide(color: Color(0xFF1E293B), width: 1.0),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF22C55E),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 12.5,
                        letterSpacing: 0.3,
                      ),
                      children: [
                        TextSpan(
                          text: 'Created by ',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: 'Piglix Labs',
                          style: TextStyle(
                            color: Color(0xFF22C55E),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1722),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B), width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: iconColor.withOpacity(0.15),
          highlightColor: iconColor.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: iconColor.withOpacity(0.3), width: 1),
                  ),
                  child: Icon(icon, color: iconColor, size: 19),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF475569),
                  size: 13,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
