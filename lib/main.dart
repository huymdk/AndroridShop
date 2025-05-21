// Đầu file main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:thuongmaidientu/services/banner_service.dart'; // Đường dẫn đúng

// Import các service và màn hình chính của bạn
import 'package:thuongmaidientu/services/auth_service.dart';
import 'package:thuongmaidientu/services/product_service.dart';
import 'package:thuongmaidientu/presentation/providers_or_blocs/cart_provider.dart';
import 'package:thuongmaidientu/presentation/providers_or_blocs/user_provider.dart'; // Đảm bảo đã import UserProvider
import 'package:thuongmaidientu/services/order_service.dart';

import 'package:thuongmaidientu/presentation/screens/splash/splash_screen.dart';
import 'package:thuongmaidientu/presentation/screens/auth/login_screen.dart';
import 'package:thuongmaidientu/presentation/screens/home/home_screen.dart';
// Import các màn hình khác nếu bạn đã tạo và muốn định nghĩa route
// import 'package:thuongmaidientu/presentation/screens/cart/cart_screen.dart';
// import 'package:thuongmaidientu/presentation/screens/checkout/checkout_screen.dart';
// import 'package:thuongmaidientu/presentation/screens/product/product_detail_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<OrderService>(create: (_) => OrderService()),
        Provider<BannerService>(create: (_) => BannerService()), // <<< THÊM DÒNG NÀY

        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(context.read<AuthService>()),
        ),
        Provider<ProductService>(create: (_) => ProductService()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        Provider<OrderService>(create: (_) => OrderService()),
      ],
      child: MaterialApp(
        title: 'Shop TMĐT',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        // ================================================================
        // SỬA Ở ĐÂY: Đặt AuthWrapper làm home để nó quyết định màn hình
        // ================================================================
        home: const AuthWrapper(),
        // ================================================================
        // Ví dụ về định nghĩa routes (bỏ comment và sửa nếu bạn dùng):
        // routes: {
        //   // '/': (ctx) => const AuthWrapper(), // Không cần nếu AuthWrapper là home
        //   // LoginScreen.routeName: (ctx) => const LoginScreen(),
        //   // HomeScreen.routeName: (ctx) => const HomeScreen(),
        //   // CartScreen.routeName: (ctx) => const CartScreen(),
        //   // CheckoutScreen.routeName: (ctx) => const CheckoutScreen(),
        // },
        // onGenerateRoute: (settings) {
        //   // ... (logic onGenerateRoute nếu cần) ...
        //   return null;
        // },
      ),
    );
  }
}

// Widget kiểm tra trạng thái đăng nhập và điều hướng
// (Sử dụng phiên bản đầy đủ hơn có isLoading)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe UserProvider để biết trạng thái đăng nhập và khi nào thông tin user (với role) sẵn sàng
    final userProvider = Provider.of<UserProvider>(context); // listen: true (mặc định)

    // print("AuthWrapper build - isLoading: ${userProvider.isLoading}, isLoggedIn: ${userProvider.isLoggedIn}, userUID: ${userProvider.appUserWithRole?.uid}");

    if (userProvider.isLoading) {
      // Nếu UserProvider đang trong quá trình tải thông tin user (ví dụ: fetch role)
      // hoặc đang chờ authStateChanges lần đầu, hiển thị SplashScreen.
      return const SplashScreen();
    }

    if (userProvider.isLoggedIn) {
      // Người dùng đã đăng nhập và UserProvider đã có thông tin AppUser
      return const HomeScreen();
    } else {
      // Người dùng chưa đăng nhập
      return const LoginScreen();
    }
  }
}