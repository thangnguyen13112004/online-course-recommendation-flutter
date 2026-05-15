import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Nền xám nhạt
      appBar: AppBar(
        title: const Text('Cài đặt', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildSectionHeader('Tùy chỉnh thông báo'),
          _buildSettingsCard(
            children: [
              _buildSwitchTile('Thông báo đẩy (Push)', 'Nhận thông báo khóa học mới trên máy', _pushNotifications, (val) => setState(() => _pushNotifications = val)),
              const Divider(height: 1, indent: 16),
              _buildSwitchTile('Thông báo Email', 'Nhận email khuyến mãi & bài tập', _emailNotifications, (val) => setState(() => _emailNotifications = val)),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Giao diện & Hệ thống'),
          _buildSettingsCard(
            children: [
              _buildSwitchTile('Chế độ tối (Dark Mode)', 'Giảm mỏi mắt khi học ban đêm', _darkMode, (val) => setState(() => _darkMode = val)),
              const Divider(height: 1, indent: 16),
              ListTile(
                title: const Text('Ngôn ngữ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                trailing: const Text('Tiếng Việt', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                onTap: () {}, // Sau này làm popup chọn ngôn ngữ
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('Khác'),
          _buildSettingsCard(
            children: [
              ListTile(
                title: const Text('Xóa tài khoản', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.red)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.red),
                onTap: () {}, // Thêm Alert cảnh báo xóa ở đây
              ),
            ],
          ),
        ],
      ),
    );
  }

Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      // Gọi .toUpperCase() thẳng vào biến title luôn
      child: Text(
        title.toUpperCase(), 
        style: TextStyle(
          fontSize: 13, 
          fontWeight: FontWeight.bold, 
          color: Colors.grey.shade600
        )
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      value: value,
      activeColor: const Color(0xFFFFCC33), // Trạng thái bật màu vàng
      onChanged: onChanged,
    );
  }
}