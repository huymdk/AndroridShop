import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> imageUrls; // Danh sách các URL hình ảnh
  final String categoryId;      // ID của danh mục sản phẩm
  final int stockQuantity;      // Số lượng tồn kho
  // Bạn có thể thêm các trường khác như: ratingAvg, brand, tags, etc.

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrls,
    required this.categoryId,
    required this.stockQuantity,
  });

  // Factory constructor để tạo Product từ DocumentSnapshot của Firestore
  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception("Dữ liệu sản phẩm không hợp lệ!");
    }
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      // Đảm bảo imageUrls là List<String>, nếu không có thì là list rỗng
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      categoryId: data['categoryId'] ?? '',
      stockQuantity: (data['stockQuantity'] ?? 0).toInt(),
    );
  }

  // Method để chuyển Product object thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrls': imageUrls,
      'categoryId': categoryId,
      'stockQuantity': stockQuantity,
      // Không cần lưu 'id' vào document data vì nó đã là ID của document
    };
  }
}