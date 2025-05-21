// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../data/models/banner_model.dart'; // Đảm bảo đường dẫn đúng
//
// class BannerService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final String _bannersCollectionPath = 'banners';
//
//   // Lấy tất cả banner, sắp xếp theo thứ tự, chỉ lấy banner active cho client
//   Stream<List<BannerModel>> getActiveBanners() {
//     return _firestore
//         .collection(_bannersCollectionPath)
//         .where('isActive', isEqualTo: true)
//         .orderBy('order') // Sắp xếp theo trường 'order'
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//         .map((doc) => BannerModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
//         .toList());
//   }
//
//   // (Admin) Lấy tất cả banner (cả active và inactive) để quản lý
//   Stream<List<BannerModel>> getAllBannersForAdmin() {
//     return _firestore
//         .collection(_bannersCollectionPath)
//         .orderBy('order')
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//         .map((doc) => BannerModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
//         .toList());
//   }
//
//   // (Admin) Thêm banner mới
//   Future<void> addBanner(BannerModel banner) async {
//     // Không cần truyền ID vào đây, Firestore sẽ tự tạo
//     // nhưng hàm toFirestore của BannerModel có thể không cần trường id
//     Map<String, dynamic> dataToSave = {
//       'imageUrl': banner.imageUrl,
//       'linkUrl': banner.linkUrl,
//       'order': banner.order,
//       'isActive': banner.isActive,
//     };
//     await _firestore.collection(_bannersCollectionPath).add(dataToSave);
//   }
//
//   // (Admin) Cập nhật banner
//   Future<void> updateBanner(BannerModel banner) async {
//     await _firestore
//         .collection(_bannersCollectionPath)
//         .doc(banner.id)
//         .update(banner.toFirestore()); // toFirestore không nên chứa id
//   }
//
//   // (Admin) Xóa banner
//   Future<void> deleteBanner(String bannerId) async {
//     // TODO: Nếu imageUrl là từ Firebase Storage, bạn cũng nên xóa file ảnh trên Storage ở đây
//     await _firestore.collection(_bannersCollectionPath).doc(bannerId).delete();
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/banner_model.dart'; // Đảm bảo đường dẫn đúng

class BannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _bannersCollectionPath = 'banners';

  // ... (getActiveBanners, getAllBannersForAdmin giữ nguyên) ...
  Stream<List<BannerModel>> getActiveBanners() { /* ... giữ nguyên ... */ return _firestore.collection(_bannersCollectionPath).where('isActive', isEqualTo: true).orderBy('order').snapshots().map((snapshot) => snapshot.docs.map((doc) => BannerModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList());}
  Stream<List<BannerModel>> getAllBannersForAdmin() { /* ... giữ nguyên ... */ return _firestore.collection(_bannersCollectionPath).orderBy('order').snapshots().map((snapshot) => snapshot.docs.map((doc) => BannerModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList());}


  Future<void> addBanner({ // Nhận trực tiếp các thuộc tính
    required String imageUrl,
    String? linkUrl,
    required int order,
    required bool isActive,
  }) async {
    try {
      // Tạo document mới với ID tự động
      await _firestore.collection(_bannersCollectionPath).add({
        'imageUrl': imageUrl,
        'linkUrl': linkUrl,
        'order': order,
        'isActive': isActive,
        'createdAt': FieldValue.serverTimestamp(), // Thêm thời gian tạo
      });
    } catch (e) {
      print("Lỗi khi thêm banner mới: $e");
      throw Exception("Không thể thêm banner.");
    }
  }

  Future<void> updateBanner({ // Nhận trực tiếp các thuộc tính và bannerId
    required String bannerId,
    required String imageUrl,
    String? linkUrl,
    required int order,
    required bool isActive,
  }) async {
    try {
      await _firestore
          .collection(_bannersCollectionPath)
          .doc(bannerId)
          .update({
        'imageUrl': imageUrl,
        'linkUrl': linkUrl,
        'order': order,
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(), // Thêm thời gian cập nhật
      });
    } catch (e) {
      print("Lỗi khi cập nhật banner: $e");
      throw Exception("Không thể cập nhật banner.");
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    try {
      // Không cần xóa ảnh từ Storage
      await _firestore.collection(_bannersCollectionPath).doc(bannerId).delete();
    } catch (e) {
      print("Lỗi khi xóa banner: $e");
      throw Exception("Không thể xóa banner.");
    }
  }
}