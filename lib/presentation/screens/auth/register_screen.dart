import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Để bắt FirebaseAuthException
import '../../../services/auth_service.dart'; // Import AuthService của bạn
// Import LoginScreen để có thể quay lại
// import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  // static const routeName = '/register'; // Nếu dùng named routes

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return; // Nếu form không hợp lệ, không làm gì cả
    }

    // Kiểm tra mật khẩu và xác nhận mật khẩu có khớp không
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = "Mật khẩu xác nhận không khớp.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _displayNameController.text.trim(),
      );
      // Nếu đăng ký thành công, AuthWrapper sẽ tự động điều hướng
      // đến HomeScreen (vì authStateChanges sẽ thay đổi).
      // Nếu bạn muốn hiển thị thông báo thành công hoặc điều hướng cụ thể ở đây,
      // bạn có thể làm:
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Đăng ký thành công! Vui lòng đăng nhập.')),
      //   );
      //   Navigator.of(context).pop(); // Quay lại màn hình trước đó (ví dụ: LoginScreen)
      // }
    } on FirebaseAuthException catch (e) { // Bắt lỗi cụ thể từ Firebase Auth
      setState(() {
        _errorMessage = e.message ?? "Đăng ký thất bại. Vui lòng thử lại.";
        // Bạn có thể xử lý các mã lỗi cụ thể của Firebase ở đây, ví dụ:
        // if (e.code == 'weak-password') {
        //   _errorMessage = 'Mật khẩu quá yếu.';
        // } else if (e.code == 'email-already-in-use') {
        //   _errorMessage = 'Địa chỉ email này đã được sử dụng.';
        // }
      });
    } catch (e) { // Bắt các lỗi chung khác
      setState(() {
        _errorMessage = "Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đăng Ký Tài Khoản"),
        // Tự động có nút back nếu được push từ màn hình khác
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch, // Cho các nút rộng ra
              children: <Widget>[
                Text(
                  'Tạo Tài Khoản Mới',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Tên hiển thị
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên hiển thị',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên hiển thị của bạn.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty || !value.contains('@')) {
                      return 'Vui lòng nhập địa chỉ email hợp lệ.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Mật khẩu
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu.';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Xác nhận mật khẩu
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Xác nhận mật khẩu',
                    prefixIcon: Icon(Icons.lock_reset_outlined),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu.';
                    }
                    if (value != _passwordController.text) {
                      return 'Mật khẩu xác nhận không khớp.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Nút Đăng Ký
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _registerUser,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    // minimumSize: const Size(double.infinity, 50), // Nếu muốn nút rộng hết
                  ),
                  child: const Text('Đăng Ký'),
                ),
                const SizedBox(height: 20),

                // Nút quay lại Đăng nhập
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Đã có tài khoản?"),
                    TextButton(
                      onPressed: () {
                        // Nếu RegisterScreen được push từ LoginScreen, pop() sẽ quay lại
                        if (Navigator.canPop(context)) {
                          Navigator.of(context).pop();
                        } else {
                          // Nếu không, điều hướng trực tiếp (cần đảm bảo LoginScreen có route)
                          // Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
                        }
                      },
                      child: const Text('Đăng nhập ngay'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}