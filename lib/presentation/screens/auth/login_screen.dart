import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Để bắt FirebaseException
import 'package:firebase_auth/firebase_auth.dart'; // Để bắt FirebaseAuthException
import '../../../services/auth_service.dart';
import 'register_screen.dart'; // Import RegisterScreen
import '../home/home_screen.dart'; // Đảm bảo đường dẫn đúng

class LoginScreen extends StatefulWidget {
  // static const routeName = '/login'; // Nếu dùng named routes

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      AppUser? user = await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null && mounted) { // Kiểm tra user không null và widget còn mounted
        // Đăng nhập thành công, ĐIỀU HƯỚNG ĐẾN HOMESCREEN
        Navigator.of(context).pushReplacement( // Dùng pushReplacement để không quay lại LoginScreen bằng nút back
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (mounted) { // Trường hợp user là null dù không có exception (ít xảy ra với email/pass)
        setState(() {
          _errorMessage = "Đăng nhập thất bại. Không nhận được thông tin người dùng.";
        });
      }

    } on FirebaseAuthException catch (e) {
      // ... (xử lý lỗi FirebaseAuthException như cũ) ...
      String message = "Đăng nhập thất bại. Vui lòng thử lại.";
      if (e.code == 'user-not-found') { /* ... */ }
      // ...
      if (mounted) {
        setState(() { _errorMessage = message; });
      }
    } catch (e) {
      // ... (xử lý lỗi chung như cũ) ...
      if (mounted) {
        setState(() { _errorMessage = "Đã xảy ra lỗi không xác định."; });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      AppUser? user = await authService.signInWithGoogle();

      if (user != null && mounted) {
        // Đăng nhập Google thành công, ĐIỀU HƯỚNG ĐẾN HOMESCREEN
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (mounted) {
        setState(() {
          _errorMessage = "Đăng nhập Google thất bại. Không nhận được thông tin người dùng.";
        });
      }
      // ... (xử lý lỗi như cũ) ...
    } on FirebaseAuthException catch (e) { /* ... */ }
    catch (e) { /* ... */ }
    finally { /* ... */ }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Đăng Nhập")), // Có thể bỏ AppBar cho màn hình login
      body: SafeArea( // Đảm bảo nội dung không bị che bởi notch hoặc thanh trạng thái
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0), // Tăng padding một chút
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Bạn có thể thêm Logo ở đây
                  // FlutterLogo(size: 80),
                  // SizedBox(height: 30),
                  Text(
                    'Chào Mừng Trở Lại!',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Đăng nhập để tiếp tục mua sắm',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true, // Thêm nền cho input field
                      fillColor: Colors.grey[100],
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty || !value.contains('@')) {
                        return 'Vui lòng nhập email hợp lệ.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu.';
                      }
                      // Bạn có thể bỏ kiểm tra độ dài ở đây nếu không muốn
                      // if (value.length < 6) {
                      //   return 'Mật khẩu phải có ít nhất 6 ký tự.';
                      // }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Align( // Nút quên mật khẩu
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Triển khai chức năng quên mật khẩu
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chức năng quên mật khẩu chưa được triển khai!')),
                        );
                      },
                      child: const Text('Quên mật khẩu?'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: _loginUser,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20),
                  Row( // Đường kẻ ngang và chữ "HOẶC"
                    children: <Widget>[
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("HOẶC", style: TextStyle(color: Colors.grey[600])),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _isLoading
                      ? const SizedBox.shrink()
                      : OutlinedButton.icon(
                    icon: Image.asset('assets/images/google_logo.png.webp', height: 20.0), // Thay bằng đường dẫn logo Google của bạn
                    label: const Text('Đăng nhập với Google'),
                    onPressed: _loginWithGoogle,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Chưa có tài khoản?"),
                      TextButton(
                        onPressed: _isLoading ? null : () { // Vô hiệu hóa nút khi đang loading
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: const Text('Đăng ký ngay'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}