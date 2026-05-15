import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/course_service.dart';
import '../models/course_model.dart';
import '../models/user_profile_model.dart';
import 'login_screen.dart';
import 'change_password_screen.dart';
<<<<<<< Updated upstream
=======
import 'settings_screen.dart';
import 'transaction_history_screen.dart';
>>>>>>> Stashed changes

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) {
      setState(() => _user = user);
    }
  }

  void _logout() async {
    await AuthService.clearAuthData();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: const Color(0xFFFFCC33),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _user == null 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          Center(
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 60, color: Colors.grey),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E88E5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _user!.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              _user!.email,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
          const SizedBox(height: 32),
          _buildMenuSection(context),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
<<<<<<< Updated upstream
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildMenuItem(Icons.person_outline, 'Edit Profile', onTap: () {}),
          const Divider(height: 1, indent: 50),
          _buildMenuItem(Icons.lock_outline, 'Change Password', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
          }),
          const Divider(height: 1, indent: 50),
          _buildMenuItem(Icons.settings_outlined, 'Settings', onTap: () {}),
          const Divider(height: 1, indent: 50),
          _buildMenuItem(Icons.help_outline, 'Help & Support', onTap: () {}),
          const Divider(height: 1, indent: 50),
          _buildMenuItem(Icons.logout, 'Log Out', color: Colors.red, onTap: _logout),
        ],
=======
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03), // Đổ bóng cực mỏng, không loe loét
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildMenuItem(Icons.person_outline, 'Chỉnh sửa hồ sơ', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
            }),
            _buildDivider(),
            _buildMenuItem(Icons.lock_outline, 'Đổi mật khẩu', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
            }),
            _buildDivider(),
            _buildMenuItem(Icons.settings_outlined, 'Cài đặt hệ thống', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            }),
            _buildDivider(),
            _buildMenuItem(Icons.history_rounded, 'Lịch sử giao dịch', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionHistoryScreen()));
            }),
            _buildDivider(),
            _buildMenuItem(Icons.help_outline, 'Trợ giúp & Hỗ trợ', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
            }),
            _buildDivider(),
            _buildMenuItem(
              Icons.logout_rounded, 
              'Đăng xuất', 
              color: Colors.red, 
              hideArrow: true,
              onTap: _logout,
            ),
          ],
        ),
>>>>>>> Stashed changes
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {Color color = Colors.black87, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.black26),
      onTap: onTap,
    );
  }
}
