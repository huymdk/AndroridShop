import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String id; // ID của document trên Firestore
  final String imageUrl;
  final String? linkUrl; // URL sẽ mở khi nhấn vào banner (tùy chọn)
  final int order;      // Thứ tự hiển thị
  final bool isActive;  // Banner có đang được kích hoạt không

  BannerModel({
    required this.id,
    required this.imageUrl,
    this.linkUrl,
    required this.order,
    required this.isActive,
  });

  factory BannerModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Missing data for BannerModel from Firestore document: ${doc.id}');
    }
    return BannerModel(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      linkUrl: data['linkUrl'] as String?,
      order: (data['order'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'order': order,
      'isActive': isActive,
      // Không cần lưu 'id' vì nó là ID của document
    };
  }
}