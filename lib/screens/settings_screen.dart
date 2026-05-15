import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/settings/settings_bloc.dart';
import '../blocs/settings/settings_event.dart';
import '../blocs/settings/settings_state.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc()..add(LoadSettingsEvent()),
      child: const SettingsScreenView(),
    );
  }
}

class SettingsScreenView extends StatefulWidget {
  const SettingsScreenView({super.key});

  @override
  State<SettingsScreenView> createState() => _SettingsScreenViewState();
}

class _SettingsScreenViewState extends State<SettingsScreenView> {

  void _showDeactivateConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa tài khoản', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: const Text('Bạn có chắc chắn muốn xóa (vô hiệu hóa) tài khoản này không? Thao tác này không thể hoàn tác.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SettingsBloc>().add(DeactivateAccountEvent());
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is AccountDeactivated) {
          AuthService.clearAuthData();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        } else if (state is AccountDeactivationError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8), // Nền xám nhạt
        appBar: AppBar(
          title: const Text('Cài đặt', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            bool push = true;
            bool email = false;
            bool dark = false;

            if (state is SettingsLoaded) {
              push = state.pushNotifications;
              email = state.emailNotifications;
              dark = state.darkMode;
            }

            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  children: [
                    _buildSectionHeader('Tùy chỉnh thông báo'),
                    _buildSettingsCard(
                      children: [
                        _buildSwitchTile('Thông báo đẩy (Push)', 'Nhận thông báo khóa học mới trên máy', push, (val) => context.read<SettingsBloc>().add(TogglePushNotificationEvent(val))),
                        const Divider(height: 1, indent: 16),
                        _buildSwitchTile('Thông báo Email', 'Nhận email khuyến mãi & bài tập', email, (val) => context.read<SettingsBloc>().add(ToggleEmailNotificationEvent(val))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSectionHeader('Giao diện & Hệ thống'),
                    _buildSettingsCard(
                      children: [
                        _buildSwitchTile('Chế độ tối (Dark Mode)', 'Giảm mỏi mắt khi học ban đêm', dark, (val) => context.read<SettingsBloc>().add(ToggleDarkModeEvent(val))),
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
                          onTap: () => _showDeactivateConfirmDialog(context),
                        ),
                      ],
                    ),
                  ],
                ),
                if (state is AccountDeactivating)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black26,
                      child: const Center(child: CircularProgressIndicator(color: Color(0xFFFFCC33))),
                    ),
                  ),
              ],
            );
          },
        ),
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