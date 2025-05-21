import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Alias để tránh trùng tên User
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Model AppUser của bạn
class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  String? role;

  AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.role,
  });
}

class AuthService {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Chuyển fb_auth.User thành AppUser
  AppUser? _appUserFromFirebaseUser(fb_auth.User? firebaseUser) {
    // ... (code như đã cung cấp trước đó) ...
    if (firebaseUser == null) return null;
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
    );
  }

  // Stream lắng nghe trạng thái đăng nhập
  Stream<AppUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(_appUserFromFirebaseUser);
  }

  // Lấy user hiện tại
  AppUser? get currentUser {
    return _appUserFromFirebaseUser(_firebaseAuth.currentUser);
  }

  // Đăng ký bằng email/password
  Future<AppUser?> createUserWithEmailAndPassword(String email, String password, String displayName) async {
    // ... (code như đã cung cấp, bao gồm cả việc lưu user vào Firestore collection 'users' với role 'customer') ...
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      final firebaseUser = credential.user;
      if (firebaseUser != null) {
        await firebaseUser.updateDisplayName(displayName);
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'uid': firebaseUser.uid,
          'email': firebaseUser.email,
          'displayName': displayName,
          'photoUrl': firebaseUser.photoURL,
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
        });
        await firebaseUser.reload();
        return _appUserFromFirebaseUser(_firebaseAuth.currentUser);
      }
      return null;
    } on fb_auth.FirebaseAuthException {
      rethrow;
    }
  }

  // Đăng nhập bằng email/password
  Future<AppUser?> signInWithEmailAndPassword(String email, String password) async {
    // ... (code như đã cung cấp) ...
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return _appUserFromFirebaseUser(credential.user);
    } on fb_auth.FirebaseAuthException {
      rethrow;
    }
  }

  // Đăng nhập bằng Google
  Future<AppUser?> signInWithGoogle() async {
    // ... (code như đã cung cấp, bao gồm kiểm tra và lưu user vào Firestore nếu chưa có) ...
    try {
      final GoogleSignInAccount? googleUserAccount = await _googleSignIn.signIn();
      if (googleUserAccount == null) return null;
      final GoogleSignInAuthentication googleAuth = await googleUserAccount.authentication;
      final fb_auth.AuthCredential credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken,
      );
      final firebaseUser = (await _firebaseAuth.signInWithCredential(credential)).user;
      if (firebaseUser != null) {
        final userDocRef = _firestore.collection('users').doc(firebaseUser.uid);
        final docSnapshot = await userDocRef.get();
        if (!docSnapshot.exists) {
          await userDocRef.set({
            'uid': firebaseUser.uid, 'email': firebaseUser.email,
            'displayName': firebaseUser.displayName, 'photoUrl': firebaseUser.photoURL,
            'role': 'customer', 'createdAt': FieldValue.serverTimestamp(),
          });
        }
        return _appUserFromFirebaseUser(firebaseUser);
      }
      return null;
    } on fb_auth.FirebaseAuthException {
      rethrow;
    } catch (e) {
      print("Lỗi Google Sign In: $e");
      throw Exception("Lỗi đăng nhập Google.");
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    try {
      // Đăng xuất khỏi Google trước nếu người dùng đã đăng nhập bằng Google
      // Điều này quan trọng để lần đăng nhập Google tiếp theo sẽ hỏi chọn tài khoản
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
        print("Đã đăng xuất khỏi Google.");
      }

      // Sau đó đăng xuất khỏi Firebase Authentication
      await _firebaseAuth.signOut();
      print("Đã đăng xuất khỏi Firebase.");

      // Không cần trả về gì, AuthWrapper hoặc UserProvider sẽ tự động cập nhật
      // dựa trên sự thay đổi của _firebaseAuth.authStateChanges()
    } catch (e) {
      print("Lỗi khi đăng xuất: $e");
      // Bạn có thể ném lại lỗi nếu muốn UI xử lý
      // throw Exception("Không thể đăng xuất. Vui lòng thử lại.");
    }
  }

  Future<AppUser?> getAppUserWithRole(String uid) async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null || firebaseUser.uid != uid) {
      print("AuthService: getAppUserWithRole - No matching logged in user for UID: $uid");
      return _appUserFromFirebaseUser(firebaseUser); // Hoặc return null
    }

    final appUser = _appUserFromFirebaseUser(firebaseUser);
    if (appUser != null) {
      try {
        print("AuthService: Fetching Firestore document for user: $uid");
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>?;
          appUser.role = data?['role'] as String?;
          print("AuthService: Role for $uid is ${appUser.role}");
        } else {
          print("AuthService: Firestore document for user $uid NOT FOUND. Defaulting role.");
          appUser.role = 'customer'; // Hoặc null nếu bạn muốn xử lý khác
        }
      } catch (e) {
        print("AuthService: ERROR fetching role for $uid: $e");
        appUser.role = 'customer'; // Hoặc null
      }
    }
    return appUser;
  }
  // Lấy role của user
  Future<String?> getUserRole(String uid) async {
    // ... (code đọc từ Firestore collection 'users') ...
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        return data?['role'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}