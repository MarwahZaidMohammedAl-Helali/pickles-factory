import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import 'restaurant_list_screen.dart';
import 'product_list_screen.dart';
import 'staff_list_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin();

    final List<Widget> screens = [
      const RestaurantListScreen(),
      const ProductListScreen(),
      if (isAdmin) const AnalyticsScreen(),
      if (isAdmin) const StaffListScreen(),
    ];

    final List<BottomNavigationBarItem> navItems = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.restaurant),
        label: l10n.restaurants,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.inventory),
        label: l10n.products,
      ),
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'التحليلات',
        ),
      if (isAdmin)
        BottomNavigationBarItem(
          icon: const Icon(Icons.people),
          label: l10n.staff,
        ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: navItems,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
