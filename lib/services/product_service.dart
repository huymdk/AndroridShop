// import 'dart:io'; // Cho File khi upload ảnh
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// // import 'package:image_picker/image_picker.dart'; // Sẽ dùng khi làm chức năng admin
// import '../data/models/product_model.dart'; // Đảm bảo đường dẫn này đúng
//
// class ProductService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final String _productCollectionPath = 'products';
//
//   // Lấy tất cả sản phẩm
//   Stream<List<Product>> getProducts() {
//     return _firestore
//         .collection(_productCollectionPath)
//         .orderBy('name') // Sắp xếp theo tên gốc (phân biệt hoa thường)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs
//           .map((doc) => Product.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
//           .toList();
//     });
//   }
//
//   // Lấy sản phẩm theo Category ID
//   Stream<List<Product>> getProductsByCategory(String categoryId) {
//     if (categoryId.toLowerCase() == 'all' || categoryId.isEmpty) {
//       return getProducts();
//     }
//     return _firestore
//         .collection(_productCollectionPath)
//         .where('categoryId', isEqualTo: categoryId)
//         .orderBy('name')
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs
//           .map((doc) => Product.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
//           .toList();
//     });
//   }
//
//   // Lấy sản phẩm theo ID
//   Future<Product?> getProductById(String productId) async {
//     try {
//       final docSnapshot = await _firestore
//           .collection(_productCollectionPath)
//           .doc(productId)
//           .get();
//       if (docSnapshot.exists) {
//         return Product.fromFirestore(docSnapshot as DocumentSnapshot<Map<String, dynamic>>);
//       }
//       return null;
//     } catch (e) {
//       print("Lỗi khi lấy sản phẩm theo ID: $e");
//       return null;
//     }
//   }
//
//   // --- Hàm tìm kiếm sản phẩm ---
//   Stream<List<Product>> searchProducts(String query) {
//     if (query.trim().isEmpty) {
//       return Stream.value([]); // Trả về danh sách rỗng nếu query rỗng
//     }
//
//     String searchQuery = query.trim().toLowerCase(); // Chuẩn hóa query thành chữ thường
//
//     return _firestore
//         .collection(_productCollectionPath)
//     // Query trên trường 'name_lowercase'
//         .where('name_lowercase', isGreaterThanOrEqualTo: searchQuery)
//         .where('name_lowercase', isLessThanOrEqualTo: '$searchQuery\uf8ff')
//     // \uf8ff là một ký tự Unicode đặc biệt giúp query hoạt động như 'startsWith'
//     // hoặc tìm các chuỗi có tiền tố là searchQuery.
//         .limit(20) // Giới hạn số lượng kết quả trả về để tối ưu
//         .snapshots()
//         .map((snapshot) {
//       print("Search results count: ${snapshot.docs.length} for query: $searchQuery"); // Dòng debug
//       return snapshot.docs
//           .map((doc) {
//         // Thêm print để debug dữ liệu trả về từ Firestore
//         // print("Product doc data: ${doc.data()}");
//         return Product.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
//       })
//           .toList();
//     });
//   }
//
//
//   // --- Các hàm cho Admin ---
//
//   Future<String?> _uploadImageToStorage(File imageFile, String productId) async {
//     try {
//       String fileExtension = imageFile.path.split('.').last;
//       String fileName = 'product_image_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
//       Reference storageRef = _storage.ref().child('product_images/$productId/$fileName');
//       UploadTask uploadTask = storageRef.putFile(imageFile);
//       TaskSnapshot snapshot = await uploadTask;
//       return await snapshot.ref.getDownloadURL();
//     } catch (e) {
//       print("Lỗi upload ảnh lên Storage: $e");
//       return null;
//     }
//   }
//
//   Future<void> addProduct({
//     required String name,
//     required String description,
//     required double price,
//     required String categoryId,
//     required int stockQuantity,
//     List<File>? imageFiles,
//   }) async {
//     try {
//       DocumentReference productDocRef = _firestore.collection(_productCollectionPath).doc();
//       String productId = productDocRef.id;
//       List<String> imageUrls = [];
//
//       if (imageFiles != null && imageFiles.isNotEmpty) {
//         for (File imageFile in imageFiles) {
//           String? url = await _uploadImageToStorage(imageFile, productId);
//           if (url != null) {
//             imageUrls.add(url);
//           }
//         }
//       }
//
//       Product newProduct = Product(
//         id: productId,
//         name: name,
//         description: description,
//         price: price,
//         categoryId: categoryId,
//         stockQuantity: stockQuantity,
//         imageUrls: imageUrls,
//       );
//
//       // Chuẩn bị dữ liệu để lưu, bao gồm cả 'name_lowercase'
//       Map<String, dynamic> productDataToSave = newProduct.toFirestore();
//       productDataToSave['name_lowercase'] = name.trim().toLowerCase(); // Tự động tạo trường name_lowercase
//
//       await productDocRef.set(productDataToSave);
//       print("Sản phẩm đã được thêm với name_lowercase: ${name.trim().toLowerCase()}");
//     } catch (e) {
//       print("Lỗi khi thêm sản phẩm mới: $e");
//       throw Exception("Không thể thêm sản phẩm. Vui lòng thử lại.");
//     }
//   }
//
//   // (Admin) Cập nhật sản phẩm
//   Future<void> updateProduct(Product product, {List<File>? newImageFiles, List<String>? imagesToDeleteUrls}) async {
//     // TODO: Triển khai logic upload ảnh mới, xóa ảnh cũ (nếu có)
//     // ... (Phần xử lý ảnh tương tự như addProduct và thêm logic xóa ảnh cũ từ Storage)
//
//     try {
//       // Chuẩn bị dữ liệu để cập nhật, bao gồm cả 'name_lowercase'
//       Map<String, dynamic> productDataToUpdate = product.toFirestore();
//       productDataToUpdate['name_lowercase'] = product.name.trim().toLowerCase(); // Cập nhật trường name_lowercase
//       // productDataToUpdate['imageUrls'] = product.imageUrls; // Đảm bảo imageUrls được cập nhật sau khi xử lý ảnh
//
//       await _firestore
//           .collection(_productCollectionPath)
//           .doc(product.id)
//           .update(productDataToUpdate);
//       print("Sản phẩm đã được cập nhật với name_lowercase: ${product.name.trim().toLowerCase()}");
//     } catch (e) {
//       print("Lỗi khi cập nhật sản phẩm: $e");
//       throw Exception("Không thể cập nhật sản phẩm. Vui lòng thử lại.");
//     }
//   }
//
//   // (Admin) Xóa sản phẩm
//   Future<void> deleteProduct(String productId) async {
//     try {
//       // TODO: Lấy thông tin sản phẩm để lấy danh sách imageUrls
//       // Product? productToDelete = await getProductById(productId);
//       // if (productToDelete != null && productToDelete.imageUrls.isNotEmpty) {
//       //   for (String imageUrl in productToDelete.imageUrls) {
//       //     try {
//       //       Reference storageRef = _storage.refFromURL(imageUrl);
//       //       await storageRef.delete();
//       //     } catch (storageError) {
//       //       print("Lỗi xóa ảnh $imageUrl từ Storage: $storageError");
//       //       // Có thể bỏ qua lỗi này và tiếp tục xóa document
//       //     }
//       //   }
//       // }
//
//       await _firestore.collection(_productCollectionPath).doc(productId).delete();
//       print("Sản phẩm với ID $productId đã được xóa.");
//     } catch (e) {
//       print("Lỗi khi xóa sản phẩm: $e");
//       throw Exception("Không thể xóa sản phẩm.");
//     }
//   }
// }


// import 'dart:io'; // Không cần File nữa
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart'; // Không dùng Storage nữa
import '../data/models/product_model.dart'; // Đảm bảo đường dẫn đúng

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instance; // Không dùng Storage
  final String _productCollectionPath = 'products';

  // ... (getProducts, getProductsByCategory, getProductById, searchProducts giữ nguyên) ...
  Stream<List<Product>> getProducts() { /* ... giữ nguyên ... */ return _firestore.collection(_productCollectionPath).orderBy('name').snapshots().map((snapshot) => snapshot.docs.map((doc) => Product.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList()); }
  Stream<List<Product>> getProductsByCategory(String categoryId) { if (categoryId.toLowerCase() == 'all' || categoryId.isEmpty) { return getProducts(); } return _firestore.collection(_productCollectionPath).where('categoryId', isEqualTo: categoryId).orderBy('name').snapshots().map((snapshot) => snapshot.docs.map((doc) => Product.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList()); }
  Future<Product?> getProductById(String productId) async { try { final docSnapshot = await _firestore.collection(_productCollectionPath).doc(productId).get(); if (docSnapshot.exists) { return Product.fromFirestore(docSnapshot as DocumentSnapshot<Map<String, dynamic>>); } return null; } catch (e) { print("Lỗi khi lấy sản phẩm theo ID: $e"); return null; } }
  Stream<List<Product>> searchProducts(String query) { if (query.trim().isEmpty) return Stream.value([]); String searchQuery = query.trim().toLowerCase(); return _firestore.collection(_productCollectionPath).where('name_lowercase', isGreaterThanOrEqualTo: searchQuery).where('name_lowercase', isLessThanOrEqualTo: '$searchQuery\uf8ff').limit(20).snapshots().map((snapshot) => snapshot.docs.map((doc) => Product.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList());}


  // --- Các hàm cho Admin (KHÔNG UPLOAD ẢNH TỪ APP) ---

  Future<String> addProduct({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required int stockQuantity,
    required List<String> imageUrls, // Nhận trực tiếp List<String> URL
  }) async {
    try {
      DocumentReference productDocRef = _firestore.collection(_productCollectionPath).doc();
      String productId = productDocRef.id;

      Product newProduct = Product(
        id: productId,
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        stockQuantity: stockQuantity,
        imageUrls: imageUrls, // Sử dụng trực tiếp URL đã nhập
      );

      Map<String, dynamic> productData = newProduct.toFirestore();
      productData['name_lowercase'] = name.trim().toLowerCase();
      productData['createdAt'] = FieldValue.serverTimestamp();
      productData['updatedAt'] = FieldValue.serverTimestamp();

      await productDocRef.set(productData);
      return productId;
    } catch (e) {
      print("Lỗi khi thêm sản phẩm mới: $e");
      throw Exception("Không thể thêm sản phẩm. Vui lòng thử lại.");
    }
  }

  Future<void> updateProduct({
    required Product existingProduct, // Product object cũ
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required int stockQuantity,
    required List<String> imageUrls, // Danh sách URL mới/đã cập nhật
  }) async {
    try {
      Map<String, dynamic> updatedData = {
        'name': name,
        'description': description,
        'price': price,
        'categoryId': categoryId,
        'stockQuantity': stockQuantity,
        'imageUrls': imageUrls, // Sử dụng trực tiếp URL đã nhập/sửa
        'name_lowercase': name.trim().toLowerCase(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_productCollectionPath)
          .doc(existingProduct.id) // Sử dụng ID của product cũ
          .update(updatedData);
    } catch (e) {
      print("Lỗi khi cập nhật sản phẩm: $e");
      throw Exception("Không thể cập nhật sản phẩm. Vui lòng thử lại.");
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      // Không cần xóa ảnh từ Storage nữa vì chúng ta không quản lý việc upload từ app
      await _firestore.collection(_productCollectionPath).doc(productId).delete();
      print("Sản phẩm với ID $productId đã được xóa.");
    } catch (e) {
      print("Lỗi khi xóa sản phẩm: $e");
      throw Exception("Không thể xóa sản phẩm.");
    }
  }
}