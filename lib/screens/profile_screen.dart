import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Models & Providers
import '../models/user_provider.dart';
import '../models/order.dart';
import '../models/product_provider.dart';

// Screens
import 'admin_dashboard.dart';
import 'admin_products_screen.dart';
import 'admin_branches_screen.dart';
import 'admin_settings_screen.dart';
import 'register_screen.dart';
import 'login_screen.dart';
import 'chat_screen.dart';
import 'edit_profile_screen.dart';
import 'product_details_screen.dart';

// Config
import '../config/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open the link")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isAdmin = userProvider.isAdminMode;
    final user = userProvider.currentUser;
    final String displayName = isAdmin ? "MANAGER" : (user?.fullName ?? "Guest User");
    bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. LUXURY HEADER (Sleek & Reduced Height) ---
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlack,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40), 
                  bottomRight: Radius.circular(40)
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 35),
              child: Column(
                children: [
                  GestureDetector(
                    onLongPress: () => _showAdminLogin(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, 
                        border: Border.all(color: AppColors.accentGold, width: 2)
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white10,
                        child: Icon(
                          isAdmin ? Icons.admin_panel_settings : Icons.person_outline, 
                          size: 40, 
                          color: Colors.white
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    displayName.toUpperCase(),
                    style: GoogleFonts.cairo(
                      color: Colors.white, 
                      fontSize: 20, 
                      fontWeight: FontWeight.w900, 
                      letterSpacing: 2
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  if (userProvider.isLoggedIn && !isAdmin)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold, 
                        borderRadius: BorderRadius.circular(15)
                      ),
                      child: Text(
                        "${user?.loyaltyPoints ?? 0} ${isAr ? 'نقطة ولاء' : 'LOYALTY POINTS'}", 
                        style: const TextStyle(
                          color: Colors.black, 
                          fontSize: 9, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withOpacity(0.2), 
                      borderRadius: BorderRadius.circular(20), 
                      border: Border.all(color: AppColors.accentGold, width: 0.5)
                    ),
                    child: Text(
                      isAdmin ? "SYSTEM ADMIN" : "ELITE MEMBER", 
                      style: GoogleFonts.cairo(
                        color: AppColors.accentGold, 
                        fontSize: 10, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 1
                      )
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 2. ADMIN TOOLS ---
                  if (isAdmin) ...[
                    _buildSectionTitle(isAr ? "أدوات الإدارة" : "ADMINISTRATION"),
                    _buildFeatureGrid([
                      _buildGridItem(context, Icons.analytics_outlined, isAr ? "المبيعات" : "Dashboard", () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const AdminDashboard()))),
                      _buildGridItem(context, Icons.inventory_2_outlined, isAr ? "المنتجات" : "Products", () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const AdminProductsScreen()))),
                      _buildGridItem(context, Icons.list_alt_outlined, isAr ? "الطلبات" : "Orders", () => _showOrdersTracking(context, true)), 
                      _buildGridItem(context, Icons.location_city_outlined, isAr ? "الفروع" : "Branches", () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const AdminBranchesScreen()))),
                      _buildGridItem(context, Icons.people_outline, isAr ? "العملاء" : "Clients", () => _showCustomersList(context, isAr)),
                      _buildGridItem(context, Icons.settings_outlined, isAr ? "الإعدادات" : "Settings", () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const AdminSettingsScreen()))),
                    ]),
                    const SizedBox(height: 35),
                  ],

                  // --- 3. PERSONAL ---
                  _buildSectionTitle(isAr ? "حسابي" : "MY EXPERIENCE"),
                  _buildModernList([
                    _buildListTile(context, Icons.history_outlined, isAr ? "تتبع طلباتي" : "Order Tracking", () => _showOrdersTracking(context, false)),
                    if (userProvider.isLoggedIn && !isAdmin) ...[
                      _buildListTile(context, Icons.favorite_border, isAr ? "قائمة الأمنيات" : "My Wishlist", () => _showWishlist(context, isAr)),
                      _buildListTile(context, Icons.manage_accounts_outlined, isAr ? "تعديل البيانات" : "Profile Settings", () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const EditProfileScreen()))),
                    ]
                  ]),

                  const SizedBox(height: 25),
                  _buildSectionTitle(isAr ? "المساعدة" : "ASSISTANCE"),
                  _buildModernList([
                    _buildListTile(context, Icons.chat_bubble_outline_rounded, isAr ? "شات الدعم" : "Live Concierge", () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const ChatScreen()))),
                    _buildListTile(context, Icons.camera_alt_outlined, "Instagram", () => _launchURL(context, "https://www.instagram.com/perfectoegypt1")),
                    if (!userProvider.isLoggedIn && !isAdmin) ...[
                      _buildListTile(context, Icons.person_add_outlined, isAr ? "فتح حساب" : "Join Perfecto", () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const RegisterScreen()))),
                      _buildListTile(context, Icons.login_outlined, isAr ? "تسجيل دخول" : "Sign In", () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const LoginScreen()))),
                    ],
                  ]),

                  const SizedBox(height: 40),

                  if (isAdmin)
                    Center(
                      child: TextButton.icon(
                        onPressed: () => userProvider.exitAdminMode(),
                        icon: const Icon(Icons.storefront_outlined, color: Colors.blueAccent),
                        label: Text(isAr ? "العودة للمتجر" : "BACK TO STORE", style: GoogleFonts.cairo(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  
                  if (userProvider.isLoggedIn || isAdmin)
                    Center(
                      child: TextButton.icon(
                        onPressed: () => userProvider.logout(),
                        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                        label: Text(isAr ? "خروج نهائي" : "SIGN OUT", style: GoogleFonts.cairo(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Center(child: Text("PERFECTO LUXURY v1.2.0", style: TextStyle(color: Colors.black26, fontSize: 9, letterSpacing: 3))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, right: 4),
      child: Text(title, style: GoogleFonts.cairo(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
    );
  }

  Widget _buildFeatureGrid(List<Widget> children) {
    return GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1, children: children);
  }

  Widget _buildGridItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(15), 
          border: Border.all(color: Colors.black.withOpacity(0.05))
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Icon(icon, color: Colors.black, size: 20),
            const SizedBox(height: 6),
            Text(title, style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ]
        ),
      ),
    );
  }

  Widget _buildModernList(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))]
      ), 
      child: Column(children: children)
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87, size: 20), 
      title: Text(title, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w500)), 
      trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.black26), 
      onTap: onTap
    );
  }

  void _showAdminLogin(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), 
        title: Text("System Access", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)), 
        content: TextField(controller: controller, obscureText: true, decoration: const InputDecoration(hintText: "Access Key")), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () { 
              if (controller.text == "1234") { 
                context.read<UserProvider>().enterAdminMode(); 
                Navigator.pop(ctx); 
              } 
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black), 
            child: const Text("Verify")
          )
        ]
      )
    );
  }

  void _showOrdersTracking(BuildContext context, bool isAdmin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => Consumer<OrderProvider>(
        builder: (context, provider, _) {
          final user = context.read<UserProvider>().currentUser;
          final orders = isAdmin 
              ? provider.orders 
              : provider.orders.where((o) => o.customerPhone == user?.phone).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(isAdmin ? "Order Management" : "My Orders", style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(height: 30),
                Expanded(
                  child: orders.isEmpty 
                    ? const Center(child: Text("No records found."))
                    : ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (ctx, i) {
                          final order = orders[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 15),
                            child: ListTile(
                              title: Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("${order.totalAmount} EGP • ${order.statusText}"),
                              trailing: isAdmin ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_road), 
                                    onPressed: () => _showUpdateStatusDialog(context, order.id)
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_forever, color: Colors.red), 
                                    onPressed: () => provider.deleteOrder(order.id)
                                  ),
                                ],
                              ) : const Icon(Icons.chevron_right),
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context, String orderId) {
    final provider = context.read<OrderProvider>();
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: const Text("Shipment Status"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text("Processing"), onTap: () { provider.updateOrderStatus(orderId, OrderStatus.processing); Navigator.pop(ctx); }),
            ListTile(title: const Text("Shipped"), onTap: () { provider.updateOrderStatus(orderId, OrderStatus.shipped); Navigator.pop(ctx); }),
            ListTile(title: const Text("Delivered"), onTap: () { provider.updateOrderStatus(orderId, OrderStatus.delivered); Navigator.pop(ctx); }),
          ],
        ),
      )
    );
  }

  void _showWishlist(BuildContext context, bool isAr) {
    final wishlistIds = context.read<UserProvider>().currentUser?.wishlistIds ?? [];
    final products = context.read<ProductProvider>().products.where((p) => wishlistIds.contains(p.id)).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(isAr ? "قائمة الأمنيات" : "My Wishlist", style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(height: 30),
            Expanded(
              child: products.isEmpty 
                ? Center(child: Text(isAr ? "القائمة فارغة" : "Wishlist is empty"))
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (ctx, i) => ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(products[i].imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                      ),
                      title: Text(products[i].getName(context)),
                      subtitle: Text("${products[i].price} EGP"),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () => context.read<UserProvider>().toggleWishlist(products[i].id),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: products[i])));
                      },
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomersList(BuildContext context, bool isAr) {
    final users = context.read<UserProvider>().allUsers;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(isAr ? "قائمة العملاء" : "Clients Directory", style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (ctx, i) => ListTile(
                  leading: const CircleAvatar(backgroundColor: AppColors.primaryBlack, child: Icon(Icons.person, color: Colors.white, size: 18)),
                  title: Text(users[i].fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(users[i].phone),
                  trailing: Text("${users[i].loyaltyPoints} Pts", style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}
