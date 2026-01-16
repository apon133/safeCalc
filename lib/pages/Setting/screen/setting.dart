import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'about_safecalc.dart';
import 'app_information_page.dart';
import 'change_log_page.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildSectionTitle('General'),
              _buildSettingsCard([
                _buildSettingTile(
                  context,
                  title: 'App Information',
                  icon: Icons.info_outline,
                  onTap: () => _navigateTo(context, const AppInformationPage()),
                ),
                _buildSettingTile(
                  context,
                  title: 'About safeCalc',
                  icon: Icons.help_outline,
                  onTap: () => _navigateTo(context, const AboutSafecalc()),
                ),
                _buildSettingTile(
                  context,
                  title: 'Changelog',
                  icon: Icons.history,
                  onTap: () => _navigateTo(context, const ChangeLogPage()),
                ),
              ]),
              const SizedBox(height: 20),
              _buildSectionTitle('Legal & Privacy'),
              _buildSettingsCard([
                _buildSettingTile(
                  context,
                  title: 'Privacy Policy',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () => _launchURL(
                      'https://sites.google.com/view/safecalc-pricey/home'),
                ),
                _buildSettingTile(
                  context,
                  title: 'Terms & Conditions',
                  icon: Icons.assignment_outlined,
                  onTap: () => _launchURL(
                      'https://sites.google.com/view/safecalc-terms/home'),
                ),
              ]),
              const SizedBox(height: 20),
              _buildSectionTitle('Community'),
              _buildSettingsCard([
                _buildSettingTile(
                  context,
                  title: 'Developer (apon133)',
                  icon: FontAwesomeIcons.github,
                  onTap: () => _launchURL('https://github.com/apon133'),
                ),
                _buildSettingTile(
                  context,
                  title: 'Telegram',
                  icon: Icons.telegram,
                  onTap: () => _launchURL('https://t.me/+-xBeTl30frgwNWI1'),
                ),
                _buildSettingTile(
                  context,
                  title: 'Share App',
                  icon: Icons.share_outlined,
                  onTap: () => Share.share(
                      'Check out safeCalc: https://www.github.com/apon133/safeCalc'),
                ),
              ]),
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Text(
                      'safeCalc v1.0.0',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Crafted by apon133',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: const Color(0xFF63FFDA).withOpacity(0.7),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.white70, size: 22),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (b) => page));
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
