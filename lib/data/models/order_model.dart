// Trong lib/data/models/order_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart'; // Giả sử CartItemModel cũng có fromMap
import 'address_model.dart';   // Giả sử AddressModel cũng có fromMap

class OrderModel {
  final String? id;
  final String userId;
  final List<CartItemModel> items;
  final double totalAmount;
  final AddressModel shippingAddress;
  final String paymentMethod;
  final Timestamp orderDate;
  String status;

  OrderModel({
    this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.orderDate,
    required this.status,
  });

  // Factory constructor để tạo OrderModel từ DocumentSnapshot
  factory OrderModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception("Dữ liệu đơn hàng không hợp lệ!");
    }

    // Chuyển đổi List<dynamic> (từ Firestore) thành List<CartItemModel>
    List<CartItemModel> orderItems = [];
    if (data['items'] != null && data['items'] is List) {
      orderItems = (data['items'] as List<dynamic>).map((itemData) {
        // Giả sử CartItemModel có fromMap hoặc bạn tự parse các trường
        return CartItemModel(
          productId: itemData['productId'] ?? '',
          name: itemData['name'] ?? '',
          imageUrl: itemData['imageUrl'] ?? '',
          price: (itemData['price'] as num?)?.toDouble() ?? 0.0,
          quantity: (itemData['quantity'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    }

    // Chuyển đổi Map (từ Firestore) thành AddressModel
    AddressModel shippingAddr;
    if (data['shippingAddress'] != null && data['shippingAddress'] is Map) {
      final addrData = data['shippingAddress'] as Map<String, dynamic>;
      shippingAddr = AddressModel(
        name: addrData['name'] ?? '',
        phone: addrData['phone'] ?? '',
        addressLine: addrData['addressLine'] ?? '',
        city: addrData['city'] ?? '',
        district: addrData['district'] ?? '',
        ward: addrData['ward'] ?? '',
        note: addrData['note'] as String?,
      );
    } else {
      // Cung cấp giá trị mặc định hoặc ném lỗi nếu địa chỉ là bắt buộc
      shippingAddr = AddressModel(name: '', phone: '', addressLine: '', city: '', district: '', ward: '');
    }

    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      items: orderItems,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      shippingAddress: shippingAddr,
      paymentMethod: data['paymentMethod'] ?? 'N/A',
      orderDate: data['orderDate'] as Timestamp? ?? Timestamp.now(), // Cung cấp giá trị mặc định
      status: data['status'] ?? 'unknown',
    );
  }

  // Hàm toFirestore của bạn đã có
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((item) => {
        'productId': item.productId, 'name': item.name,
        'imageUrl': item.imageUrl, 'price': item.price,
        'quantity': item.quantity,
      }).toList(),
      'totalAmount': totalAmount,
      'shippingAddress': shippingAddress.toMap(), // Giả sử AddressModel có toMap()
      'paymentMethod': paymentMethod,
      'orderDate': orderDate,
      'status': status,
    };
  }
}