import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vending_state.dart';
import '../models/noodle.dart';
import '../theme/app_theme.dart';

class AdminMenuManagementScreen extends StatefulWidget {
  const AdminMenuManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminMenuManagementScreen> createState() =>
      _AdminMenuManagementScreenState();
}

class _AdminMenuManagementScreenState extends State<AdminMenuManagementScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VendingState>();
    final items = state.noodles
        .where((n) =>
            _query.isEmpty ||
            n.name.toLowerCase().contains(_query.toLowerCase()) ||
            n.brand.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, state, null),
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มเมนู'),
        backgroundColor: AppColors.brightGreen,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'ค้นหาเมนู/ยี่ห้อ...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${state.noodles.length} รายการ',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final n = items[i];
                return _MenuRow(
                  item: n,
                  onEdit: () => _openEditor(context, state, n),
                  onDelete: () => _confirmDelete(context, state, n),
                  onToggleStock: () => state.toggleOutOfStock(n.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, VendingState state, NoodleItem n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ลบเมนูนี้?'),
        content: Text('ต้องการลบ "${n.name}" ออกจากรายการหรือไม่'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () {
              state.deleteNoodleItem(n.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  void _openEditor(BuildContext context, VendingState state, NoodleItem? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MenuEditorSheet(state: state, existing: existing),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final NoodleItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStock;
  const _MenuRow({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStock,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 52,
                height: 52,
                child: item.imageUrl.isNotEmpty
                    ? Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.lightMintBg,
                          child: const Icon(Icons.ramen_dining, color: AppColors.primaryGreen),
                        ),
                      )
                    : Container(
                        color: AppColors.lightMintBg,
                        child: const Icon(Icons.ramen_dining, color: AppColors.primaryGreen),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                    '${item.brand.isNotEmpty ? "${item.brand} • " : ""}${item.category} • ${item.price} บาท',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.ruleBinding != null)
                    Text(item.ruleBinding!,
                        style: const TextStyle(fontSize: 10, color: AppColors.primaryGreen)),
                ],
              ),
            ),
            Column(
              children: [
                Switch(
                  value: !item.isOutOfStock,
                  activeColor: AppColors.brightGreen,
                  onChanged: (_) => onToggleStock(),
                ),
                Text(item.isOutOfStock ? 'หมด' : 'มีของ',
                    style: TextStyle(
                        fontSize: 10,
                        color: item.isOutOfStock ? AppColors.dangerRed : AppColors.brightGreen)),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.dangerRed),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuEditorSheet extends StatefulWidget {
  final VendingState state;
  final NoodleItem? existing;
  const _MenuEditorSheet({required this.state, this.existing});

  @override
  State<_MenuEditorSheet> createState() => _MenuEditorSheetState();
}

class _MenuEditorSheetState extends State<_MenuEditorSheet> {
  late TextEditingController _name;
  late TextEditingController _brand;
  late TextEditingController _price;
  late TextEditingController _imageUrl;
  late String _category;
  bool _outOfStock = false;

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _brand = TextEditingController(text: e?.brand ?? '');
    _price = TextEditingController(text: e != null ? e.price.toString() : '');
    _imageUrl = TextEditingController(text: e?.imageUrl ?? '');
    _category = e?.category ?? kNoodleCategories.first;
    _outOfStock = e?.isOutOfStock ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _price.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    final price = int.tryParse(_price.text.trim());
    if (name.isEmpty || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกชื่อเมนูและราคาให้ถูกต้อง')),
      );
      return;
    }

    if (isEditing) {
      widget.state.updateNoodleItem(widget.existing!.copyWith(
        name: name,
        brand: _brand.text.trim(),
        price: price,
        imageUrl: _imageUrl.text.trim(),
        category: _category,
        isOutOfStock: _outOfStock,
      ));
    } else {
      widget.state.addNoodleItem(NoodleItem(
        id: widget.state.generateNoodleId(),
        name: name,
        brand: _brand.text.trim(),
        price: price,
        imageUrl: _imageUrl.text.trim(),
        category: _category,
        isOutOfStock: _outOfStock,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEditing ? 'แก้ไขเมนู' : 'เพิ่มเมนูใหม่',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'ชื่อเมนู', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _brand,
                decoration: const InputDecoration(labelText: 'ยี่ห้อ (Brand)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _price,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'ราคา (บาท)', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(labelText: 'หมวดหมู่', border: OutlineInputBorder()),
                      items: kNoodleCategories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (v) => setState(() => _category = v ?? _category),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _imageUrl,
                decoration: const InputDecoration(
                  labelText: 'Image URL (หรือ asset path)',
                  border: OutlineInputBorder(),
                  hintText: 'https://... หรือ assets/images/xxx.png',
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('สินค้าหมด (Rule 16: P)'),
                value: _outOfStock,
                activeColor: AppColors.dangerRed,
                onChanged: (v) => setState(() => _outOfStock = v),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ยกเลิก'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      child: Text(isEditing ? 'บันทึกการแก้ไข' : 'เพิ่มเมนู'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
