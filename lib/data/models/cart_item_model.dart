// lib/data/models/cart_item_model.dart
class CartItemModel {
  final String productId;
  final String name;
  final String imageUrl; // URL của ảnh đầu tiên để hiển thị
  final double price;    // Giá tại thời điểm thêm vào giỏ
  int quantity;

  CartItemModel({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

// Có thể thêm các hàm toMap, fromMap nếu bạn muốn lưu giỏ hàng lên Firestore
}