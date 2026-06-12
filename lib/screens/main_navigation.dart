import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_screen.dart';
import 'branches_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import '../models/cart.dart';
import '../models/user_provider.dart';
import '../models/order.dart';
import '../models/product.dart'; // مهم جداً للبحث
import '../models/navigation_provider.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  @override
  void initState() {
    super.initState();
    // تفعيل التحديث اللحظي لجميع البيانات المهمة في واجهة التطبيق
    globalTabIndex.addListener(_updateUI);
    cartProvider.addListener(_updateUI);
    orderProvider.addListener(_updateUI);
    userProvider.addListener(_updateUI);
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    globalTabIndex.removeListener(_updateUI);
    cartProvider.removeListener(_updateUI);
    orderProvider.removeListener(_updateUI);
    userProvider.removeListener(_updateUI);
    super.dispose();
  }

  Future<void> _launchWhatsApp() async {
    const url = "https://wa.me/201234567890"; 
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open WhatsApp")));
    }
  }

  @override
  Widget build(BuildContext context) {
    int cartCount = cartProvider.totalItems;
    bool isAdmin = userProvider.isAdminMode;
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
                if (globalTabIndex.value == 0)
                  IconButton(
                    icon: const Icon(Icons.search_outlined, size: 24),
                    onPressed: () => showSearch(context: context, delegate: CustomSearchDelegate()),
                  ),
              ],
            ),
          ],
        ),
      ),
      body: IndexedStack( // يحافظ على حالة الصفحات ويجعل التنقل خفيف جداً
        index: globalTabIndex.value,
        children: const [
          HomeScreen(),
          BranchesScreen(),
          CartScreen(),
          ProfileScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _launchWhatsApp,
        backgroundColor: const Color(0xFF25D366),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.message, color: Colors.white, size: 24),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 25, offset: const Offset(0, -5)),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: Colors.black12,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black);
              }
              return GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black38);
            }),
          ),
          child: NavigationBar(
            selectedIndex: globalTabIndex.value,
            onDestinationSelected: (i) => globalTabIndex.value = i,
            backgroundColor: Colors.white,
            elevation: 0,
            height: 70,
            destinations: [
              NavigationDestination(icon: const Icon(Icons.grid_view_outlined), label: isAr ? "الرئيسية" : 'Home'),
              NavigationDestination(icon: const Icon(Icons.near_me_outlined), label: isAr ? "الفروع" : 'Explore'),
              NavigationDestination(
                icon: Badge(label: Text(cartCount.toString()), isLabelVisible: cartCount > 0, child: const Icon(Icons.shopping_bag_outlined)),
                label: isAr ? "السلة" : 'Bag',
              ),
              NavigationDestination(
                icon: Icon(isAdmin ? Icons.admin_panel_settings_outlined : Icons.person_outline),
                label: isAdmin ? (isAr ? "الإدارة" : 'Control') : (isAr ? "حسابي" : 'Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// شريط إعلانات ثابت وأنيق (Premium & Static) لضمان سرعة الويب
class AnnouncementBar extends StatelessWidget {
  const AnnouncementBar({super.key});
  @override
  Widget build(BuildContext context) {
    bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Container(
      height: 35, width: double.infinity, color: Colors.black,
      child: Center(
        child: Text(
          isAr ? "شحن مجاني للطلبات أكثر من 2000 ج.م • كود: PERFECTO10" : "FREE SHIPPING ON ORDERS OVER 2000 EGP • CODE: PERFECTO10",
          style: GoogleFonts.cairo(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = "")];
  @override
  Widget? buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => close(context, null));
  @override
  Widget buildResults(BuildContext context) {
    final res = dummyProducts.where((p) => p.getName(context).toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(itemCount: res.length, itemBuilder: (ctx, i) => ListTile(title: Text(res[i].getName(context))));
  }
  @override
  Widget buildSuggestions(BuildContext context) {
    final res = dummyProducts.where((p) => p.getName(context).toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: res.length, 
      itemBuilder: (ctx, i) => ListTile(
        title: Text(res[i].getName(context)), 
        onTap: () => query = res[i].getName(context)
      )
    );
  }
}
