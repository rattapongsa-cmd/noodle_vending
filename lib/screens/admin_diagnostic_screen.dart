import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vending_state.dart';
import '../theme/app_theme.dart';

class AdminDiagnosticScreen extends StatelessWidget {
  const AdminDiagnosticScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VendingState>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: 'สถานะเครื่องโดยรวม',
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    state.isServiceAvailable ? Icons.check_circle : Icons.error,
                    color: state.isServiceAvailable
                        ? AppColors.brightGreen
                        : AppColors.dangerRed,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.isServiceAvailable
                          ? 'พร้อมให้บริการ (Rule 1: A)'
                          : 'งดให้บริการ (Rule 2: B / Rule 26: Z)',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('จำลองเครื่องเสีย (machineBroken)'),
                subtitle: const Text('ทดสอบ Rule 2 / Rule 26'),
                value: state.machineStatus == MachineStatus.broken,
                activeColor: AppColors.dangerRed,
                onChanged: (v) => state.adminSetMachineBroken(v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'อุณหภูมิน้ำร้อน (Hot Water Temp)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    state.waterHeaterOk ? Icons.local_fire_department : Icons.warning,
                    color: state.waterHeaterOk
                        ? AppColors.brightGreen
                        : AppColors.warningAmber,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${state.hotWaterTemp.toStringAsFixed(0)} °C',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.waterHeaterOk
                        ? 'พร้อมทำงาน'
                        : 'ต่ำกว่า ${VendingState.kMinHotWaterTemp.toStringAsFixed(0)}°C ไม่พร้อม',
                    style: TextStyle(
                      color: state.waterHeaterOk
                          ? AppColors.brightGreen
                          : AppColors.dangerRed,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Slider(
                value: state.hotWaterTemp.clamp(0, 100),
                min: 0,
                max: 100,
                divisions: 100,
                activeColor: AppColors.brightGreen,
                label: '${state.hotWaterTemp.toStringAsFixed(0)}°C',
                onChanged: (v) => state.adminSetHotWaterTemp(v),
              ),
              Text(
                'เกณฑ์ขั้นต่ำ ${VendingState.kMinHotWaterTemp.toStringAsFixed(0)}°C — ต่ำกว่านี้ถือว่าน้ำร้อนไม่พร้อม',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'ระดับน้ำ/วัตถุดิบคงเหลือ',
          child: Column(
            children: [
              _LevelSlider(
                label: 'ระดับน้ำในแทงก์',
                icon: Icons.water_drop,
                value: state.waterTankLevel,
                onChanged: state.adminSetWaterTankLevel,
              ),
              _LevelSlider(
                label: 'ชีสแผ่นคงเหลือ',
                icon: Icons.egg_alt_outlined,
                value: state.cheeseStock,
                onChanged: state.adminSetCheeseStock,
              ),
              _LevelSlider(
                label: 'ไข่ออนเซ็นคงเหลือ',
                icon: Icons.egg_outlined,
                value: state.eggStock,
                onChanged: state.adminSetEggStock,
              ),
              _LevelSlider(
                label: 'ช้อนส้อมคงเหลือ',
                icon: Icons.restaurant,
                value: state.spoonForkStock,
                onChanged: state.adminSetSpoonForkStock,
              ),
              const SizedBox(height: 4),
              const Text(
                'หมายเหตุ: หากชีส/ไข่หมด (0%) ตัวเลือกท็อปปิ้งนั้นจะถูกปิดใช้งานอัตโนมัติในหน้าลูกค้า',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _confirmReset(context, state),
            icon: const Icon(Icons.restart_alt, color: AppColors.dangerRed),
            label: const Text('รีเซ็ตตู้ทั้งหมด',
                style: TextStyle(color: AppColors.dangerRed)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.dangerRed),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmReset(BuildContext context, VendingState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการรีเซ็ตตู้'),
        content: const Text(
            'ระบบจะคืนค่าฮาร์ดแวร์ เงินทอนสำรอง และรายการสั่งซื้อปัจจุบันทั้งหมดกลับเป็นค่าเริ่มต้น'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              state.resetMachine();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed),
            child: const Text('รีเซ็ต'),
          ),
        ],
      ),
    );
  }
}

class _LevelSlider extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  final ValueChanged<double> onChanged;
  const _LevelSlider({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  Color get _color {
    if (value <= 15) return AppColors.dangerRed;
    if (value <= 40) return AppColors.warningAmber;
    return AppColors.brightGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _color),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              activeColor: _color,
              label: '${value.toStringAsFixed(0)}%',
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 42,
            child: Text('${value.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 12, color: _color, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
