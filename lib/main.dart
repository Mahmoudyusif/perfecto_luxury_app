import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Config & Theme
import 'config/app_colors.dart';

// Screens
import 'screens/splash_screen.dart';

// Models & Providers
import 'models/cart.dart';
import 'models/user_provider.dart';
import 'models/order.dart';
import 'models/navigation_provider.dart';
import 'models/promo_provider.dart';
import 'models/product_provider.dart';
import 'models/branch.dart';
import 'models/announcement_provider.dart';

// Services
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      // NOTE: Placeholders for GitHub security. 
      // Replace with your real Firebase config locally if needed.
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
      // تهيئة نظام الإشعارات للموبايل
      await NotificationService.initialize();
    }
  } catch (e) {
    debugPrint("System Initialization Error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => PromoProvider()),
        ChangeNotifierProvider(create: (_) => BranchProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: const PerfectoApp(),
    ),
  );
}

class PerfectoApp extends StatelessWidget {
  const PerfectoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Perfecto Luxury',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('ar', 'EG')],
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primaryBlack,
        scaffoldBackgroundColor: AppColors.backgroundGrey,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlack, 
          primary: AppColors.primaryBlack, 
          secondary: AppColors.accentGold,
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryBlack,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.primaryBlack, 
            fontSize: 14, 
            fontWeight: FontWeight.w900, 
            letterSpacing: 4,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlack,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 55),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 0,
            textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
        ),
      ),
      home: const SplashScreen(), 
    );
  }
}
