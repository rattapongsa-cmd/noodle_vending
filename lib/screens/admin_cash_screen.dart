import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vending_state.dart';
import '../theme/app_theme.dart';

class AdminCashScreen extends StatelessWidget {
  const AdminCashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VendingState>();
    final reserve = state.cashReserve;
    final totalReserve =
        reserve.entries.fold<double>(0, (sum, e) => sum + e.key * e.value);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: AppColors.primaryGreen,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('เงินสำรองทอนรวมทั้งหมด',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(
                        '${totalReserve.toStringAsFixed(0)} บาท',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('รายการเหรียญ/ธนบัตรสำรอง',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                ...kDenominations.map((d) {
                  final count = reserve[d] ?? 0;
                  final isCoin = d <= 10;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          isCoin ? Icons.circle : Icons.receipt_long,
                          size: 18,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${isCoin ? "เหรียญ" : "ธนบัตร"} ${d.toStringAsFixed(0)} บาท',
                          ),
                        ),
                        Text('x $count', style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 12),
                        Text(
                          '${(d * count).toStringAsFixed(0)} บ.',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  state.refillCashReserve();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('เติมเงินทอนสำรองเรียบร้อยแล้ว')),
                  );
                },
                icon: const Icon(Icons.add_card),
                label: const Text('เติมเงินทอนสำรอง'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _confirmResetMachine(context, state),
                icon: const Icon(Icons.restart_alt, color: AppColors.dangerRed),
                label: const Text('รีเซ็ตตู้', style: TextStyle(color: AppColors.dangerRed)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.dangerRed),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _confirmResetMachine(BuildContext context, VendingState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการรีเซ็ตตู้'),
        content: const Text('รีเซ็ตเงินทอนสำรองและสถานะฮาร์ดแวร์ทั้งหมดกลับค่าเริ่มต้น'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก')),
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
