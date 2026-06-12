# Perfecto Luxury 👗 - Premium Flutter E-commerce Suite

**Perfecto** is a production-grade Flutter application designed for high-end fashion brands. It demonstrates a sophisticated dual-user ecosystem: a luxurious shopping experience for customers and a comprehensive, real-time command center for brand owners.

## 🏗 Project Architecture & Clean Code
This project follows a **Modular Provider-based Architecture**, ensuring scalability and ease of maintenance:
- **State Management:** Utilizes `ChangeNotifier` and `Provider` for reactive UI updates.
- **Backend:** Fully integrated with **Firebase Ecosystem** (Firestore for real-time NoSQL data, Cloud Messaging for notifications).
- **Navigation:** Optimized using `IndexedStack` to maintain state and provide near-instant tab switching.
- **Security:** Hidden entry points for Admin tools and protected API configuration placeholders for open-source sharing.

## 🚀 Key Features

### 🛍 For Customers (Elite Member Mode)
- **Loyalty Program:** Automated points calculation system integrated into the order pipeline.
- **Real-time Discovery:** Advanced search and dynamic category filtering.
- **Interactive UI:** Smooth transitions, Hero animations, and auto-scrolling promotional banners.
- **Wishlist & Cart:** Full persistence using local storage and cloud syncing.

### 💼 For Brand Owners (The Dashboard)
- **Financial Analytics:** Live revenue tracking (Daily/Monthly).
- **Inventory Control:** Instant product management (Add/Delete/Stock Toggle).
- **Campaign Manager:** Create and manage dynamic promo codes and top-bar announcements.
- **Direct Engagement:** Send broadcast push notifications to all users directly from the app.

## 🛠 Tech Stack
- **Framework:** Flutter (3.x)
- **Database:** Firebase Firestore
- **Messaging:** Firebase Cloud Messaging (FCM)
- **Fonts:** Cairo (Google Fonts)
- **Local Storage:** SharedPreferences

## 📂 Folder Structure
```
lib/
├── models/       # Data entities & logic providers
├── screens/      # Feature-specific UI views
├── services/     # External integrations (Notifications, etc.)
└── widgets/      # Reusable UI components
```

## 📸 How to Preview
1. Clone the repository.
2. Run `flutter pub get`.
3. For Admin access: Go to **Account** -> **Long Press Profile Avatar** -> Enter **1234**.

---
**Developed by Mahmoud Youssef**  
*Passionate about building scalable mobile experiences.*
