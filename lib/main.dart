import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/vending_state.dart';
import 'screens/screen1_home.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const NoodleVendingApp());
}

class NoodleVendingApp extends StatelessWidget {
  const NoodleVendingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<VendingState>(create: (_) => VendingState()),
      ],
      child: MaterialApp(
        title: 'ตู้ขายบะหมี่กึ่งสำเร็จรูปอัตโนมัติ',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const Screen1Home(),
      ),
    );
  }
}
