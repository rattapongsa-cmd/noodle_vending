import 'dart:async';
import 'package:flutter/foundation.dart';
import 'noodle.dart';
export 'noodle.dart';

enum MachineStatus { ready, broken } // Rule 1 (A) / Rule 2 (B) + Rule 26 (Z)

enum CashStatus { empty, insufficient, exact, over } // Rule 14/15/13 (N/O/M)

enum PaymentMethod { none, qr, cash }

enum ProcessOutcome {
  none,
  dispensingHot, // Rule 19 (S) in progress
  dispensingDry, // Rule 20 (T) in progress
  successHot, // Rule 21 (U)
  successDry, // Rule 22 (V)
  changeReturned, // Rule 23 (W)
  cancelledRefund, // Rule 24 (X)
  emergencyError, // Rule 25 (Y)
  machineLocked, // Rule 26 (Z)
}

/// Denomination breakdown for cash handling (coins 5,10 / notes 20,50,100)
const List<double> kDenominations = [100, 50, 20, 10, 5];

/// Default reserve counts for the cash drawer (Admin > Cash Drawer Monitor)
Map<double, int> defaultCashReserve() => {
      100: 20,
      50: 20,
      20: 30,
      10: 40,
      5: 40,
    };

class VendingState extends ChangeNotifier {
  VendingState() {
    _noodles = defaultNoodleMenu();
  }

  // =========================================================================
  // Rule 1 / Rule 2 : Machine status (now backed by diagnostic values)
  // =========================================================================
  bool _machineBroken = false;
  double hotWaterTemp = 95; // °C, must be >= kMinHotWaterTemp
  static const double kMinHotWaterTemp = 80;

  MachineStatus get machineStatus =>
      _machineBroken ? MachineStatus.broken : MachineStatus.ready;

  bool get waterHeaterOk => hotWaterTemp >= kMinHotWaterTemp;

  /// Rule 1 (A): machine ready && heater ok -> service available
  bool get isServiceAvailable => !_machineBroken && waterHeaterOk;

  void toggleMachineBroken() {
    _machineBroken = !_machineBroken;
    _syncLockState();
  }

  void adminSetMachineBroken(bool broken) {
    _machineBroken = broken;
    _syncLockState();
  }

  void adminSetHotWaterTemp(double temp) {
    hotWaterTemp = temp;
    _syncLockState();
  }

  void _syncLockState() {
    processOutcome =
        isServiceAvailable ? ProcessOutcome.none : ProcessOutcome.machineLocked;
    notifyListeners();
  }

  // =========================================================================
  // Hardware levels (Admin > Diagnostic panel — informational + soft gating)
  // =========================================================================
  double waterTankLevel = 82; // %
  double cheeseStock = 70; // %
  double eggStock = 65; // %
  double spoonForkStock = 90; // %

  bool get cheeseAvailable => cheeseStock > 0;
  bool get eggAvailable => eggStock > 0;

  void adminSetWaterTankLevel(double v) {
    waterTankLevel = v.clamp(0, 100);
    notifyListeners();
  }

  void adminSetCheeseStock(double v) {
    cheeseStock = v.clamp(0, 100);
    notifyListeners();
  }

  void adminSetEggStock(double v) {
    eggStock = v.clamp(0, 100);
    notifyListeners();
  }

  void adminSetSpoonForkStock(double v) {
    spoonForkStock = v.clamp(0, 100);
    notifyListeners();
  }

  // =========================================================================
  // Admin Authentication (2.1)
  // =========================================================================
  bool isAdminLoggedIn = false;
  static const Set<String> _validPins = {'8888', '1234'};

  bool adminLogin(String pin) {
    if (_validPins.contains(pin)) {
      isAdminLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void adminLogout() {
    isAdminLoggedIn = false;
    notifyListeners();
  }

  // =========================================================================
  // Cash Drawer Monitor (2.2)
  // =========================================================================
  Map<double, int> cashReserve = defaultCashReserve();

  void refillCashReserve() {
    cashReserve = defaultCashReserve();
    notifyListeners();
  }

  void resetMachine() {
    _machineBroken = false;
    hotWaterTemp = 95;
    waterTankLevel = 100;
    cheeseStock = 100;
    eggStock = 100;
    spoonForkStock = 100;
    cashReserve = defaultCashReserve();
    resetOrder();
    notifyListeners();
  }

  // =========================================================================
  // Sales Summary (2.2)
  // =========================================================================
  double totalSalesAmount = 0;
  int totalCupsSold = 0;
  final Map<String, int> salesCountByFlavorName = {};

  void _recordSale() {
    if (selectedNoodle == null) return;
    totalSalesAmount += totalPrice;
    totalCupsSold += 1;
    final name = selectedNoodle!.name;
    salesCountByFlavorName[name] = (salesCountByFlavorName[name] ?? 0) + 1;
  }

  void adminResetSales() {
    totalSalesAmount = 0;
    totalCupsSold = 0;
    salesCountByFlavorName.clear();
    notifyListeners();
  }

  // =========================================================================
  // Menu Management (2.3) — CRUD over 30+ item catalogue
  // =========================================================================
  late List<NoodleItem> _noodles;
  List<NoodleItem> get noodles => _noodles;

  void addNoodleItem(NoodleItem item) {
    _noodles = [..._noodles, item];
    notifyListeners();
  }

  void updateNoodleItem(NoodleItem updated) {
    _noodles = _noodles.map((n) => n.id == updated.id ? updated : n).toList();
    notifyListeners();
  }

  void deleteNoodleItem(String id) {
    _noodles = _noodles.where((n) => n.id != id).toList();
    notifyListeners();
  }

  void toggleOutOfStock(String id) {
    _noodles = _noodles.map((n) {
      if (n.id == id) return n.copyWith(isOutOfStock: !n.isOutOfStock);
      return n;
    }).toList();
    notifyListeners();
  }

  String generateNoodleId() =>
      'n${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

  // =========================================================================
  // Menu / Flavor Selection (Rule 3,4,5,16)
  // =========================================================================
  NoodleItem? selectedNoodle;
  String? soldOutMessage;

  bool selectFlavor(NoodleItem n) {
    if (n.isOutOfStock) {
      // Rule 16 (P): sold out -> block and warn
      soldOutMessage = '"${n.name}" สินค้าหมด กรุณาเลือกรายการอื่น';
      notifyListeners();
      return false;
    }
    soldOutMessage = null;
    selectedNoodle = n;
    notifyListeners();
    return true;
  }

  // =========================================================================
  // Topping (Rule 6,7,8,9)
  // =========================================================================
  Topping selectedTopping = Topping.none;

  void selectTopping(Topping t) {
    selectedTopping = t;
    notifyListeners();
  }

  // =========================================================================
  // Heat Mode (Rule 10,11)
  // =========================================================================
  HeatMode heatMode = HeatMode.none;

  void selectHeatMode(HeatMode m) {
    heatMode = m;
    notifyListeners();
  }

  // =========================================================================
  // Pricing
  // =========================================================================
  double get basePrice => selectedNoodle?.priceAsDouble ?? 0;
  double get toppingPrice => selectedTopping.price;
  double get totalPrice => basePrice + toppingPrice;

  // =========================================================================
  // Payment (Rule 12,13,14,15)
  // =========================================================================
  PaymentMethod paymentMethod = PaymentMethod.none;
  double insertedCash = 0;
  bool qrPaid = false;

  CashStatus get cashStatus {
    if (paymentMethod != PaymentMethod.cash || insertedCash == 0) {
      return CashStatus.empty;
    }
    if (insertedCash < totalPrice) return CashStatus.insufficient; // Rule 14 N
    if (insertedCash == totalPrice) return CashStatus.exact; // Rule 15 O
    return CashStatus.over; // Rule 13 M
  }

  double get change =>
      cashStatus == CashStatus.over ? (insertedCash - totalPrice) : 0;

  /// Rule 12 (L): Scan QR, exact net amount paid instantly
  void payWithQR() {
    paymentMethod = PaymentMethod.qr;
    qrPaid = true;
    notifyListeners();
  }

  /// Insert a coin/note of given denomination
  void insertCash(double amount) {
    paymentMethod = PaymentMethod.cash;
    insertedCash += amount;
    notifyListeners();
  }

  /// whether START is enabled (feeds Rule 17/19/20)
  bool get canStart {
    if (!isServiceAvailable) return false;
    if (selectedNoodle == null) return false;
    if (heatMode == HeatMode.none) return false;
    if (qrPaid) return true; // Rule 12 -> ready for Rule 19/20
    return cashStatus == CashStatus.exact || cashStatus == CashStatus.over;
  }

  /// Breaks an amount into denomination counts (for change / display)
  static Map<double, int> breakIntoDenominations(double amount) {
    final Map<double, int> result = {};
    double remaining = amount;
    for (final d in kDenominations) {
      final count = (remaining / d).floor();
      if (count > 0) {
        result[d] = count;
        remaining -= count * d;
        remaining = double.parse(remaining.toStringAsFixed(2));
      }
    }
    return result;
  }

  // =========================================================================
  // Cancel (Rule 18, 24)
  // =========================================================================
  void cancelOrder() {
    // Rule 18 (R): cancel before cooking -> refund full inserted cash
    // Rule 24 (X): refund completed in full denominations
    processOutcome = ProcessOutcome.cancelledRefund;
    notifyListeners();
  }

  void acknowledgeCancelAndReset() {
    resetOrder();
  }

  // =========================================================================
  // Dispense process (Rule 19,20,21,22,23,25)
  // =========================================================================
  ProcessOutcome processOutcome = ProcessOutcome.none;
  double dispenseProgress = 0;
  Timer? _timer;
  bool _forceErrorNext = false;

  void armSimulatedError() {
    _forceErrorNext = true;
  }

  /// Rule 19 (S) / Rule 20 (T): press START
  void startDispense(void Function() onTick, void Function() onDone) {
    if (!canStart) return;
    dispenseProgress = 0;
    processOutcome = heatMode == HeatMode.hot
        ? ProcessOutcome.dispensingHot // Rule 19 (S)
        : ProcessOutcome.dispensingDry; // Rule 20 (T)
    notifyListeners();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (t) {
      // Rule 25 (Y): simulated emergency error mid-cook
      if (_forceErrorNext && dispenseProgress >= 40) {
        _forceErrorNext = false;
        t.cancel();
        processOutcome = ProcessOutcome.emergencyError; // Rule 25 (Y)
        notifyListeners();
        onDone();
        return;
      }

      dispenseProgress += 10;
      if (dispenseProgress >= 100) {
        dispenseProgress = 100;
        t.cancel();
        if (heatMode == HeatMode.hot) {
          processOutcome = ProcessOutcome.successHot; // Rule 21 (U)
        } else {
          processOutcome = ProcessOutcome.successDry; // Rule 22 (V)
        }
        _recordSale(); // Admin Sales Summary
        notifyListeners();
        onDone();
      } else {
        onTick();
        notifyListeners();
      }
    });
  }

  /// Rule 23 (W): after success, if change > 0, dispense change
  bool get hasChangeToReturn => change > 0;

  void resetOrder() {
    _timer?.cancel();
    selectedNoodle = null;
    selectedTopping = Topping.none;
    heatMode = HeatMode.none;
    paymentMethod = PaymentMethod.none;
    insertedCash = 0;
    qrPaid = false;
    processOutcome = isServiceAvailable ? ProcessOutcome.none : ProcessOutcome.machineLocked;
    dispenseProgress = 0;
    soldOutMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
