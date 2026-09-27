import 'package:flutter/material.dart';
import '../models/vending_state.dart';
import '../theme/app_theme.dart';

/// Shows the cooking/dispense progress dialog, then transitions to the
/// outcome dialog once the process finishes (Rules 19-26).
void showDispenseDialog(BuildContext context, VendingState state) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          // Kick off dispensing exactly once when dialog first builds.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (state.processOutcome == ProcessOutcome.dispensingHot ||
                state.processOutcome == ProcessOutcome.dispensingDry) {
              return; // already started
            }
            state.startDispense(
              () => setState(() {}),
              () {
                // finished -> swap this dialog for the outcome dialog
                Navigator.of(ctx).pop();
                _showOutcomeDialog(context, state);
              },
            );
          });

          final isDone = state.processOutcome != ProcessOutcome.dispensingHot &&
              state.processOutcome != ProcessOutcome.dispensingDry &&
              state.processOutcome != ProcessOutcome.none;

          return AlertDialog(
            backgroundColor: AppColors.primaryDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: SizedBox(
              width: 280,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.soup_kitchen, size: 48, color: AppColors.mintAccent),
                  const SizedBox(height: 12),
                  const Text(
                    'กำลังปรุง...',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: isDone ? 1 : state.dispenseProgress / 100,
                      minHeight: 10,
                      backgroundColor: Colors.white24,
                      color: AppColors.brightGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${state.dispenseProgress.toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void _showOutcomeDialog(BuildContext context, VendingState state) {
  late String title;
  late String message;
  late IconData icon;
  late Color color;
  late String ruleCode;

  switch (state.processOutcome) {
    case ProcessOutcome.successHot:
      title = 'ได้รับสินค้าพร้อมรับประทาน';
      message = 'ปรุงน้ำร้อนเสร็จสิ้น 100% กรุณารับบะหมี่ที่ช่องรับสินค้า';
      icon = Icons.ramen_dining;
      color = AppColors.brightGreen;
      ruleCode = 'Rule 21: U';
      break;
    case ProcessOutcome.successDry:
      title = 'ได้รับบะหมี่ถ้วยแบบแห้ง';
      message = 'จ่ายสินค้าสำหรับนำกลับบ้านเรียบร้อยแล้ว';
      icon = Icons.takeout_dining;
      color = AppColors.brightGreen;
      ruleCode = 'Rule 22: V';
      break;
    case ProcessOutcome.emergencyError:
      title = 'ระบบขัดข้องขณะกำลังปรุง';
      message = 'เครื่องหยุดทำงานฉุกเฉิน ระบบจะทำการคืนเงินให้ท่านทั้งหมด';
      icon = Icons.error_outline;
      color = AppColors.dangerRed;
      ruleCode = 'Rule 25: Y';
      break;
    default:
      title = 'เสร็จสิ้น';
      message = 'ขอบคุณที่ใช้บริการ';
      icon = Icons.check_circle_outline;
      color = AppColors.brightGreen;
      ruleCode = '';
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: color),
              const SizedBox(height: 12),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              if (ruleCode.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(ruleCode, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
              if (state.hasChangeToReturn) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warningAmber.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'กรุณารับเงินทอนที่ช่องเงินทอน (Rule 23: W)',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text('เงินทอน: ${state.change.toStringAsFixed(0)} บาท'),
                      Text(
                        _formatBreakdown(state.change),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
              if (state.processOutcome == ProcessOutcome.emergencyError) ...[
                const SizedBox(height: 12),
                Text(
                  'คืนเงินทั้งหมด ${(state.qrPaid ? state.totalPrice : state.insertedCash).toStringAsFixed(0)} บาท',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    state.resetOrder();
                    Navigator.of(ctx).pop(); // close outcome dialog
                    Navigator.of(context).popUntil((r) => r.isFirst); // back home
                  },
                  child: const Text('ขอบคุณที่ใช้บริการ'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

String _formatBreakdown(double amount) {
  final breakdown = VendingState.breakIntoDenominations(amount);
  if (breakdown.isEmpty) return '';
  return breakdown.entries
      .map((e) => '${e.value} x ${e.key.toStringAsFixed(0)}฿')
      .join('  ');
}
