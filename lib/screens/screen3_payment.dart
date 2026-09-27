import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/vending_state.dart';
import '../theme/app_theme.dart';
import '../widgets/dispense_dialog.dart';

class Screen3Payment extends StatelessWidget {
  const Screen3Payment({Key? key}) : super(key: key);

  static const List<double> _coins = [5, 10];
  static const List<double> _notes = [20, 50, 100];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VendingState>();

    return Scaffold(
      appBar: AppBar(title: const Text('ชำระเงิน')),
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
                    Expanded(
                      child: _AmountBox(
                        label: 'ยอดที่ต้องชำระ',
                        value: '${state.totalPrice.toStringAsFixed(0)} บาท',
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _AmountBox(
                        label: 'ยอดเงินที่ใส่แล้ว',
                        value: '${state.insertedCash.toStringAsFixed(0)} บาท',
                        color: AppColors.mintAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth > 620;
              final qrColumn = _QrPaySection(state: state);
              final cashColumn = _CashSection(state: state, coins: _coins, notes: _notes);
              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: qrColumn),
                    const SizedBox(width: 16),
                    Expanded(child: cashColumn),
                  ],
                );
              }
              return Column(
                children: [
                  qrColumn,
                  const SizedBox(height: 16),
                  cashColumn,
                ],
              );
            }),
            const SizedBox(height: 16),
            _CashStatusBanner(state: state),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      state.cancelOrder(); // Rule 18: R
                      _showCancelledDialog(context, state);
                    },
                    icon: const Icon(Icons.close, color: AppColors.dangerRed),
                    label: const Text(
                      'ยกเลิก/ขอคืนเงิน',
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
                    onPressed: state.canStart
                        ? () => showDispenseDialog(context, state)
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      state.heatMode == HeatMode.hot
                          ? 'START (Rule 19: S)'
                          : 'START (Rule 20: T)',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelledDialog(BuildContext context, VendingState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยกเลิกรายการ (Rule 24: X)'),
        content: Text(
          state.insertedCash > 0
              ? 'ระบบคืนเงินสด ${state.insertedCash.toStringAsFixed(0)} บาท ครบตามจำนวนที่ใส่'
              : 'ยกเลิกรายการเรียบร้อยแล้ว',
        ),
        actions: [
          TextButton(
            onPressed: () {
              state.acknowledgeCancelAndReset();
              Navigator.of(ctx).pop(); // close dialog
              Navigator.of(context).popUntil((r) => r.isFirst); // back home
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }
}

class _AmountBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _AmountBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _QrPaySection extends StatelessWidget {
  final VendingState state;
  const _QrPaySection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('PromptPay / Thai QR',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            QrImageView(
              data: 'PROMPTPAY|AMOUNT=${state.totalPrice.toStringAsFixed(2)}',
              size: 140,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 8),
            Text('สแกนยอดพอดี ${state.totalPrice.toStringAsFixed(0)} บาท',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: state.qrPaid ? null : () => state.payWithQR(),
                icon: Icon(state.qrPaid ? Icons.check : Icons.qr_code_scanner),
                label: Text(state.qrPaid ? 'จ่ายสำเร็จ (Rule 12: L)' : 'จำลองสแกนจ่าย'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CashSection extends StatelessWidget {
  final VendingState state;
  final List<double> coins;
  final List<double> notes;
  const _CashSection({required this.state, required this.coins, required this.notes});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ช่องหยอดเหรียญ/ธนบัตร',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text('เหรียญ', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: coins
                  .map((c) => _CoinChip(value: c, state: state))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Text('ธนบัตร', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: notes
                  .map((n) => _CoinChip(value: n, state: state))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoinChip extends StatelessWidget {
  final double value;
  final VendingState state;
  const _CoinChip({required this.value, required this.state});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      backgroundColor: AppColors.lightMintBg,
      avatar: const Icon(Icons.payments, size: 16, color: AppColors.primaryGreen),
      label: Text('${value.toStringAsFixed(0)}฿'),
      onPressed: state.qrPaid ? null : () => state.insertCash(value),
    );
  }
}

class _CashStatusBanner extends StatelessWidget {
  final VendingState state;
  const _CashStatusBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.qrPaid) return const SizedBox.shrink();

    String text;
    Color color;
    IconData icon;

    switch (state.cashStatus) {
      case CashStatus.insufficient:
        text = 'ใส่เงินไม่ครบ กรุณาใส่เพิ่ม (Rule 14: N)';
        color = AppColors.dangerRed;
        icon = Icons.error_outline;
        break;
      case CashStatus.exact:
        text = 'ใส่เงินครบพอดี พร้อมกด START (Rule 15: O)';
        color = AppColors.brightGreen;
        icon = Icons.check_circle_outline;
        break;
      case CashStatus.over:
        text =
            'ใส่เงินเกิน ${state.change.toStringAsFixed(0)} บาท จะได้รับเงินทอน (Rule 13: M)';
        color = AppColors.warningAmber;
        icon = Icons.info_outline;
        break;
      case CashStatus.empty:
        text = 'กรุณาสแกน QR หรือหยอดเงินสดเพื่อชำระเงิน';
        color = Colors.grey;
        icon = Icons.info_outline;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
                maxLines: 2),
          ),
        ],
      ),
    );
  }
}
