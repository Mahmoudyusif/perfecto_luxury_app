import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Models & Providers
import '../models/cart.dart';
import '../models/order.dart';
import '../models/user_provider.dart';
import '../models/promo_provider.dart';

// Config
import '../config/app_colors.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalAmount;
  const CheckoutScreen({super.key, required this.totalAmount});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedPayment = 'cash';
  String selectedGovernorate = 'Cairo';
  bool isProcessing = false;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _promoController = TextEditingController();
  double discount = 0.0;

  final List<String> governorates = [
    'Cairo', 'Giza', 'Alexandria', 'Dakahlia', 'Red Sea', 'Beheira', 'Fayoum', 'Gharbia', 'Ismailia', 'Monufia', 'Minya', 'Qalyubia', 'New Valley', 'Sharqia', 'Suez', 'Aswan', 'Assiut', 'Beni Suef', 'Port Said', 'Damietta', 'South Sinai', 'Kafr El Sheikh', 'Matrouh', 'Luxor', 'Qena', 'North Sinai', 'Sohag'
  ];

  void _applyPromo() {
    final promoProvider = context.read<PromoProvider>();
    bool success = promoProvider.validateAndApply(_promoController.text, widget.totalAmount);
    if (success) {
      setState(() {
        discount = widget.totalAmount * (promoProvider.appliedPromo!.discountPercent / 100);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Promo Code Applied!"), backgroundColor: Colors.green)
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid or expired code"), backgroundColor: Colors.red)
      );
    }
  }

  Future<void> _processPayment() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your detailed address"))
      );
      return;
    }

    setState(() => isProcessing = true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final userProvider = context.read<UserProvider>();
    final cartProvider = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final promoProvider = context.read<PromoProvider>();

    final user = userProvider.currentUser;
    if (user != null) {
      await orderProvider.addOrder(
        List.from(cartProvider.items),
        widget.totalAmount - discount,
        discount,
        selectedPayment,
        "${_addressController.text}, $selectedGovernorate",
        user.phone,
        user.fullName,
      );
      cartProvider.clearCart();
      promoProvider.removePromo();
    }

    setState(() => isProcessing = false);
    if (mounted) _showOrderConfirmedDialog();
  }

  void _showOrderConfirmedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Order Confirmed!"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 15),
            Text("Your order has been placed successfully. You earned loyalty points!"),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text("BACK TO SHOPPING"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double finalTotal = widget.totalAmount - discount;
    bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(isAr ? "إتمام الطلب" : "SECURE CHECKOUT")),
      body: isProcessing 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Promo Code Section
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!)
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promoController,
                          decoration: const InputDecoration(
                            hintText: "Promo Code", 
                            border: InputBorder.none
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _applyPromo, 
                        child: const Text("APPLY", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlack))
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text("Shipping Address", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedGovernorate,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: governorates.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (val) => setState(() => selectedGovernorate = val!),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: "Detailed Address", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 30),
                const Text("Payment Method", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                RadioListTile(
                  value: 'cash', 
                  groupValue: selectedPayment, 
                  title: const Text("Cash on Delivery"), 
                  onChanged: (v) => setState(() => selectedPayment = v!)
                ),
                RadioListTile(
                  value: 'card', 
                  groupValue: selectedPayment, 
                  title: const Text("Credit Card"), 
                  onChanged: (v) => setState(() => selectedPayment = v!)
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlack, 
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Column(
                    children: [
                      if (discount > 0) 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                            children: [
                              const Text("Discount", style: TextStyle(color: Colors.greenAccent)), 
                              Text("-$discount EGP", style: const TextStyle(color: Colors.greenAccent))
                            ]
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                        children: [
                          const Text("Total Payable", style: TextStyle(color: Colors.white, fontSize: 16)), 
                          Text("${finalTotal.toInt()} EGP", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))
                        ]
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _processPayment, 
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primaryBlack),
                        child: const Text("PLACE ORDER")
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
