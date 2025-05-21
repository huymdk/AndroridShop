import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Cho Timestamp

// Đảm bảo các đường dẫn import này chính xác
import '../../providers_or_blocs/cart_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/order_service.dart';
import '../../../data/models/address_model.dart';
import '../../../data/models/order_model.dart';
import '../home/home_screen.dart'; // Import HomeScreen để điều hướng về

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers cho các trường thông tin
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLineController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _wardController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedPaymentMethod = 'COD'; // Mặc định là COD
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressLineController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // =======================================================================
  // PHẦN QUAN TRỌNG CẦN THAY ĐỔI VÀ HOÀN THIỆN LÀ HÀM _placeOrder NÀY
  // =======================================================================
  Future<void> _placeOrder() async {
    // 1. Kiểm tra tính hợp lệ của Form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin giao hàng.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }
    // Form hợp lệ, lưu lại các giá trị (không bắt buộc nếu bạn lấy trực tiếp từ controller)
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    // 2. Lấy các Provider và Service cần thiết
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final orderService = Provider.of<OrderService>(context, listen: false);

    // 3. Kiểm tra người dùng đã đăng nhập và giỏ hàng có sản phẩm
    final currentUser = authService.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để đặt hàng.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    if (cartProvider.items.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giỏ hàng của bạn đang trống. Không thể đặt hàng.'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    // 4. Tạo đối tượng AddressModel và OrderModel
    try {
      final shippingAddress = AddressModel(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        addressLine: _addressLineController.text.trim(),
        city: _cityController.text.trim(),
        district: _districtController.text.trim(),
        ward: _wardController.text.trim(),
        note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      );

      final order = OrderModel(
        // id: null, // OrderService sẽ xử lý việc gán ID nếu cần thiết trong model
        userId: currentUser.uid,
        items: cartProvider.items.values.toList(), // Truyền danh sách CartItemModel
        totalAmount: cartProvider.totalAmount,
        shippingAddress: shippingAddress,
        paymentMethod: _selectedPaymentMethod,
        orderDate: Timestamp.now(), // Thời điểm tạo đơn hàng
        status: 'pending', // Trạng thái ban đầu của đơn hàng
      );

      // 5. Gọi hàm placeOrder từ OrderService
      String orderId = await orderService.placeOrder(order);

      // 6. Xử lý khi đặt hàng thành công
      cartProvider.clearCart(); // Xóa giỏ hàng

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đặt hàng thành công! Mã đơn hàng: $orderId'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        // Điều hướng về trang chủ hoặc trang chi tiết đơn hàng / cảm ơn
        // Navigator.of(context).popUntil((route) => route.isFirst); // Quay về màn hình đầu tiên (thường là AuthWrapper rồi đến Home)
        // Hoặc nếu bạn muốn đảm bảo về HomeScreen:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false, // Xóa tất cả các route trước đó
        );
      }
    } catch (error) {
      // 7. Xử lý khi đặt hàng thất bại
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đặt hàng thất bại: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  // =======================================================================
  // KẾT THÚC PHẦN CẦN THAY ĐỔI _placeOrder
  // =======================================================================


  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context); // Dùng để hiển thị tóm tắt đơn hàng
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác Nhận Đơn Hàng'),
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phần thông tin giao hàng
              Text('1. Thông tin người nhận', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextFormField(controller: _nameController, label: 'Họ và tên', icon: Icons.person_outline_rounded),
              _buildTextFormField(controller: _phoneController, label: 'Số điện thoại', icon: Icons.phone_iphone_rounded, keyboardType: TextInputType.phone),
              _buildTextFormField(controller: _addressLineController, label: 'Địa chỉ (Số nhà, tên đường, tòa nhà)', icon: Icons.location_on_outlined),
              _buildTextFormField(controller: _wardController, label: 'Phường/Xã', icon: Icons.my_location_rounded),
              _buildTextFormField(controller: _districtController, label: 'Quận/Huyện', icon: Icons.location_city_rounded),
              _buildTextFormField(controller: _cityController, label: 'Tỉnh/Thành phố', icon: Icons.map_rounded),
              _buildTextFormField(controller: _noteController, label: 'Ghi chú thêm (tùy chọn)', icon: Icons.notes_rounded, isOptional: true, maxLines: 3, textInputAction: TextInputAction.done),
              const SizedBox(height: 24),

              // Phần phương thức thanh toán
              Text('2. Phương thức thanh toán', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: RadioListTile<String>(
                  title: const Text('Thanh toán khi nhận hàng (COD)'),
                  subtitle: const Text('Trả tiền mặt khi nhận được hàng.'),
                  value: 'COD',
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    }
                  },
                  secondary: Icon(Icons.delivery_dining_outlined, color: theme.colorScheme.primary),
                  activeColor: theme.colorScheme.primary,
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              ),
              const SizedBox(height: 24),

              // Phần tóm tắt đơn hàng
              Text('3. Tóm tắt đơn hàng', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildOrderSummaryRow('Tạm tính:', '${cart.totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ'),
                      _buildOrderSummaryRow('Phí vận chuyển:', 'Miễn phí'), // Hoặc tính toán phí
                      const Divider(height: 20, thickness: 1),
                      _buildOrderSummaryRow(
                        'Tổng cộng:',
                        '${cart.totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: (cart.items.isEmpty || _isLoading) && mounted
          ? null
          : Padding(
        padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, MediaQuery.of(context).padding.bottom + 8.0),
        child: ElevatedButton(
          onPressed: _placeOrder, // Gọi hàm _placeOrder khi nhấn nút
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('ĐẶT HÀNG NGAY'),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isOptional = false,
    int maxLines = 1,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        textInputAction: textInputAction,
        validator: validator ?? (value) {
          if (!isOptional && (value == null || value.trim().isEmpty)) {
            return 'Vui lòng nhập $label.';
          }
          if (label == 'Số điện thoại' && !isOptional) {
            if (value != null && (value.length < 9 || value.length > 11 || !RegExp(r'^[0-9]+$').hasMatch(value))) {
              return 'Số điện thoại không hợp lệ.';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildOrderSummaryRow(String label, String value, {bool isTotal = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 17)
                : theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
          ),
          Text(
            value,
            style: isTotal
                ? theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)
                : theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}