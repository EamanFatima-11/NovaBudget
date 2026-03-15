import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const NovaBudgetApp());
}

// ══════════════════════════════════════════════
//  THEME
// ══════════════════════════════════════════════
class NC {
  static const bg = Color(0xFF021A0E);
  static const bgMid = Color(0xFF062414);
  static const surface = Color(0xFF0D3320);
  static const surfaceHi = Color(0xFF154530);
  static const emerald = Color(0xFF10B981);
  static const mint = Color(0xFF6EE7B7);
  static const forest = Color(0xFF065F46);
  static const lime = Color(0xFFBEF264);
  static const cream = Color(0xFFF0FDF4);
  static const muted = Color(0xFF4D8C6A);
  static const red = Color(0xFFFF6B6B);
  static const yellow = Color(0xFFFFD93D);
  static const blue = Color(0xFF38BDF8);
  static const purple = Color(0xFF818CF8);
}

// ══════════════════════════════════════════════
//  MODELS
// ══════════════════════════════════════════════
class Transaction {
  final String id, title, category;
  final double amount;
  final bool isIncome;
  final DateTime date;

  Transaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.date,
  });

  IconData get icon => catIcons[category] ?? Icons.attach_money_rounded;
  Color get color => catColors[category] ?? NC.emerald;
}

class BudgetItem {
  final String id, category;
  double limit;
  Color color;
  BudgetItem({
    required this.id,
    required this.category,
    required this.limit,
    required this.color,
  });

  double spent(List<Transaction> txns) => txns
      .where((t) => !t.isIncome && t.category == category)
      .fold(0.0, (a, t) => a + t.amount);

  double percent(List<Transaction> txns) =>
      limit > 0 ? (spent(txns) / limit).clamp(0.0, 1.0) : 0;
}

// ══════════════════════════════════════════════
//  CONSTANTS
// ══════════════════════════════════════════════
const expenseCategories = [
  'Food',
  'Transport',
  'Education',
  'Entertainment',
  'Shopping',
  'Health',
  'Utilities',
  'Other',
];

final catColors = <String, Color>{
  'Food': NC.yellow,
  'Transport': NC.purple,
  'Education': NC.blue,
  'Entertainment': NC.red,
  'Shopping': const Color(0xFFEC4899),
  'Health': const Color(0xFF34D399),
  'Utilities': const Color(0xFFFB923C),
  'Other': NC.muted,
  'Income': NC.emerald,
};

final catIcons = <String, IconData>{
  'Food': Icons.restaurant_rounded,
  'Transport': Icons.directions_bus_rounded,
  'Education': Icons.menu_book_rounded,
  'Entertainment': Icons.play_circle_rounded,
  'Shopping': Icons.shopping_bag_rounded,
  'Health': Icons.favorite_rounded,
  'Utilities': Icons.bolt_rounded,
  'Other': Icons.category_rounded,
  'Income': Icons.account_balance_wallet_rounded,
};

// ══════════════════════════════════════════════
//  APP STATE
// ══════════════════════════════════════════════
class AppState extends ChangeNotifier {
  final List<Transaction> transactions = [];
  final List<BudgetItem> budgets = [];

  AppState() {
    _seed();
  }

  double get totalIncome =>
      transactions.where((t) => t.isIncome).fold(0, (a, t) => a + t.amount);
  double get totalExpense =>
      transactions.where((t) => !t.isIncome).fold(0, (a, t) => a + t.amount);
  double get balance => totalIncome - totalExpense;
  double get savingsRate =>
      totalIncome > 0 ? (balance / totalIncome * 100).clamp(0, 100) : 0;

  Map<String, double> get spendingByCategory {
    final map = <String, double>{};
    for (final t in transactions.where((t) => !t.isIncome)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  List<double> get weeklySpending {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return transactions
          .where(
            (t) =>
                !t.isIncome &&
                t.date.year == day.year &&
                t.date.month == day.month &&
                t.date.day == day.day,
          )
          .fold(0.0, (a, t) => a + t.amount);
    });
  }

  void addTransaction(Transaction t) {
    transactions.insert(0, t);
    notifyListeners();
  }

  void deleteTransaction(String id) {
    transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void addBudget(BudgetItem b) {
    budgets.removeWhere((x) => x.category == b.category);
    budgets.add(b);
    notifyListeners();
  }

  void updateBudget(String id, double newLimit) {
    final idx = budgets.indexWhere((b) => b.id == id);
    if (idx != -1) {
      budgets[idx].limit = newLimit;
      notifyListeners();
    }
  }

  void deleteBudget(String id) {
    budgets.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  void _seed() {
    final now = DateTime.now;
    transactions.addAll([
      Transaction(
        id: 's1',
        title: 'Freelance Project',
        category: 'Income',
        amount: 15000,
        isIncome: true,
        date: now().subtract(const Duration(hours: 3)),
      ),
      Transaction(
        id: 's2',
        title: 'Grocery Shopping',
        category: 'Food',
        amount: 2300,
        isIncome: false,
        date: now().subtract(const Duration(hours: 6)),
      ),
      Transaction(
        id: 's3',
        title: 'Scholarship Grant',
        category: 'Income',
        amount: 25000,
        isIncome: true,
        date: now().subtract(const Duration(days: 1)),
      ),
      Transaction(
        id: 's4',
        title: 'Netflix',
        category: 'Entertainment',
        amount: 800,
        isIncome: false,
        date: now().subtract(const Duration(days: 1)),
      ),
      Transaction(
        id: 's5',
        title: 'Bus Pass',
        category: 'Transport',
        amount: 500,
        isIncome: false,
        date: now().subtract(const Duration(days: 2)),
      ),
      Transaction(
        id: 's6',
        title: 'Books & Notes',
        category: 'Education',
        amount: 1200,
        isIncome: false,
        date: now().subtract(const Duration(days: 2)),
      ),
      Transaction(
        id: 's7',
        title: 'Part-time Work',
        category: 'Income',
        amount: 8000,
        isIncome: true,
        date: now().subtract(const Duration(days: 3)),
      ),
      Transaction(
        id: 's8',
        title: 'Restaurant',
        category: 'Food',
        amount: 1500,
        isIncome: false,
        date: now().subtract(const Duration(days: 3)),
      ),
    ]);
    budgets.addAll([
      BudgetItem(id: 'b1', category: 'Food', limit: 5000, color: NC.yellow),
      BudgetItem(
        id: 'b2',
        category: 'Entertainment',
        limit: 2000,
        color: NC.red,
      ),
      BudgetItem(id: 'b3', category: 'Education', limit: 3000, color: NC.blue),
      BudgetItem(
        id: 'b4',
        category: 'Transport',
        limit: 1500,
        color: NC.purple,
      ),
    ]);
  }
}

// ══════════════════════════════════════════════
//  APP ROOT
// ══════════════════════════════════════════════
class NovaBudgetApp extends StatelessWidget {
  const NovaBudgetApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'NovaBudget',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: NC.bg),
    home: const BudgetSplash(),
  );
}

// ══════════════════════════════════════════════
//  SPLASH
// ══════════════════════════════════════════════
class BudgetSplash extends StatefulWidget {
  const BudgetSplash({super.key});
  @override
  State<BudgetSplash> createState() => _BudgetSplashState();
}

class _BudgetSplashState extends State<BudgetSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: const Interval(0.4, 1.0));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => BudgetHome(state: AppState()),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: NC.bg,
    body: Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [Color(0xFF0D3320), NC.bg],
          center: Alignment.center,
          radius: 0.8,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [NC.emerald, NC.mint],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: NC.emerald.withOpacity(0.5),
                      blurRadius: 48,
                      spreadRadius: 12,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('💰', style: TextStyle(fontSize: 50)),
                ),
              ),
            ),
            const SizedBox(height: 28),
            FadeTransition(
              opacity: _fade,
              child: const Column(
                children: [
                  Text(
                    'NovaBudget',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: NC.cream,
                      letterSpacing: -1.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Smart money. Smarter you.',
                    style: TextStyle(fontSize: 14, color: NC.mint),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ══════════════════════════════════════════════
//  HOME
// ══════════════════════════════════════════════
class BudgetHome extends StatefulWidget {
  final AppState state;
  const BudgetHome({super.key, required this.state});
  @override
  State<BudgetHome> createState() => _BudgetHomeState();
}

class _BudgetHomeState extends State<BudgetHome> with TickerProviderStateMixin {
  int _tab = 0;
  late AnimationController _cardCtrl;
  late Animation<double> _cardAnim;
  AppState get _s => widget.state;

  @override
  void initState() {
    super.initState();
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardAnim = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic);
    _cardCtrl.forward();
    _s.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _cardCtrl.dispose();
    _s.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: NC.bg,
    body: SafeArea(
      child: Column(
        children: [
          _header(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _balanceCard(),
                  const SizedBox(height: 12),
                  _savingsBar(),
                  const SizedBox(height: 12),
                  _tabs(),
                  const SizedBox(height: 6),
                  _tabContent(),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton.extended(
      backgroundColor: NC.emerald,
      foregroundColor: NC.bg,
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Add Transaction',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      onPressed: _openAddTxn,
    ),
  );

  // ─── HEADER ──────────────────────────────
  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NovaBudget',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: NC.cream,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              _monthYear(),
              style: const TextStyle(fontSize: 12, color: NC.muted),
            ),
          ],
        ),
        Row(
          children: [
            _chip('📈 ${_s.savingsRate.toStringAsFixed(0)}% saved', NC.emerald),
            const SizedBox(width: 8),
            // Add budget button
            GestureDetector(
              onTap: _openAddBudget,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: NC.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NC.emerald.withOpacity(0.2)),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: NC.mint,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  // ─── BALANCE CARD ─────────────────────────
  Widget _balanceCard() => AnimatedBuilder(
    animation: _cardAnim,
    builder: (_, __) => Transform.translate(
      offset: Offset(0, 24 * (1 - _cardAnim.value)),
      child: Opacity(
        opacity: _cardAnim.value.clamp(0.0, 1.0),
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [NC.forest, Color(0xFF0D6B40), NC.emerald],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: NC.emerald.withOpacity(0.35),
                blurRadius: 36,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _monthYear(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'PKR ${_fmt(_s.balance)}',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.trending_up_rounded,
                    size: 13,
                    color: NC.lime,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_s.savingsRate.toStringAsFixed(1)}% savings rate',
                    style: const TextStyle(fontSize: 11, color: NC.lime),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _miniStat('💚 Income', _s.totalIncome, NC.lime),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _miniStat('🔴 Expense', _s.totalExpense, NC.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _miniStat(String label, double amount, Color color) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.12),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          'PKR ${_fmt(amount)}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    ),
  );

  // ─── SAVINGS BAR ──────────────────────────
  Widget _savingsBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NC.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: NC.emerald.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Goal Progress',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: NC.cream,
                ),
              ),
              Text(
                '${_s.savingsRate.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: NC.mint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _s.savingsRate / 100,
              minHeight: 10,
              backgroundColor: NC.surfaceHi,
              valueColor: AlwaysStoppedAnimation(
                _s.savingsRate >= 30 ? NC.emerald : NC.yellow,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _s.savingsRate >= 30
                ? '🎉 Excellent! You\'re saving well this month.'
                : '💡 Save at least 30% of income for a healthy budget.',
            style: const TextStyle(fontSize: 11, color: NC.muted),
          ),
        ],
      ),
    ),
  );

  // ─── TABS ─────────────────────────────────
  Widget _tabs() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: ['Overview', 'Transactions', 'Budgets']
          .asMap()
          .entries
          .map(
            (e) => GestureDetector(
              onTap: () => setState(() => _tab = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  gradient: _tab == e.key
                      ? const LinearGradient(colors: [NC.forest, NC.emerald])
                      : null,
                  color: _tab != e.key ? NC.surface : null,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _tab == e.key
                      ? [
                          BoxShadow(
                            color: NC.emerald.withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  e.value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _tab == e.key ? Colors.white : NC.muted,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    ),
  );

  Widget _tabContent() {
    if (_tab == 0) return _overview();
    if (_tab == 1) return _transactionsList();
    return _budgetsList();
  }

  // ─── OVERVIEW ─────────────────────────────
  Widget _overview() => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        // weekly bars
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: NC.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: NC.emerald.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Weekly Spending',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: NC.cream,
                    ),
                  ),
                  Text(
                    'PKR ${_fmt(_s.weeklySpending.fold(0, (a, b) => a + b))}',
                    style: const TextStyle(fontSize: 12, color: NC.muted),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _barChart(),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // donut
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: NC.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: NC.emerald.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Spending by Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: NC.cream,
                ),
              ),
              const SizedBox(height: 14),
              _donut(),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // stats grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.1,
          children: [
            _statCard('💰', 'Balance', 'PKR ${_fmt(_s.balance)}', NC.emerald),
            _statCard('📥', 'Income', 'PKR ${_fmt(_s.totalIncome)}', NC.mint),
            _statCard('📤', 'Expenses', 'PKR ${_fmt(_s.totalExpense)}', NC.red),
            _statCard(
              '🧾',
              'Transactions',
              '${_s.transactions.length}',
              NC.yellow,
            ),
          ],
        ),
      ],
    ),
  );

  Widget _barChart() {
    final weekly = _s.weeklySpending;
    final maxVal = weekly.isEmpty ? 1.0 : weekly.reduce(max);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now().weekday - 1;

    return SizedBox(
      height: 110,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekly.asMap().entries.map((e) {
          final h = maxVal > 0 ? e.value / maxVal : 0.0;
          final isToday = e.key == today;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (e.value > 0)
                Text(
                  _fmtSmall(e.value),
                  style: const TextStyle(fontSize: 8, color: NC.mint),
                ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: Duration(milliseconds: 400 + e.key * 80),
                width: 30,
                height: max(6.0, 90.0 * h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isToday
                        ? [NC.emerald, NC.mint]
                        : [NC.forest, NC.emerald],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isToday
                      ? [
                          BoxShadow(
                            color: NC.emerald.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : [],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                days[e.key],
                style: TextStyle(
                  fontSize: 9,
                  color: isToday ? NC.emerald : NC.muted,
                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w400,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _donut() {
    final cats = _s.spendingByCategory;
    if (cats.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No expenses yet — add some!',
            style: TextStyle(color: NC.muted, fontSize: 13),
          ),
        ),
      );
    }
    final total = cats.values.fold(0.0, (a, b) => a + b);
    final colors = cats.keys.map((k) => catColors[k] ?? NC.muted).toList();
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: CustomPaint(
            painter: _RingPainter(cats.values.toList(), colors),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 10, color: NC.muted),
                  ),
                  Text(
                    'PKR ${_fmt(total)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: NC.cream,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: cats.entries
              .map(
                (e) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: catColors[e.key] ?? NC.muted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${e.key}: ${_fmt(e.value)}',
                      style: const TextStyle(fontSize: 11, color: NC.muted),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _statCard(String emoji, String label, String val, Color color) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 10, color: NC.muted),
                  ),
                  Text(
                    val,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  // ─── TRANSACTIONS LIST ─────────────────────
  Widget _transactionsList() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_s.transactions.length} Transactions',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: NC.cream,
              ),
            ),
            GestureDetector(onTap: _openAddTxn, child: _addChip('+ Add')),
          ],
        ),
      ),
      if (_s.transactions.isEmpty)
        _emptyState(
          '💸',
          'No transactions yet',
          'Tap + to add your first transaction',
        )
      else
        ..._s.transactions.map(_txnTile),
      const SizedBox(height: 80),
    ],
  );

  Widget _txnTile(Transaction t) => Dismissible(
    key: Key(t.id),
    direction: DismissDirection.endToStart,
    background: Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      decoration: BoxDecoration(
        color: NC.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_rounded, color: NC.red),
          Text('Delete', style: TextStyle(fontSize: 10, color: NC.red)),
        ],
      ),
    ),
    onDismissed: (_) {
      _s.deleteTransaction(t.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${t.title}" deleted'),
          backgroundColor: NC.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () => _s.addTransaction(t),
          ),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NC.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: t.isIncome
              ? NC.emerald.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: t.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(t.icon, color: t.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: NC.cream,
                  ),
                ),
                Text(
                  t.category,
                  style: const TextStyle(fontSize: 11, color: NC.muted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${t.isIncome ? '+' : '-'} PKR ${_fmt(t.amount)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: t.isIncome ? NC.mint : NC.red,
                ),
              ),
              Text(
                _timeAgo(t.date),
                style: const TextStyle(fontSize: 10, color: NC.muted),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  // ─── BUDGETS LIST ──────────────────────────
  Widget _budgetsList() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Budget Limits',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: NC.cream,
              ),
            ),
            GestureDetector(
              onTap: _openAddBudget,
              child: _addChip('+ Add Budget'),
            ),
          ],
        ),
      ),
      if (_s.budgets.isEmpty)
        _emptyState(
          '📊',
          'No budgets set',
          'Tap "Add Budget" to set monthly spending limits',
        )
      else
        ..._s.budgets.map(_budgetCard),
      const SizedBox(height: 80),
    ],
  );

  Widget _budgetCard(BudgetItem b) {
    final spent = b.spent(_s.transactions);
    final percent = b.percent(_s.transactions);
    final over = percent >= 0.9;
    final remaining = b.limit - spent;

    return Dismissible(
      key: Key(b.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        decoration: BoxDecoration(
          color: NC.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_rounded, color: NC.red),
            Text('Remove', style: TextStyle(fontSize: 10, color: NC.red)),
          ],
        ),
      ),
      onDismissed: (_) {
        _s.deleteBudget(b.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${b.category} budget removed'),
            backgroundColor: NC.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _openEditBudget(b),
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: NC.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: over ? NC.red.withOpacity(0.4) : b.color.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: b.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          catIcons[b.category] ?? Icons.category_rounded,
                          color: b.color,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        b.category,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: NC.cream,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (over)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: NC.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '⚠️ Near limit',
                            style: TextStyle(fontSize: 9, color: NC.red),
                          ),
                        ),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit_rounded, color: NC.muted, size: 15),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Spent: PKR ${_fmt(spent)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: b.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Limit: PKR ${_fmt(b.limit)}',
                    style: const TextStyle(fontSize: 12, color: NC.muted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 10,
                  backgroundColor: NC.surfaceHi,
                  valueColor: AlwaysStoppedAnimation(over ? NC.red : b.color),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(percent * 100).toInt()}% used',
                    style: const TextStyle(fontSize: 11, color: NC.muted),
                  ),
                  Text(
                    remaining >= 0
                        ? 'PKR ${_fmt(remaining)} remaining'
                        : 'Over by PKR ${_fmt(-remaining)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: remaining >= 0 ? NC.emerald : NC.red,
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

  // ─── SHEET OPENERS ────────────────────────
  void _openAddTxn() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: NC.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _AddTxnSheet(onAdd: _s.addTransaction),
  );

  void _openAddBudget() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: NC.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _AddBudgetSheet(onAdd: _s.addBudget),
  );

  void _openEditBudget(BudgetItem b) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: NC.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) =>
        _EditBudgetSheet(budget: b, onSave: (v) => _s.updateBudget(b.id, v)),
  );

  // ─── HELPERS ──────────────────────────────
  Widget _addChip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: NC.emerald.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: NC.emerald.withOpacity(0.3)),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        color: NC.emerald,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _emptyState(String emoji, String title, String sub) => Padding(
    padding: const EdgeInsets.all(40),
    child: Center(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: NC.cream,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: const TextStyle(color: NC.muted, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    ),
  );

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700),
    ),
  );

  String _fmt(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toStringAsFixed(0);
  }

  String _fmtSmall(double n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(0)}k' : n.toStringAsFixed(0);

  String _monthYear() {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final d = DateTime.now();
    return '${m[d.month - 1]} ${d.year}';
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ══════════════════════════════════════════════
//  ADD TRANSACTION SHEET
// ══════════════════════════════════════════════
class _AddTxnSheet extends StatefulWidget {
  final Function(Transaction) onAdd;
  const _AddTxnSheet({required this.onAdd});
  @override
  State<_AddTxnSheet> createState() => _AddTxnSheetState();
}

class _AddTxnSheetState extends State<_AddTxnSheet> {
  final _titleCtrl = TextEditingController();
  final _amtCtrl = TextEditingController();
  bool _isIncome = false;
  String _cat = 'Food';
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amtCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final amt = double.tryParse(_amtCtrl.text.replaceAll(',', '').trim());
    if (title.isEmpty) {
      setState(() => _error = 'Please enter a title');
      return;
    }
    if (amt == null || amt <= 0) {
      setState(() => _error = 'Please enter a valid amount');
      return;
    }
    widget.onAdd(
      Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        category: _isIncome ? 'Income' : _cat,
        amount: amt,
        isIncome: _isIncome,
        date: DateTime.now(),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: 20,
      right: 20,
      top: 20,
      bottom: MediaQuery.of(context).viewInsets.bottom + 28,
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _handle(),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Add Transaction 💸',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: NC.cream,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Toggle
          Row(
            children: [
              Expanded(
                child: _toggle(
                  '💸 Expense',
                  !_isIncome,
                  () => setState(() {
                    _isIncome = false;
                    _cat = 'Food';
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _toggle(
                  '💰 Income',
                  _isIncome,
                  () => setState(() {
                    _isIncome = true;
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _field(
            _titleCtrl,
            'Title (e.g. Grocery Shopping)',
            Icons.title_rounded,
          ),
          const SizedBox(height: 12),
          _field(
            _amtCtrl,
            'Amount in PKR (e.g. 2500)',
            Icons.attach_money_rounded,
            keyboard: const TextInputType.numberWithOptions(decimal: true),
          ),
          if (!_isIncome) ...[
            const SizedBox(height: 16),
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: NC.muted,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: expenseCategories.map((c) {
                final active = _cat == c;
                final color = catColors[c] ?? NC.muted;
                return GestureDetector(
                  onTap: () => setState(() => _cat = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: active ? color.withOpacity(0.2) : NC.surfaceHi,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active ? color : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          catIcons[c] ?? Icons.circle,
                          size: 13,
                          color: active ? color : NC.muted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          c,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: active ? color : NC.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            _errorBox(_error!),
          ],
          const SizedBox(height: 20),
          _saveBtn('Save Transaction ✅', _submit),
        ],
      ),
    ),
  );

  Widget _toggle(String label, bool active, VoidCallback fn) => GestureDetector(
    onTap: fn,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: active ? NC.emerald.withOpacity(0.2) : NC.surfaceHi,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: active ? NC.emerald : Colors.transparent),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? NC.mint : NC.muted,
          ),
        ),
      ),
    ),
  );

  Widget _field(
    TextEditingController c,
    String hint,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) => TextField(
    controller: c,
    keyboardType: keyboard,
    style: const TextStyle(color: NC.cream, fontSize: 14),
    onChanged: (_) => setState(() => _error = null),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: NC.muted),
      prefixIcon: Icon(icon, color: NC.muted, size: 18),
      filled: true,
      fillColor: NC.surfaceHi,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );

  Widget _handle() => Center(
    child: Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: NC.muted.withOpacity(0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );

  Widget _errorBox(String msg) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: NC.red.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: NC.red.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline_rounded, color: NC.red, size: 16),
        const SizedBox(width: 8),
        Text(msg, style: const TextStyle(fontSize: 12, color: NC.red)),
      ],
    ),
  );

  Widget _saveBtn(String label, VoidCallback fn) => GestureDetector(
    onTap: fn,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [NC.forest, NC.emerald]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: NC.emerald.withOpacity(0.3), blurRadius: 12),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}

// ══════════════════════════════════════════════
//  ADD BUDGET SHEET
// ══════════════════════════════════════════════
class _AddBudgetSheet extends StatefulWidget {
  final Function(BudgetItem) onAdd;
  const _AddBudgetSheet({required this.onAdd});
  @override
  State<_AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<_AddBudgetSheet> {
  final _limitCtrl = TextEditingController();
  String _cat = 'Food';
  String? _error;

  @override
  void dispose() {
    _limitCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final limit = double.tryParse(_limitCtrl.text.replaceAll(',', '').trim());
    if (limit == null || limit <= 0) {
      setState(() => _error = 'Enter a valid amount');
      return;
    }
    widget.onAdd(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: _cat,
        limit: limit,
        color: catColors[_cat] ?? NC.emerald,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: 20,
      right: 20,
      top: 20,
      bottom: MediaQuery.of(context).viewInsets.bottom + 28,
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: NC.muted.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Set Budget Limit 📊',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: NC.cream,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Set a monthly spending limit per category',
              style: TextStyle(fontSize: 12, color: NC.muted),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Category',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: NC.muted,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: expenseCategories.map((c) {
              final active = _cat == c;
              final color = catColors[c] ?? NC.muted;
              return GestureDetector(
                onTap: () => setState(() => _cat = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: active ? color.withOpacity(0.2) : NC.surfaceHi,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active ? color : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        catIcons[c] ?? Icons.circle,
                        size: 13,
                        color: active ? color : NC.muted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        c,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: active ? color : NC.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _limitCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: NC.cream, fontSize: 14),
            onChanged: (_) => setState(() => _error = null),
            decoration: InputDecoration(
              hintText: 'Monthly limit in PKR (e.g. 5000)',
              hintStyle: const TextStyle(color: NC.muted),
              prefixIcon: const Icon(
                Icons.account_balance_wallet_rounded,
                color: NC.muted,
                size: 18,
              ),
              filled: true,
              fillColor: NC.surfaceHi,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: NC.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: NC.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: NC.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _error!,
                    style: const TextStyle(fontSize: 12, color: NC.red),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _submit,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [NC.forest, NC.emerald]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: NC.emerald.withOpacity(0.3), blurRadius: 12),
                ],
              ),
              child: const Center(
                child: Text(
                  'Set Limit ✅',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ══════════════════════════════════════════════
//  EDIT BUDGET SHEET
// ══════════════════════════════════════════════
class _EditBudgetSheet extends StatefulWidget {
  final BudgetItem budget;
  final Function(double) onSave;
  const _EditBudgetSheet({required this.budget, required this.onSave});
  @override
  State<_EditBudgetSheet> createState() => _EditBudgetSheetState();
}

class _EditBudgetSheetState extends State<_EditBudgetSheet> {
  late TextEditingController _ctrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.budget.limit.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final v = double.tryParse(_ctrl.text.replaceAll(',', '').trim());
    if (v == null || v <= 0) {
      setState(() => _error = 'Enter a valid amount');
      return;
    }
    widget.onSave(v);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: 20,
      right: 20,
      top: 20,
      bottom: MediaQuery.of(context).viewInsets.bottom + 28,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: NC.muted.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Edit ${widget.budget.category} Budget ✏️',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: NC.cream,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: NC.cream, fontSize: 16),
          onChanged: (_) => setState(() => _error = null),
          decoration: InputDecoration(
            hintText: 'New monthly limit in PKR',
            hintStyle: const TextStyle(color: NC.muted),
            prefixIcon: const Icon(
              Icons.edit_rounded,
              color: NC.muted,
              size: 18,
            ),
            filled: true,
            fillColor: NC.surfaceHi,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(fontSize: 12, color: NC.red)),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: NC.surfaceHi,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: NC.muted.withOpacity(0.2)),
                  ),
                  child: const Center(
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: NC.muted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _submit,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [NC.forest, NC.emerald],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ══════════════════════════════════════════════
//  RING CHART PAINTER
// ══════════════════════════════════════════════
class _RingPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  _RingPainter(this.values, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;
    final cx = size.width / 2, cy = size.height / 2;
    final r = min(cx, cy) - 12;
    double angle = -pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = 2 * pi * (values[i] / total);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        angle,
        sweep - 0.06,
        false,
        Paint()
          ..color = colors[i % colors.length]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 26
          ..strokeCap = StrokeCap.round,
      );
      angle += sweep;
    }
  }

  @override
  bool shouldRepaint(_RingPainter o) => true;
}
