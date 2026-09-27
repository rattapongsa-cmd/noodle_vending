import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vending_state.dart';
import '../models/noodle.dart';
import '../theme/app_theme.dart';
import 'screen3_payment.dart';

class Screen2Topping extends StatelessWidget {
  const Screen2Topping({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VendingState>();
    final noodle = state.selectedNoodle;

    return Scaffold(
      appBar: AppBar(title: const Text('เลือกท็อปปิ้ง & รูปแบบ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.ramen_dining, color: AppColors.primaryGreen),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'รายการที่เลือก: ${noodle?.name ?? '-'}  (${noodle?.price.toStringAsFixed(0) ?? 0} บาท)',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('1. เลือกท็อปปิ้งเสริม (กดเลือก 1 ข้อ)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            Card(
              child: Column(
                children: Topping.values.map((t) {
                  final needsCheese = t == Topping.cheese || t == Topping.both;
                  final needsEgg = t == Topping.onsenEgg || t == Topping.both;
                  final unavailable = (needsCheese && !state.cheeseAvailable) ||
                      (needsEgg && !state.eggAvailable);
                  return RadioListTile<Topping>(
                    value: t,
                    groupValue: state.selectedTopping,
                    onChanged: unavailable ? null : (v) => state.selectTopping(v!),
                    activeColor: AppColors.brightGreen,
                    title: Text(
                      unavailable
                          ? '${t.label} (หมดสต็อก)'
                          : '${t.label} (+${t.price.toStringAsFixed(0)}฿)',
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(t.ruleCode,
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('2. เลือกรูปแบบการรับประทาน',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _HeatModeButton(
                    mode: HeatMode.hot,
                    state: state,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _HeatModeButton(
                    mode: HeatMode.dry,
                    state: state,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      state.cancelOrder(); // Rule 18: R
                      Navigator.of(context)
                          .popUntil((route) => route.isFirst);
                      state.acknowledgeCancelAndReset();
                    },
                    icon: const Icon(Icons.close, color: AppColors.dangerRed),
                    label: const Text(
                      'กดยกเลิกรายการ',
                      style: TextStyle(color: AppColors.dangerRed),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.dangerRed),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (noodle != null && state.heatMode != HeatMode.none)
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const Screen3Payment(),
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('ยืนยันไปชำระเงิน'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeatModeButton extends StatelessWidget {
  final HeatMode mode;
  final VendingState state;
  const _HeatModeButton({required this.mode, required this.state});

  @override
  Widget build(BuildContext context) {
    final selected = state.heatMode == mode;
    return InkWell(
      onTap: () => state.selectHeatMode(mode),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.brightGreen : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.brightGreen : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              mode.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? AppColors.white : AppColors.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mode.ruleCode,
              style: TextStyle(
                fontSize: 11,
                color: selected ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
