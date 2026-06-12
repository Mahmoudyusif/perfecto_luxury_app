import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_provider.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/chat_provider.dart';
import 'admin_dashboard.dart';
import 'admin_products_screen.dart';
import 'admin_branches_screen.dart';
import 'admin_settings_screen.dart';
import 'register_screen.dart';
import 'login_screen.dart';
import 'chat_screen.dart';
import 'edit_profile_screen.dart';
import 'product_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    userProvider.addListener(_refreshUI);
    orderProvider.addListener(_refreshUI);
  }
  void _refreshUI() { if (mounted) setState(() {}); }
  @override
  void dispose() {
    userProvider.removeListener(_refreshUI);
    orderProvider.removeListener(_refreshUI);
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open the link")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = userProvider.isAdminMode;
    final user = userProvider.currentUser;
    final String displayName = isAdmin ? "MANAGER" : (user?.fullName ?? "Guest User");
    bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- LUXURY HEADER ---
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 35),
              child: Column(
                children: [
                  GestureDetector(
                    onLongPress: _showAdminLogin,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFD4AF37), width: 2)),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white10,
                        child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person_outline, size: 40, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    displayName.toUpperCase(),
                    style: GoogleFonts.cairo(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2),
                  ),
                  const SizedBox(height: 8),
                  if (userProvider.isLoggedIn && !isAdmin)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(15)),
                      child: Text("${user?.loyaltyPoints ?? 0} ${isAr ? 'نقطة ولاء' : 'LOYALTY POINTS'}", style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD4AF37), width: 0.5)),
                    child: Text(isAdmin ? "SYSTEM ADMIN" : "ELITE MEMBER", style: GoogleFonts.cairo(color: const Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isAdmin) ...[
                    _buildSectionTitle(isAr ? "أدوات الإدارة" : "ADMINISTRATION"),
                    _buildFeatureGrid([
                      _buildGridItem(Icons.analytics_outlined, isAr ? "المبيعات" : "Dashboard", () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const AdminDashboard()))),
                      _buildGridItem(Icons.inventory_2_outlined, isAr ? "المنتجات" : "Products", () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const AdminProductsScreen()))),
                      _buildGridItem(Icons.list_alt_outlined, isAr ? "الطلبات" : "Orders", () => _showOrdersTracking(true)),
                      _buildGridItem(Icons.location_city_outlined, isAr ? "الفروع" : "Branches", () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const AdminBranchesScreen()))),
                      _buildGridItem(Icons.people_outline, isAr ? "العملاء" : "Clients", () => _showCustomersList(isAr)),
                      _buildGridItem(Icons.settings_outlined, isAr ? "الإعدادات" : "Settings", () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const AdminSettingsScreen()))),
                    ]),
                    const SizedBox(height: 35),
                  ],

                  _buildSectionTitle(isAr ? "حسابي" : "MY EXPERIENCE"),
                  _buildModernList([
                    _buildListTile(Icons.history_outlined, isAr ? "تتبع طلباتي" : "Order Tracking", () => _showOrdersTracking(false)),
                    if (userProvider.isLoggedIn && !isAdmin) ...[
                      _buildListTile(Icons.favorite_border, isAr ? "قائمة الأمنيات" : "My Wishlist", () => _showWishlist(context, isAr)),
                      _buildListTile(Icons.manage_accounts_outlined, isAr ? "تعديل البيانات" : "Profile Settings", () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const EditProfileScreen()))),
                    ]
                  ]),

                  const SizedBox(height: 25),
                  _buildSectionTitle(isAr ? "المساعدة" : "ASSISTANCE"),
                  _buildModernList([
                    _buildListTile(Icons.chat_bubble_outline_rounded, isAr ? "شات الدعم" : "Live Concierge", () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const ChatScreen()))),
                    _buildListTile(Icons.camera_alt_outlined, "Instagram", () => _launchURL("https://www.instagram.com/perfectoegypt1")),
                    if (!userProvider.isLoggedIn && !isAdmin) ...[
                      _buildListTile(Icons.person_add_outlined, isAr ? "فتح حساب" : "Join Perfecto", () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const RegisterScreen()))),
                      _buildListTile(Icons.login_outlined, isAr ? "تسجيل دخول" : "Sign In", () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const LoginScreen()))),
                    ],
                  ]),

                  const SizedBox(height: 40),

                  if (isAdmin)
                    Center(
                      child: TextButton.icon(
                        onPressed: () => userProvider.exitAdminMode(),
                        icon: const Icon(Icons.storefront_outlined, color: Colors.blueAccent),
                        label: Text(isAr ? "العودة للمتجر (كعميل)" : "BACK TO STORE MODE", style: GoogleFonts.cairo(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  
                  if (userProvider.isLoggedIn || isAdmin)
                    Center(
                      child: TextButton.icon(
                        onPressed: () => userProvider.logout(),
                        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                        label: Text(isAr ? "خروج نهائي" : "LOGOUT", style: GoogleFonts.cairo(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 2)),
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
    return Padding(padding: const EdgeInsets.only(left: 4, bottom: 12, right: 4), child: Text(title, style: GoogleFonts.cairo(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.5)));
  }

  Widget _buildFeatureGrid(List<Widget> children) {
    return GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1, children: children);
  }

  Widget _buildGridItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(15), child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.black.withOpacity(0.05))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Colors.black, size: 20), const SizedBox(height: 6), Text(title, style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center)])));
  }

  Widget _buildModernList(List<Widget> children) {
    return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))]), child: Column(children: children));
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon, color: Colors.black87, size: 20), title: Text(title, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w500)), trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.black26), onTap: onTap);
  }

  void _showWishlist(BuildContext context, bool isAr) {
    final wishlistIds = userProvider.currentUser?.wishlistIds ?? [];
    final wishlistProducts = dummyProducts.where((p) => wishlistIds.contains(p.id)).toList();
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))), builder: (ctx) => Container(
      height: MediaQuery.of(context).size.height * 0.8, padding: const EdgeInsets.all(24),
      child: Column(children: [
        Text(isAr ? "قائمة الأمنيات" : "My Wishlist", style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold)),
        const Divider(height: 30),
        Expanded(child: wishlistProducts.isEmpty ? Center(child: Text(isAr ? "القائمة فارغة" : "Wishlist is empty")) : ListView.builder(itemCount: wishlistProducts.length, itemBuilder: (ctx, i) {
          final p = wishlistProducts[i];
          return ListTile(leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(imageUrl: p.imageUrl, width: 50, height: 50, fit: BoxFit.cover)), title: Text(p.getName(context)), subtitle: Text("${p.price} EGP"), trailing: const Icon(Icons.favorite, color: Colors.red), onTap: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: p))); });
        })),
      ]),
    ));
  }

  void _showAdminLogin() {
    final controller = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: Text("System Access", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)), content: TextField(controller: controller, obscureText: true, decoration: const InputDecoration(hintText: "Access Key")), actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
      ElevatedButton(onPressed: () { if (controller.text == "1234") { userProvider.enterAdminMode(); Navigator.pop(ctx); } }, style: ElevatedButton.styleFrom(backgroundColor: Colors.black), child: const Text("Verify"))
    ]));
  }

  void _showCustomersList(bool isAr) {
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))), builder: (ctx) => ListenableBuilder(
      listenable: userProvider,
      builder: (context, _) => Container(
        height: MediaQuery.of(context).size.height * 0.85, padding: const EdgeInsets.all(24),
        child: Column(children: [
          Text(isAr ? "قائمة العملاء" : "Clients Directory", style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(height: 30),
          Expanded(child: ListView.builder(itemCount: userProvider.allUsers.length, itemBuilder: (ctx, i) {
            final user = userProvider.allUsers[i];
            final userOrders = orderProvider.orders.where((o) => o.customerPhone == user.phone).toList();
            final totalSpent = userOrders.fold(0.0, (sum, o) => sum + o.totalAmount);
            return Card(margin: const EdgeInsets.only(bottom: 12), elevation: 0, color: Colors.grey[50], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), child: ListTile(title: Text(user.fullName, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)), subtitle: Text("${user.phone} • ${user.loyaltyPoints} Pts"), trailing: Text("${totalSpent.toInt()} EGP", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)), onTap: () => _showUserOrdersHistory(user.fullName, userOrders)));
          }))
        ]),
      ),
    ));
  }

  void _showUserOrdersHistory(String name, List<OrderItem> orders) {
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))), builder: (ctx) => Container(
      height: MediaQuery.of(context).size.height * 0.7, padding: const EdgeInsets.all(24),
      child: Column(children: [
        Text(name, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(height: 30),
        Expanded(child: orders.isEmpty ? const Center(child: Text("No records found.")) : ListView.builder(itemCount: orders.length, itemBuilder: (ctx, i) {
          final order = orders[i];
          return ListTile(title: Text("${order.totalAmount} EGP"), subtitle: Text("${order.dateTime.day}/${order.dateTime.month}"), trailing: Text(order.statusText, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)));
        }))
      ]),
    ));
  }

  void _showOrdersTracking(bool isAdmin) {
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))), builder: (ctx) => ListenableBuilder(
      listenable: orderProvider,
      builder: (context, child) {
        final filteredOrders = isAdmin ? orderProvider.orders : orderProvider.orders.where((o) => o.customerPhone == userProvider.currentUser?.phone && o.status != OrderStatus.cancelled).toList();
        return Container(
          height: MediaQuery.of(context).size.height * 0.85, padding: const EdgeInsets.all(24),
          child: Column(children: [
            Text(isAdmin ? "Shipment Management" : "My Orders Tracking", style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(height: 30),
            Expanded(child: filteredOrders.isEmpty ? const Center(child: Text("No active records.")) : ListView.builder(itemCount: filteredOrders.length, itemBuilder: (ctx, i) {
              final order = filteredOrders[i];
              return Card(margin: const EdgeInsets.only(bottom: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold)), Text(order.statusText, style: TextStyle(color: order.status == OrderStatus.cancelled ? Colors.red : Colors.green, fontWeight: FontWeight.bold))]),
                const SizedBox(height: 10),
                Text("Total Payable: ${order.totalAmount} EGP"),
                if (order.status != OrderStatus.cancelled && order.remainingTimeText != "N/A") Padding(padding: const EdgeInsets.only(top: 8), child: Text("Arrival: ${order.remainingTimeText}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
                if (isAdmin) Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  IconButton(icon: const Icon(Icons.edit_road), onPressed: () => _showUpdateStatusDialog(order.id)),
                  IconButton(icon: const Icon(Icons.timer_outlined), onPressed: () => _showSetTimeDialog(order.id)),
                  IconButton(icon: const Icon(Icons.delete_forever, color: Colors.red), onPressed: () => orderProvider.deleteOrder(order.id)),
                ])
              ])));
            }))
          ]),
        );
      },
    ));
  }

  void _showSetTimeDialog(String orderId) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: const Text("Set Arrival Time"), content: TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Enter hours from now")), actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
      ElevatedButton(onPressed: () { if (ctrl.text.isNotEmpty) { orderProvider.updateOrderDelivery(orderId, int.parse(ctrl.text)); Navigator.pop(ctx); } }, child: const Text("Update"))
    ]));
  }

  void _showUpdateStatusDialog(String orderId) {
    showDialog(context: context, builder: (ctx) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: const Text("Shipment Status"), content: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(title: const Text("Processing"), onTap: () { orderProvider.updateOrderStatus(orderId, OrderStatus.processing); Navigator.pop(ctx); }),
      ListTile(title: const Text("Shipped"), onTap: () { orderProvider.updateOrderStatus(orderId, OrderStatus.shipped); Navigator.pop(ctx); }),
      ListTile(title: const Text("Delivered"), onTap: () { orderProvider.updateOrderStatus(orderId, OrderStatus.delivered); Navigator.pop(ctx); }),
    ])));
  }
}
