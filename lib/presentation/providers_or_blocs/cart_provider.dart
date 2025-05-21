// lib/presentation/providers_or_blocs/cart_provider.dart
import 'package:flutter/foundation.dart'; // Cho ChangeNotifier
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart'; // Cần ProductModel để lấy thông tin khi thêm

class CartProvider with ChangeNotifier {
  final Map<String, CartItemModel> _items = {};

  Map<String, CartItemModel> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length; // Số loại sản phẩm khác nhau
  }
  int get totalItemsInCart { // Tổng số lượng của tất cả sản phẩm (ví dụ: 2 áo + 3 quần = 5 items)
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  int get totalQuantity {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(Product product, {int quantity = 1}) {
    if (_items.containsKey(product.id)) {
      // Nếu sản phẩm đã có trong giỏ, tăng số lượng
      _items.update(
        product.id,
            (existingCartItem) => CartItemModel(
          productId: existingCartItem.productId,
          name: existingCartItem.name,
          imageUrl: existingCartItem.imageUrl,
          price: existingCartItem.price, // Giữ nguyên giá tại thời điểm thêm lần đầu
          quantity: existingCartItem.quantity + quantity,
        ),
      );
    } else {
      // Nếu sản phẩm chưa có, thêm mới vào giỏ
      _items.putIfAbsent(
        product.id,
            () => CartItemModel(
          productId: product.id,
          name: product.name,
          imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '', // Lấy ảnh đầu tiên
          price: product.price,
          quantity: quantity,
        ),
      );
    }
    notifyListeners(); // Thông báo cho các widget đang lắng nghe để cập nhật UI
  }

  void updateQuantity(String productId, int newQuantity) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (newQuantity <= 0) {
      // Nếu số lượng mới <= 0, xóa sản phẩm khỏi giỏ
      removeItem(productId);
    } else {
      _items.update(
        productId,
            (existingCartItem) => CartItemModel(
          productId: existingCartItem.productId,
          name: existingCartItem.name,
          imageUrl: existingCartItem.imageUrl,
          price: existingCartItem.price,
          quantity: newQuantity,
        ),
      );
      notifyListeners();
    }
  }

  void incrementQuantity(String productId) {
    if (_items.containsKey(productId)) {
      updateQuantity(productId, _items[productId]!.quantity + 1);
    }
  }

  void decrementQuantity(String productId) {
    if (_items.containsKey(productId)) {
      updateQuantity(productId, _items[productId]!.quantity - 1);
    }
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}