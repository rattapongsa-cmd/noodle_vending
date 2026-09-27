import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vending_state.dart';
import '../theme/app_theme.dart';

class AdminSalesScreen extends StatelessWidget {
  const AdminSalesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VendingState>();
    final entries = state.salesCountByFlavorName.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'ยอดขายรวม',
                value: '${state.totalSalesAmount.toStringAsFixed(0)} บาท',
                icon: Icons.payments,
                color: AppColors.brightGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'จำนวนถ้วยที่ขาย',
                value: '${state.totalCupsSold} ถ้วย',
                icon: Icons.ramen_dining,
                color: AppColors.mintAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ยอดขายแยกตามรสชาติ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                if (entries.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text('ยังไม่มีการขายในรอบนี้',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ...entries.map((e) {
                    final ratio = state.totalCupsSold == 0
                        ? 0.0
                        : e.value / state.totalCupsSold;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(e.key,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13)),
                              ),
                              Text('${e.value} ถ้วย',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 8,
                              backgroundColor: AppColors.lightMintBg,
                              color: AppColors.brightGreen,
                            ),
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
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _confirmResetSales(context, state),
            icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.dangerRed),
            label: const Text('ล้างรายงานยอดขาย',
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

  void _confirmResetSales(BuildContext context, VendingState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ล้างรายงานยอดขาย'),
        content: const Text('ต้องการล้างสรุปยอดขายทั้งหมดหรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () {
              state.adminResetSales();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed),
            child: const Text('ล้างข้อมูล'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
