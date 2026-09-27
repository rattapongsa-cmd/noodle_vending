import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vending_state.dart';
import '../theme/app_theme.dart';
import 'admin_diagnostic_screen.dart';
import 'admin_cash_screen.dart';
import 'admin_sales_screen.dart';
import 'admin_menu_management_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VendingState>();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('แผงควบคุมผู้ดูแลระบบ'),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.mintAccent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(icon: Icon(Icons.handyman_outlined), text: 'ระบบฮาร์ดแวร์'),
              Tab(icon: Icon(Icons.payments_outlined), text: 'เงินทอน'),
              Tab(icon: Icon(Icons.bar_chart), text: 'ยอดขาย'),
              Tab(icon: Icon(Icons.restaurant_menu), text: 'จัดการเมนู'),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'ออกจากระบบ',
              icon: const Icon(Icons.logout),
              onPressed: () {
                state.adminLogout();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            AdminDiagnosticScreen(),
            AdminCashScreen(),
            AdminSalesScreen(),
            AdminMenuManagementScreen(),
          ],
        ),
      ),
    );
  }
}
