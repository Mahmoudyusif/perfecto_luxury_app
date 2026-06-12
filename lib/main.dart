import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'screens/home_screen.dart';
import 'screens/branches_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/product_details_screen.dart';
import 'models/cart.dart';
import 'models/user_provider.dart';
import 'models/order.dart';
import 'models/navigation_provider.dart';
import 'models/promo_provider.dart';
import 'models/product_provider.dart';
import 'models/branch.dart';
import 'models/announcement_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      // NOTE: Replace these placeholders with your actual Firebase Web config for local development.
      // Do not push real API keys to public repositories.
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "YOUR-API-KEY-HERE",
          appId: "YOUR-APP-ID-HERE",
          messagingSenderId: "YOUR-SENDER-ID-HERE",
          projectId: "perfecto-pro",
          storageBucket: "perfecto-pro.firebasestorage.app",
        ),
      );
    } else {
      await Firebase.initializeApp();
      await NotificationService.initialize();
    }
  } catch (e) {
    debugPrint("System Init Error: $e");
  }
  runApp(const PerfectoApp());
}

class PerfectoApp extends StatelessWidget {
  const PerfectoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Perfecto Brand',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('ar', 'EG')],
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black, primary: Colors.black, secondary: const Color(0xFFD4AF37)),
        textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.cairo(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 4),
        ),
      ),
      home: const LocalSplashScreen(),
    );
  }
}

class LocalSplashScreen extends StatefulWidget {
  const LocalSplashScreen({super.key});
  @override
  State<LocalSplashScreen> createState() => _LocalSplashScreenState();
}

class _LocalSplashScreenState extends State<LocalSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _controller.forward();
    Timer(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => const MainNavigation()));
    });
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _controller,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
                child: const Text("PERFECTO", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w200, letterSpacing: 15)),
              ),
              const SizedBox(height: 20),
              const Text("WELCOME TO PERFECTO WORLD", style: TextStyle(fontSize: 12, letterSpacing: 4, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  @override
  void initState() {
    super.initState();
    globalTabIndex.addListener(_rebuild);
    cartProvider.addListener(_rebuild);
    orderProvider.addListener(_rebuild);
    userProvider.addListener(_rebuild);
    promoProvider.addListener(_rebuild);
    productProvider.addListener(_rebuild);
    branchProvider.addListener(_rebuild);
    announcementProvider.addListener(_rebuild);
  }
  void _rebuild() { if (mounted) setState(() {}); }
  @override
  void dispose() {
    globalTabIndex.removeListener(_rebuild);
    cartProvider.removeListener(_rebuild);
    orderProvider.removeListener(_rebuild);
    userProvider.removeListener(_rebuild);
    promoProvider.removeListener(_rebuild);
    productProvider.removeListener(_rebuild);
    branchProvider.removeListener(_rebuild);
    announcementProvider.removeListener(_rebuild);
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
                IconButton(
                  icon: const Icon(Icons.search, size: 20),
                  onPressed: () => showSearch(context: context, delegate: CustomSearchDelegate()),
                )
              ],
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: globalTabIndex.value,
        children: const [HomeScreen(), BranchesScreen(), CartScreen(), ProfileScreen()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _launchWhatsApp,
        backgroundColor: const Color(0xFF25D366),
        shape: const CircleBorder(),
        child: const Icon(Icons.message, color: Colors.white, size: 24),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: globalTabIndex.value,
        onDestinationSelected: (i) => globalTabIndex.value = i,
        backgroundColor: Colors.white,
        indicatorColor: Colors.black12,
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
            label: isAdmin ? (isAr ? "الإدارة" : 'Control') : (isAr ? "حسابي" : 'Account')
          ),
        ],
      ),
    );
  }
}

class AnnouncementBar extends StatefulWidget {
  const AnnouncementBar({super.key});

  @override
  State<AnnouncementBar> createState() => _AnnouncementBarState();
}

class _AnnouncementBarState extends State<AnnouncementBar> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startScrolling();
  }

  void _startScrolling() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients && announcementProvider.messages.isNotEmpty) {
        _currentIndex = (_currentIndex + 1) % announcementProvider.messages.length;
        _pageController.animateToPage(
          _currentIndex, 
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = announcementProvider.messages;
    if (messages.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 35,
      width: double.infinity,
      color: Colors.black,
      child: PageView.builder(
        controller: _pageController,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return Center(
            child: Text(
              messages[index].toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: Colors.white, 
                fontSize: 9, 
                fontWeight: FontWeight.bold, 
                letterSpacing: 1.2
              ),
            ),
          );
        },
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
    final res = productProvider.products.where((p) => p.getName(context).toLowerCase().contains(query.toLowerCase())).toList();
    return _buildList(res);
  }
  
  @override
  Widget buildSuggestions(BuildContext context) {
    final res = productProvider.products.where((p) => p.getName(context).toLowerCase().contains(query.toLowerCase())).toList();
    return _buildList(res);
  }

  Widget _buildList(List<dynamic> res) {
    return ListView.builder(
      itemCount: res.length,
      itemBuilder: (ctx, i) => ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(res[i].imageUrl, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.broken_image)),
        ),
        title: Text(res[i].getName(ctx)),
        subtitle: Text("${res[i].price} EGP"),
        onTap: () {
          close(ctx, null);
          Navigator.push(ctx, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: res[i])));
        }
      ),
    );
  }
}
