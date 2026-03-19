import 'package:casaly/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/glass_bottom_navigation.dart';
import '../../../dorm/presentation/screens/dorm_dashboard_screen.dart';
import '../../../user_profile/presentation/screens/user_profile_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DormDashboardScreen(), // Home
    const _ChatScreen(), // Chat
    const _SocialScreen(), // Social
    const SettingsScreen(), // Settings
    const UserProfileScreen(), // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      extendBody: true,
      bottomNavigationBar: GlassBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// Placeholder screens for Chat and Social
class _ChatScreen extends StatelessWidget {
  const _ChatScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chat', style: TextStyle(color: Color(0xFF4A9E60))),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Color(0xFF4A9E60)),
            SizedBox(height: 16),
            Text(
              'Chat Feature',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A9E60),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: TextStyle(fontSize: 16, color: Color(0xFF5A4E42)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialScreen extends StatelessWidget {
  const _SocialScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Social', style: TextStyle(color: Color(0xFF4A9E60))),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_outlined, size: 64, color: Color(0xFF4A9E60)),
            SizedBox(height: 16),
            Text(
              'Social Features',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A9E60),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: TextStyle(fontSize: 16, color: Color(0xFF5A4E42)),
            ),
          ],
        ),
      ),
    );
  }
}
