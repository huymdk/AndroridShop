import 'package:flutter/foundation.dart';
import '../../services/auth_service.dart'; // Đảm bảo đường dẫn đúng đến AuthService và AppUser model

class UserProvider with ChangeNotifier {
  final AuthService _authService;
  AppUser? _appUserWithRole; // Thông tin user hiện tại, bao gồm cả role
  bool _isLoading = true;    // Bắt đầu với isLoading = true để hiển thị SplashScreen ban đầu

  UserProvider(this._authService) {
    print("UserProvider: Initialized. Listening to authStateChanges and initializing user.");
    // Ngay khi UserProvider được tạo, lắng nghe authStateChanges
    _authService.authStateChanges.listen(_onAuthStateChangedFromStream);
    // Đồng thời, kiểm tra và xử lý trạng thái người dùng hiện tại ngay lập tức
    _initializeUser();
  }

  // Getters
  AppUser? get appUserWithRole => _appUserWithRole;
  bool get isLoggedIn => _appUserWithRole != null;
  bool get isAdmin => _appUserWithRole?.role == 'admin'; // Case-sensitive, đảm bảo 'admin' là chữ thường
  bool get isLoading => _isLoading;

  // Hàm riêng để khởi tạo hoặc kiểm tra user ban đầu
  Future<void> _initializeUser() async {
    print("UserProvider: _initializeUser called.");
    // Lấy AppUser cơ bản (chưa có role) từ AuthService
    final AppUser? initialBasicUser = _authService.currentUser;
    // Gọi hàm xử lý chính, isInitialization có thể không cần thiết nếu logic _onAuthStateChanged đủ mạnh
    await _processUserAuthChange(initialBasicUser, fromInit: true);
  }

  // Hàm được gọi bởi stream authStateChanges
  void _onAuthStateChangedFromStream(AppUser? basicAppUser) {
    print("UserProvider: AuthState changed from stream. BasicUser UID: ${basicAppUser?.uid}");
    // Gọi hàm xử lý chính
    _processUserAuthChange(basicAppUser);
  }

  // Hàm xử lý chính khi có sự thay đổi trạng thái đăng nhập hoặc khi khởi tạo
  Future<void> _processUserAuthChange(AppUser? basicAppUser, {bool fromInit = false}) async {
    print("UserProvider: _processUserAuthChange - START. BasicUser UID: ${basicAppUser?.uid}. Current _isLoading: $_isLoading. From init: $fromInit");

    // Chỉ set isLoading = true khi bắt đầu một quá trình fetch mới hoặc thay đổi user
    if (basicAppUser != null && (_appUserWithRole?.uid != basicAppUser.uid || _appUserWithRole?.role == null)) {
      // Nếu có user mới, hoặc user cũ nhưng chưa có role, hoặc user thay đổi
      _setLoading(true);
    } else if (basicAppUser == null && _appUserWithRole != null) {
      // Nếu đang từ có user sang không có user (đăng xuất)
      _setLoading(true); // Vẫn set loading để hiển thị SplashScreen trong AuthWrapper trước khi về Login
    } else if (fromInit && basicAppUser == null) {
      // Nếu là lần khởi tạo và không có user, thì không cần loading nữa
      _setLoading(false);
    }
    // Nếu không có thay đổi gì đáng kể (ví dụ: basicAppUser và _appUserWithRole cùng là null) thì không cần set loading.

    if (basicAppUser != null) {
      // Nếu user đăng nhập (có basicAppUser từ Firebase Auth)
      try {
        _appUserWithRole = await _authService.getAppUserWithRole(basicAppUser.uid);
        print("UserProvider: Fetched user with role: ${_appUserWithRole?.role}. UID: ${_appUserWithRole?.uid}");
        if (_appUserWithRole == null) {
          print("UserProvider: getAppUserWithRole returned null. Forcing logout state.");
          // Nếu không lấy được thông tin user từ Firestore (dù Auth có user), coi như lỗi và đăng xuất
          // Hoặc bạn có thể giữ basicAppUser và không có role tùy theo yêu cầu
          _appUserWithRole = null; // Đảm bảo là null
        }
      } catch (e) {
        print("UserProvider - ERROR fetching role in _processUserAuthChange: $e");
        _appUserWithRole = basicAppUser; // Fallback, role sẽ là null
        _appUserWithRole?.role = null;
      }
    } else {
      // Nếu user đăng xuất (basicAppUser là null)
      _appUserWithRole = null;
      print("UserProvider: User is null (logged out), _appUserWithRole set to null.");
    }

    _setLoading(false); // Luôn đặt isLoading thành false sau khi hoàn tất xử lý
    print("UserProvider: _processUserAuthChange - END. isLoggedIn: $isLoggedIn, isLoading: $_isLoading, isAdmin: $isAdmin");
    // notifyListeners() đã được gọi trong _setLoading nếu _isLoading thay đổi.
    // Nếu _isLoading không đổi nhưng _appUserWithRole thay đổi, cần gọi thêm.
    // Cách an toàn nhất là luôn gọi ở cuối hàm này nếu có khả năng _appUserWithRole thay đổi.
    notifyListeners(); // Đảm bảo UI cập nhật sau khi _appUserWithRole có thể đã thay đổi
  }

  void _setLoading(bool newLoadingState) {
    if (_isLoading != newLoadingState) {
      _isLoading = newLoadingState;
      notifyListeners();
    }
    // Nếu newLoadingState và _isLoading đã giống nhau, không cần notify.
  }

  // Hàm để UI có thể gọi để làm mới thông tin người dùng một cách chủ động
  Future<void> forceRefreshUserDetails() async {
    print("UserProvider: forceRefreshUserDetails called.");
    final AppUser? basicCurrentUser = _authService.currentUser;
    // Gọi lại hàm xử lý chính để tải lại toàn bộ thông tin user và role
    await _processUserAuthChange(basicCurrentUser);
  }
}