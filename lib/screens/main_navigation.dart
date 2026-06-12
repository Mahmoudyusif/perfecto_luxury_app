import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// Models & Providers
import '../models/cart.dart';
import '../models/user_provider.dart';
import '../models/navigation_provider.dart';

// Widgets
import '../widgets/announcement_bar.dart';
import '../widgets/custom_search_delegate.dart';
import '../config/app_colors.dart';

// Screens
import 'home_screen.dart';
import 'branches_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  Future<void> _launchWhatsApp(BuildContext context) async {
    const url = "https://wa.me/201234567890";
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open WhatsApp")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // استخدام Provider للوصول للبيانات (المستوى الاحترافي)
    final navProvider = context.watch<NavigationProvider>();
    final cartCount = context.watch<CartProvider>().totalItems;
    final isAdmin = context.watch<UserProvider>().isAdminMode;
    bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 35),
        child: Column(
          children: [
            const AnnouncementBar(),
            AppBar(
              title: Text(isAr ? "بيرفيكتو" : "PERFECTO"),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, size: 20),
                  onPressed: () => showSearch(
                    context: context,
                    delegate: CustomSearchDelegate(),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: navProvider.currentIndex,
        children: const [
          HomeScreen(),
          BranchesScreen(),
          CartScreen(),
          ProfileScreen()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _launchWhatsApp(context),
        backgroundColor: const Color(0xFF25D366),
        shape: const CircleBorder(),
        child: const Icon(Icons.message, color: Colors.white, size: 24),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navProvider.currentIndex,
        onDestinationSelected: (i) => navProvider.setIndex(i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.accentGold.withOpacity(0.1),
        height: 70,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            label: isAr ? "الرئيسية" : 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.near_me_outlined),
            label: isAr ? "الفروع" : 'Explore',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text(cartCount.toString()),
              isLabelVisible: cartCount > 0,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            label: isAr ? "السلة" : 'Bag',
          ),
          NavigationDestination(
            icon: Icon(isAdmin
                ? Icons.admin_panel_settings_outlined
                : Icons.person_outline),
            label: isAdmin
                ? (isAr ? "الإدارة" : 'Control')
                : (isAr ? "حسابي" : 'Account'),
          ),
        ],
      ),
    );
  }
}
