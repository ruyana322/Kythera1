// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/kythera_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/converter_screen.dart';
import 'screens/compress_screen.dart';
import 'screens/patch_screen.dart';
import 'screens/other_screens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: KColor.surface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const KytheraApp());
}

class KytheraApp extends StatelessWidget {
  const KytheraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kythera Tools',
      theme: kytheraTheme(),
      debugShowCheckedModeBanner: false,
      home: const KytheraShell(),
    );
  }
}

// ─── Main Shell (bottom nav + drawer) ────────────────────────────────────────
class KytheraShell extends StatefulWidget {
  const KytheraShell({super.key});

  @override
  State<KytheraShell> createState() => _KytheraShellState();
}

class _KytheraShellState extends State<KytheraShell> {
  int _currentIndex = 0;

  // Pages: 0=Dashboard, 1=Converter, 2=Compress, 3=Patch, 4=History, 5=Settings
  // Photo Enhance (index 6) accessible via drawer + dashboard only
  final _pages = <Widget Function(void Function(int))>[
    (nav) => DashboardScreen(onNavigate: nav),
    (_)   => const ConverterScreen(),
    (_)   => const CompressScreen(),
    (_)   => const PatchScreen(),
    (_)   => const HistoryScreen(),
    (_)   => const SettingsScreen(),
  ];

  // Bottom nav only shows: Dashboard, Converter, Compress, Patch, History
  static const _navItems = [
    _NavItem(Icons.grid_view_rounded, 'Dashboard'),
    _NavItem(Icons.swap_horiz_rounded, 'Convert'),
    _NavItem(Icons.compress_rounded, 'Compress'),
    _NavItem(Icons.edit_outlined, 'Patch'),
    _NavItem(Icons.history_rounded, 'History'),
  ];

  void _navigate(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColor.bg,
      appBar: _KytheraAppBar(
        currentIndex: _currentIndex,
        onMenuTap: () => Scaffold.of(context).openDrawer(),
      ),
      drawer: _KytheraDrawer(
        currentIndex: _currentIndex,
        onNavigate: _navigate,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages
            .map((builder) => builder(_navigate))
            .toList(),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex > 4 ? 0 : _currentIndex,
        items: _navItems,
        onTap: _navigate,
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────
class _KytheraAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final VoidCallback onMenuTap;

  const _KytheraAppBar(
      {required this.currentIndex, required this.onMenuTap});

  static const _titles = [
    'Dashboard',
    'Converter',
    'Compress',
    'Patch',
    'History',
    'Pengaturan',
  ];

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: KColor.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                // Logo
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [KColor.accent, KColor.accent2],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.bolt, color: Colors.black, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Kythera',
                      style: TextStyle(
                          color: KColor.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 16),
                    ),
                  ],
                ),
                const Spacer(),
                // Current page title
                Text(
                  currentIndex < _titles.length ? _titles[currentIndex] : '',
                  style: const TextStyle(color: KColor.text3, fontSize: 12),
                ),
                const SizedBox(width: 12),
                // Status dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: KColor.accent3,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: KColor.accent3.withOpacity(0.6),
                          blurRadius: 6)
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Menu button (opens drawer)
                GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: const Icon(Icons.menu, color: KColor.text2, size: 22),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Side Drawer ──────────────────────────────────────────────────────────────
class _KytheraDrawer extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onNavigate;

  const _KytheraDrawer(
      {required this.currentIndex, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final items = [
      _DrawerItem(Icons.grid_view_rounded, 'Dashboard',     0),
      _DrawerItem(Icons.image_outlined,    'Photo Enhance', 6),
      _DrawerItem(Icons.swap_horiz_rounded,'Converter',     1),
      _DrawerItem(Icons.compress_rounded,  'Compress',      2),
      _DrawerItem(Icons.edit_outlined,     'Patch Video',   3),
      _DrawerItem(Icons.history_rounded,   'History',       4),
      _DrawerItem(Icons.settings_outlined, 'Pengaturan',    5),
    ];

    return Drawer(
      backgroundColor: KColor.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer header
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: KColor.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [KColor.accent, KColor.accent2],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.bolt, color: Colors.black, size: 24),
                  ),
                  const SizedBox(height: 12),
                  const Text('Kythera Tools',
                      style: TextStyle(
                          color: KColor.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 18)),
                  const Text('by D4nzxml · JGC',
                      style: TextStyle(color: KColor.text3, fontSize: 11)),
                ],
              ),
            ),

            // Nav items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                children: items
                    .map((item) => _DrawerNavItem(
                          item: item,
                          isActive: currentIndex == item.index,
                          onTap: () {
                            Navigator.pop(context);
                            onNavigate(item.index);
                          },
                        ))
                    .toList(),
              ),
            ),

            // Version footer
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: KColor.border)),
              ),
              child: const Text('v1.0.0 · FFmpeg min-gpl 6.x',
                  style: TextStyle(color: KColor.text3, fontSize: 10),
                  textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem {
  final IconData icon;
  final String label;
  final int index;
  const _DrawerItem(this.icon, this.label, this.index);
}

class _DrawerNavItem extends StatelessWidget {
  final _DrawerItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerNavItem(
      {required this.item, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isActive
                ? KColor.accent.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive
                ? Border.all(color: KColor.accent.withOpacity(0.2))
                : null,
          ),
          child: Row(
            children: [
              Icon(item.icon,
                  color: isActive ? KColor.accent : KColor.text2,
                  size: 18),
              const SizedBox(width: 12),
              Text(item.label,
                  style: TextStyle(
                      color: isActive ? KColor.accent : KColor.text2,
                      fontSize: 13,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final void Function(int) onTap;

  const _BottomNav(
      {required this.currentIndex,
      required this.items,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: KColor.surface,
        border: Border(top: BorderSide(color: KColor.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((e) {
              final isActive = currentIndex == e.key;
              return GestureDetector(
                onTap: () => onTap(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? KColor.accent.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        e.value.icon,
                        color: isActive ? KColor.accent : KColor.text3,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.value.label,
                        style: TextStyle(
                          color: isActive ? KColor.accent : KColor.text3,
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
