/// Dynamic noodle product model — supports 30+ menu items, images, categories
/// and CRUD from the Admin Menu Management screen.
class NoodleItem {
  final String id;
  String name;
  String brand;
  int price;
  String imageUrl; // Network Image URL or local asset path
  bool isOutOfStock; // Rule 16 (P)
  String category; // e.g. ต้มยำ/เผ็ด, รามยอนเกาหลี, วุ้นเส้น/เพื่อสุขภาพ
  String? ruleBinding; // e.g. "Rule 3: C" — only the first 3 seed items bind

  NoodleItem({
    required this.id,
    required this.name,
    this.brand = '',
    required this.price,
    this.imageUrl = '',
    this.isOutOfStock = false,
    this.category = 'อื่นๆ',
    this.ruleBinding,
  });

  // ---- Compatibility getters used by existing Screen 1 / 2 widgets ----
  bool get soldOut => isOutOfStock;
  String get ruleCode => ruleBinding ?? '';
  double get priceAsDouble => price.toDouble();

  NoodleItem copyWith({
    String? name,
    String? brand,
    int? price,
    String? imageUrl,
    bool? isOutOfStock,
    String? category,
    String? ruleBinding,
  }) {
    return NoodleItem(
      id: id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isOutOfStock: isOutOfStock ?? this.isOutOfStock,
      category: category ?? this.category,
      ruleBinding: ruleBinding ?? this.ruleBinding,
    );
  }
}

/// Backward-compatible alias so any old references to `Noodle` still work.
typedef Noodle = NoodleItem;

const List<String> kNoodleCategories = [
  'ต้มยำ/เผ็ด',
  'รามยอนเกาหลี',
  'วุ้นเส้น/เพื่อสุขภาพ',
  'ซุปใส',
  'ผัด/แห้ง',
  'นานาชาติ',
];

/// Seed menu of 30+ items. The first three keep their original Rule 3/4/5
/// bindings from the base spec; the rest are additional catalogue items
/// manageable from the Admin Menu Management screen.
List<NoodleItem> defaultNoodleMenu() {
  int seq = 0;
  String nextId() => 'n${(++seq).toString().padLeft(3, '0')}';
  NoodleItem item(
    String name,
    String brand,
    int price,
    String category, {
    bool soldOut = false,
    String? rule,
  }) {
    return NoodleItem(
      id: nextId(),
      name: name,
      brand: brand,
      price: price,
      category: category,
      isOutOfStock: soldOut,
      ruleBinding: rule,
      imageUrl:
          'https://placehold.co/300x300/10B981/FFFFFF?text=${Uri.encodeComponent(brand.isEmpty ? name : brand)}',
    );
  }

  return [
    // --- Original Rule-bound seed items ---
    item('มาม่า ต้มยำกุ้งน้ำข้น', 'มาม่า', 20, 'ต้มยำ/เผ็ด', rule: 'Rule 3: C'),
    item('ไวไว รสหมูสับ', 'ไวไว', 20, 'ผัด/แห้ง', rule: 'Rule 4: D'),
    item('รามยอนเกาหลี รสเผ็ด (Shin Ramyun)', 'Nongshim', 35, 'รามยอนเกาหลี',
        soldOut: true, rule: 'Rule 5: E'),

    // --- ต้มยำ/เผ็ด ---
    item('มาม่า ต้มยำกุ้งน้ำใส', 'มาม่า', 20, 'ต้มยำ/เผ็ด'),
    item('ยำยำ ต้มยำกุ้ง', 'ยำยำ', 20, 'ต้มยำ/เผ็ด'),
    item('ไวไว ต้มยำกุ้ง', 'ไวไว', 20, 'ต้มยำ/เผ็ด'),
    item('มาม่า OK ต้มยำกุ้งคัพ', 'มาม่า', 22, 'ต้มยำ/เผ็ด'),
    item('นิสชิน ต้มยำซีฟู้ด', 'Nissin', 25, 'ต้มยำ/เผ็ด'),

    // --- รามยอนเกาหลี ---
    item('Samyang บูดัก บ๊อกกึม เผ็ดมาก', 'Samyang', 45, 'รามยอนเกาหลี'),
    item('Samyang ชีสบูดัก', 'Samyang', 48, 'รามยอนเกาหลี'),
    item('Nongshim ชาปาเก็ตติ', 'Nongshim', 40, 'รามยอนเกาหลี'),
    item('Ottogi จินราเมง', 'Ottogi', 38, 'รามยอนเกาหลี'),
    item('Paldo หมูกระทะโบกึม', 'Paldo', 42, 'รามยอนเกาหลี'),
    item('Nongshim คิมจิราเมง', 'Nongshim', 40, 'รามยอนเกาหลี', soldOut: true),

    // --- วุ้นเส้น/เพื่อสุขภาพ ---
    item('วุ้นเส้นต้มยำกุ้ง ไฟเบอร์วัน', 'ไฟเบอร์วัน', 25, 'วุ้นเส้น/เพื่อสุขภาพ'),
    item('เส้นหมี่โฮลวีทซุปไก่', 'ควิก', 28, 'วุ้นเส้น/เพื่อสุขภาพ'),
    item('บะหมี่ข้าวโอ๊ตน้ำใส', 'ควิก', 30, 'วุ้นเส้น/เพื่อสุขภาพ'),
    item('วุ้นเส้นซุปเห็ด', 'ไวไว', 25, 'วุ้นเส้น/เพื่อสุขภาพ'),

    // --- ซุปใส ---
    item('มาม่า หมูสับซุปใส', 'มาม่า', 20, 'ซุปใส'),
    item('ยำยำ ซุปไก่สาหร่าย', 'ยำยำ', 20, 'ซุปใส'),
    item('นิสชิน ซุปไก่ต้นหอม', 'Nissin', 26, 'ซุปใส'),
    item('ไวไว ซุปเป็ดตุ๋น', 'ไวไว', 22, 'ซุปใส'),

    // --- ผัด/แห้ง ---
    item('มาม่า ผัดไทย', 'มาม่า', 22, 'ผัด/แห้ง'),
    item('ยำยำ จับกัง ผัดขี้เมา', 'ยำยำ', 22, 'ผัด/แห้ง'),
    item('ไวไว ผัดซีอิ๊ว', 'ไวไว', 22, 'ผัด/แห้ง'),
    item('มาม่า คัพ ผัดกะเพราหมูสับ', 'มาม่า', 25, 'ผัด/แห้ง'),

    // --- นานาชาติ ---
    item('Nissin Demae Ramen โชยุ', 'Nissin', 32, 'นานาชาติ'),
    item('Myojo Chukazanmai หมูทงคตสึ', 'Myojo', 36, 'นานาชาติ'),
    item('Indomie Mi Goreng', 'Indomie', 24, 'นานาชาติ'),
    item('Ottogi จาจังเมียน', 'Ottogi', 40, 'นานาชาติ'),
    item('Paldo Bibim Naengmyeon เย็น', 'Paldo', 42, 'นานาชาติ', soldOut: true),
    item('Nongshim Neoguri อูดงเผ็ด', 'Nongshim', 40, 'นานาชาติ'),
    item('Samyang การ์โบนาร่า บูดัก', 'Samyang', 48, 'นานาชาติ'),
  ];
}

/// Topping options (Rules 6, 7, 8, 9)
enum Topping { none, cheese, onsenEgg, both }

extension ToppingX on Topping {
  String get label {
    switch (this) {
      case Topping.none:
        return 'ธรรมดา / ไม่เพิ่ม';
      case Topping.cheese:
        return 'เพิ่มชีสแผ่น';
      case Topping.onsenEgg:
        return 'เพิ่มไข่ออนเซ็น';
      case Topping.both:
        return 'เพิ่มทั้งชีสและไข่ออนเซ็น';
    }
  }

  double get price {
    switch (this) {
      case Topping.none:
        return 0;
      case Topping.cheese:
        return 10;
      case Topping.onsenEgg:
        return 10;
      case Topping.both:
        return 20;
    }
  }

  String get ruleCode {
    switch (this) {
      case Topping.none:
        return '';
      case Topping.cheese:
        return '';
      case Topping.onsenEgg:
        return '';
      case Topping.both:
        return '' ;
    }
  }
}

/// Heat mode (Rules 10, 11)
enum HeatMode { none, hot, dry }

extension HeatModeX on HeatMode {
  String get label {
    switch (this) {
      case HeatMode.hot:
        return '🔥 เติมน้ำร้อนพร้อมทาน';
      case HeatMode.dry:
        return '📦 แบบแห้ง นำกลับบ้าน';
      case HeatMode.none:
        return '';
    }
  }

  String get ruleCode {
    switch (this) {
      case HeatMode.hot:
        return 'Rule 10: J';
      case HeatMode.dry:
        return 'Rule 11: K';
      case HeatMode.none:
        return '';
    }
  }
}
