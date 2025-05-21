import 'package:cloud_firestore/cloud_firestore.dart';
// Đảm bảo các đường dẫn import này chính xác với cấu trúc dự án của bạn
import '../data/models/order_model.dart';
import '../data/models/cart_item_model.dart'; // Cần cho hàm placeOrder và OrderModel.fromFirestore
import '../data/models/address_model.dart';   // Cần cho OrderModel.fromFirestore

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _ordersCollectionPath = 'orders';
  final String _productsCollectionPath = 'products'; // Cần để cập nhật tồn kho

  // Đặt hàng mới
  Future<String> placeOrder(OrderModel order) async {
    try {
      String orderId = ''; // Sẽ được gán ID của document mới
      await _firestore.runTransaction((transaction) async {
        // --- Bước 1: ĐỌC TẤT CẢ DỮ LIỆU CẦN THIẾT TRƯỚC (Kiểm tra tồn kho) ---
        Map<String, int> currentStocks = {}; // Lưu trữ tồn kho hiện tại đã đọc

        for (var item in order.items) {
          DocumentReference productRef = _firestore.collection(_productsCollectionPath).doc(item.productId);
          DocumentSnapshot productSnap = await transaction.get(productRef); // THAO TÁC ĐỌC

          if (!productSnap.exists) {
            throw Exception("Sản phẩm '${item.name}' (ID: ${item.productId}) không tồn tại!");
          }
          final productData = productSnap.data() as Map<String, dynamic>;
          currentStocks[item.productId] = (productData['stockQuantity'] ?? 0).toInt();

          if (currentStocks[item.productId]! < item.quantity) {
            throw Exception("Không đủ số lượng cho sản phẩm '${item.name}'. Chỉ còn ${currentStocks[item.productId]} sản phẩm.");
          }
        }

        // --- Bước 2: THỰC HIỆN TẤT CẢ CÁC THAO TÁC GHI ---

        // 2.1. Tạo document đơn hàng mới (WRITE)
        DocumentReference orderRef = _firestore.collection(_ordersCollectionPath).doc(); // Tự tạo ID
        orderId = orderRef.id; // Lấy ID vừa được tạo

        final orderToSave = OrderModel(
          id: orderId, // Gán ID vào đối tượng order nếu model của bạn có trường này
          userId: order.userId,
          items: order.items,
          totalAmount: order.totalAmount,
          shippingAddress: order.shippingAddress,
          paymentMethod: order.paymentMethod,
          orderDate: order.orderDate, // Nên được gán Timestamp.now() khi tạo order ở client
          status: order.status,
        );
        transaction.set(orderRef, orderToSave.toFirestore());

        // 2.2. Cập nhật số lượng tồn kho của sản phẩm (WRITES)
        for (var item in order.items) {
          DocumentReference productRef = _firestore.collection(_productsCollectionPath).doc(item.productId);
          int newStock = currentStocks[item.productId]! - item.quantity;
          transaction.update(productRef, {'stockQuantity': newStock}); // THAO TÁC GHI
        }
      });
      print("Đơn hàng đã được đặt thành công với ID: $orderId");
      return orderId;
    } catch (e) {
      print("Lỗi nghiêm trọng khi đặt hàng trong transaction: $e");
      throw e;
    }
  }

  // (Admin) Lấy tất cả đơn hàng, sắp xếp theo ngày mới nhất
  Stream<List<OrderModel>> getAllOrders() {
    return _firestore
        .collection(_ordersCollectionPath)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) {
          return OrderModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
        }).toList();
      } catch (e) {
        print("Lỗi khi parse danh sách đơn hàng (getAllOrders): $e");
        return [];
      }
    });
  }

  // (User) Lấy lịch sử đơn hàng của một người dùng cụ thể
  Stream<List<OrderModel>> getUserOrders(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }
    return _firestore
        .collection(_ordersCollectionPath)
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) {
          return OrderModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
        }).toList();
      } catch (e) {
        print("Lỗi khi parse danh sách đơn hàng của user (getUserOrders): $e");
        return [];
      }
    });
  }

  // (Admin) Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    if (orderId.isEmpty || newStatus.isEmpty) {
      print("Order ID hoặc New Status không được rỗng khi cập nhật.");
      throw ArgumentError("Order ID hoặc New Status không hợp lệ.");
    }
    try {
      await _firestore
          .collection(_ordersCollectionPath)
          .doc(orderId)
          .update({'status': newStatus});
      print('Đã cập nhật trạng thái đơn hàng $orderId thành $newStatus');
    } catch (e) {
      print("Lỗi khi cập nhật trạng thái đơn hàng: $e");
      throw Exception("Không thể cập nhật trạng thái đơn hàng. Vui lòng thử lại.");
    }
  }

  // (Tùy chọn, Admin hoặc User) Lấy chi tiết một đơn hàng theo ID
  Future<OrderModel?> getOrderById(String orderId) async {
    if (orderId.isEmpty) return null;
    try {
      final docSnapshot = await _firestore.collection(_ordersCollectionPath).doc(orderId).get();
      if (docSnapshot.exists) {
        return OrderModel.fromFirestore(docSnapshot as DocumentSnapshot<Map<String, dynamic>>);
      }
      return null;
    } catch (e) {
      print("Lỗi khi lấy chi tiết đơn hàng theo ID: $e");
      return null;
    }
  }
}