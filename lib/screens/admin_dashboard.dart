import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import 'admin_promo_screen.dart';
import 'admin_notifications_screen.dart';
import 'admin_announcements_screen.dart';
import '../config/app_colors.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    // استخدام watch لمراقبة مبيعات اليوم والشهر لحظياً
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text(isAr ? "لوحة التحكم" : "MANAGER DASHBOARD"),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isAr ? "الأداء المالي" : "Financial Performance", 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 20),
            
            // بطاقة المبيعات الذكية
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryBlack,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isAr ? "مبيعات اليوم" : "TODAY'S SALES", 
                              style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1)),
                          const SizedBox(height: 8),
                          Text("${orderProvider.todayTotalSales.toInt()} EGP", 
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Icon(Icons.trending_up, color: Colors.greenAccent, size: 40),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.white10)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isAr ? "مبيعات الشهر" : "MONTHLY REVENUE", 
                              style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1)),
                          const SizedBox(height: 8),
                          Text("${orderProvider.monthlyTotalSales.toInt()} EGP", 
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Icon(Icons.calendar_month_outlined, color: AppColors.accentGold, size: 30),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            
            Text(isAr ? "أدوات الإدارة وال Engagement" : "Management & Marketing", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            // شبكة الأدوات
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildActionCard(
                  context,
                  icon: Icons.local_offer_outlined,
                  color: Colors.green,
                  title: isAr ? "الأكواد" : "Promos",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPromoScreen())),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.campaign_outlined,
                  color: Colors.blue,
                  title: isAr ? "شريط العروض" : "Offers Bar",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAnnouncementsScreen())),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.notifications_active_outlined,
                  color: Colors.orange,
                  title: isAr ? "الإشعارات" : "Notify",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotificationsScreen())),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.chat_bubble_outline,
                  color: Colors.purple,
                  title: isAr ? "محادثات الدعم" : "Support",
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 30),
            
            Text(isAr ? "الأصناف الأكثر مبيعاً" : "Top Selling Items", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            if (orderProvider.soldItemsStats.isEmpty)
              const Center(child: Text("No sales data yet", style: TextStyle(color: Colors.grey)))
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(15), 
                  border: Border.all(color: Colors.grey[200]!)
                ),
                child: Column(
                  children: orderProvider.soldItemsStats.entries.map((entry) => ListTile(
                    leading: const CircleAvatar(backgroundColor: AppColors.primaryBlack, radius: 4),
                    title: Text(entry.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    trailing: Text("${entry.value} ${isAr ? 'قطع' : 'Sold'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  )).toList(),
                ),
              ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required IconData icon, required Color color, required String title, required VoidCallback onTap}) {
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
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
