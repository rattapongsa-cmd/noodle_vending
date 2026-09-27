import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vending_state.dart';
import '../theme/app_theme.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  String _pin = '';
  String? _error;

  void _tap(String digit) {
    if (_pin.length >= 6) return;
    setState(() {
      _pin += digit;
      _error = null;
    });
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _submit() {
    final state = context.read<VendingState>();
    final ok = state.adminLogin(_pin);
    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } else {
      setState(() {
        _error = 'รหัส PIN ไม่ถูกต้อง';
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('เข้าสู่ระบบผู้ดูแล'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_person, size: 56, color: AppColors.mintAccent),
                const SizedBox(height: 12),
                const Text(
                  'กรุณาป้อนรหัส PIN ผู้ดูแลระบบ',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (i) {
                    final filled = i < _pin.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled ? AppColors.brightGreen : Colors.white24,
                      ),
                    );
                  }),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.dangerRed)),
                ],
                const SizedBox(height: 24),
                _PinPad(onDigit: _tap, onBackspace: _backspace),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _pin.isNotEmpty ? _submit : null,
                    child: const Text('เข้าสู่ระบบ'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'PIN ทดสอบ: 8888 หรือ 1234',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PinPad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  const _PinPad({required this.onDigit, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: keys.map((k) {
        if (k.isEmpty) return const SizedBox.shrink();
        return Material(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => k == '⌫' ? onBackspace() : onDigit(k),
            child: Center(
              child: Text(
                k,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
