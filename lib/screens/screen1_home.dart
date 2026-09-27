import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vending_state.dart';
import '../models/noodle.dart';
import '../theme/app_theme.dart';
import 'screen2_topping.dart';
import 'admin_login_screen.dart';
import 'admin_dashboard_screen.dart';

class Screen1Home extends StatefulWidget {
  const Screen1Home({Key? key}) : super(key: key);

  @override
  State<Screen1Home> createState() => _Screen1HomeState();
}

class _Screen1HomeState extends State<Screen1Home> {
  String _category = 'ทั้งหมด';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VendingState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ตู้ขายบะหมี่กึ่งสำเร็จรูปอัตโนมัติ'),
        actions: [
          IconButton(
            tooltip: 'สำหรับผู้ดูแลระบบ',
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () => _openAdmin(context, state),
          ),
        ],
      ),
      body: Column(
        children: [
          _StatusHeader(state: state),
          if (state.soldOutMessage != null)
            Container(
              width: double.infinity,
              color: AppColors.dangerRed.withOpacity(0.12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.block, color: AppColors.dangerRed, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.soldOutMessage!,
                      style: const TextStyle(color: AppColors.dangerRed),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: state.isServiceAvailable
                ? Column(
                    children: [
                      _CategoryBar(
                        selected: _category,
                        onSelect: (c) => setState(() => _category = c),
                      ),
                      Expanded(child: _FlavorGrid(state: state, category: _category)),
                    ],
                  )
                : const _OutOfServiceView(),
          ),
        ],
      ),
    );
  }

  void _openAdmin(BuildContext context, VendingState state) {
    if (state.isAdminLoggedIn) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
      );
    }
  }
}

class _StatusHeader extends StatelessWidget {
  final VendingState state;
  const _StatusHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final ok = state.isServiceAvailable;
    return Container(
      width: double.infinity,
      color: AppColors.primaryDark,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.warning_amber_rounded,
            color: ok ? AppColors.mintAccent : AppColors.warningAmber,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ok
                  ? 'พร้อมทำงาน (Rule 1: A)'
                  : 'แจ้งเตือน: เครื่องเสีย/ระบบน้ำร้อนขัดข้อง (Rule 2: B)',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'จำนวนเงิน: ${state.insertedCash.toStringAsFixed(0)} บาท',
              style: const TextStyle(color: AppColors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutOfServiceView extends StatelessWidget {
  const _OutOfServiceView();

  @override
  Widget build(BuildContext context) {
    // Rule 26 (Z): lock screen, show out-of-service message
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 72, color: AppColors.dangerRed),
            const SizedBox(height: 16),
            const Text(
              'ตู้งดให้บริการชั่วคราว',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'ระบบขัดข้อง (Rule 26: Z) กรุณาติดต่อเจ้าหน้าที่',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _CategoryBar({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final cats = ['ทั้งหมด', ...kNoodleCategories];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = cats[i];
          final isSelected = c == selected;
          return ChoiceChip(
            label: Text(c, style: const TextStyle(fontSize: 12)),
            selected: isSelected,
            selectedColor: AppColors.brightGreen,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.primaryDark,
            ),
            onSelected: (_) => onSelect(c),
          );
        },
      ),
    );
  }
}

class _FlavorGrid extends StatelessWidget {
  final VendingState state;
  final String category;
  const _FlavorGrid({required this.state, required this.category});

  @override
  Widget build(BuildContext context) {
    final items = category == 'ทั้งหมด'
        ? state.noodles
        : state.noodles.where((n) => n.category == category).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'เมนูทั้งหมด ${items.length} รายการ',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 900
                    ? 4
                    : constraints.maxWidth > 600
                        ? 3
                        : 2;
                return GridView.builder(
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, i) {
                    return _FlavorCard(noodle: items[i], state: state);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FlavorCard extends StatelessWidget {
  final NoodleItem noodle;
  final VendingState state;
  const _FlavorCard({required this.noodle, required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: AppColors.lightMintBg,
                  child: noodle.imageUrl.isNotEmpty
                      ? Image.network(
                          noodle.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => Center(
                            child: Icon(
                              Icons.ramen_dining,
                              size: 40,
                              color: noodle.soldOut
                                  ? Colors.grey
                                  : AppColors.primaryGreen,
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.ramen_dining,
                            size: 40,
                            color: noodle.soldOut
                                ? Colors.grey
                                : AppColors.primaryGreen,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              noodle.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              'ราคา ${noodle.price} บาท',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.primaryGreen, fontSize: 12),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: noodle.soldOut
                  ? ElevatedButton.icon(
                      onPressed: () => state.selectFlavor(noodle),
                      icon: const Icon(Icons.do_not_disturb_alt, size: 16),
                      label: const Text('สินค้าหมด', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () {
                        final ok = state.selectFlavor(noodle);
                        if (ok) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const Screen2Topping(),
                            ),
                          );
                        }
                      },
                      child: const Text('กดเลือก', style: TextStyle(fontSize: 12)),
                    ),
            ),
            const SizedBox(height: 2),
            Text(
              noodle.soldOut ? 'Rule 16: P' : (noodle.ruleCode.isNotEmpty ? noodle.ruleCode : noodle.category),
              style: const TextStyle(fontSize: 9, color: Colors.grey),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
