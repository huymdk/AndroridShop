# Đồ Án Cuối Kỳ: Ứng Dụng Shop Thương Mại Điện Tử Bằng Flutter

Đây là dự án xây dựng ứng dụng mua sắm trực tuyến đa nền tảng sử dụng Flutter và Firebase.

## Mục Lục

- [Tổng Quan Chức Năng](#tổng-quan-chức-năng)
- [Công Nghệ Sử Dụng](#công-nghệ-sử-dụng)
- [Yêu Cầu Hệ Thống](#yêu-cầu-hệ-thống)
- [Hướng Dẫn Cài Đặt và Chạy Dự Án](#hướng-dẫn-cài-đặt-và-chạy-dự-án)
  - [Bước 1: Clone Repository](#bước-1-clone-repository)
  - [Bước 2: Cài Đặt Flutter SDK](#bước-2-cài-đặt-flutter-sdk)
  - [Bước 3: Thiết Lập Firebase](#bước-3-thiết-lập-firebase)
  - [Bước 4: Cấu Hình Dự Án Flutter với Firebase](#bước-4-cấu-hình-dự-án-flutter-với-firebase)
  - [Bước 5: Lấy Dependencies](#bước-5-lấy-dependencies)
  - [Bước 6: Chạy Ứng Dụng](#bước-6-chạy-ứng-dụng)
- [Cấu Trúc Thư Mục Dự Án](#cấu-trúc-thư-mục-dự-án)
- [Tính Năng Nổi Bật](#tính-năng-nổi-bật)
- [Đóng Góp](#đóng-góp)
- [Tác Giả](#tác-giả)

---

## Tổng Quan Chức Năng

Ứng dụng cho phép người dùng:

- Đăng ký, đăng nhập tài khoản (Email/Password, Google Sign-In).
- Xem danh sách sản phẩm theo danh mục.
- Tìm kiếm sản phẩm.
- Xem chi tiết sản phẩm.
- Thêm sản phẩm vào giỏ hàng.
- Quản lý giỏ hàng (thay đổi số lượng, xóa sản phẩm).
- Thực hiện quy trình thanh toán (COD).
- Xem lịch sử đơn hàng.

Chức năng Admin (truy cập qua tài khoản có vai trò "admin"):

- Quản lý sản phẩm (Thêm/Sửa/Xóa).
- Quản lý đơn hàng (Xem danh sách, cập nhật trạng thái).
- Quản lý banner quảng cáo trang chủ.
- (Tùy chọn) Xem thống kê cơ bản.

---

## Công Nghệ Sử Dụng

- **Ngôn ngữ:** Dart
- **Framework:** Flutter
- **Backend & Database:** Firebase
  - Firebase Authentication (Xác thực)
  - Cloud Firestore (Cơ sở dữ liệu NoSQL)
  - Firebase Storage (Lưu trữ ảnh - _Lưu ý: Hiện tại có thể đang sử dụng URL ảnh hardcode/placeholder nếu Storage chưa được kích hoạt đầy đủ_)
  - (Tùy chọn) Firebase Cloud Functions
- **State Management:** Provider
- **UI:** Material Design, các widget Flutter cơ bản, `cached_network_image`, `fl_chart` (nếu có thống kê).
- **Khác:** `image_picker` (cho Admin upload ảnh - nếu Storage được dùng), `intl` (định dạng).

---

## Yêu Cầu Hệ Thống

- **Flutter SDK:** Phiên bản 3.x.x trở lên (Kiểm tra file `pubspec.yaml` để biết phiên bản SDK chính xác được sử dụng: `environment: sdk: '>=X.Y.Z <A.B.C'`).
- **IDE:** Android Studio (khuyến khích) hoặc Visual Studio Code với các plugin Flutter và Dart đã cài đặt.
- **Java Development Kit (JDK):** Cần thiết cho việc build ứng dụng Android.
- **Để build cho iOS:** Cần có macOS với Xcode đã cài đặt.
- **Để build cho Android:** Cần có Android SDK và các công cụ build cần thiết (thường đi kèm với Android Studio).
- **Trình duyệt web:** Nếu muốn chạy phiên bản web.

---

## Hướng Dẫn Cài Đặt và Chạy Dự Án

### Bước 1: Clone Repository

Nếu dự án được lưu trữ trên Git (ví dụ: GitHub, GitLab):

```bash
git clone <URL_CUA_REPOSITORY_CUA_BAN>
cd <TEN_THU_MUC_DU_AN>
Use code with caution.
Markdown
Nếu bạn nhận được project dưới dạng file nén, hãy giải nén nó.
Bước 2: Cài Đặt Flutter SDK
Nếu bạn chưa cài đặt Flutter, hãy làm theo hướng dẫn trên trang chủ của Flutter: https://flutter.dev/docs/get-started/install
Đảm bảo lệnh flutter doctor chạy không có lỗi nghiêm trọng (các cảnh báo về iOS/macOS có thể bỏ qua nếu bạn chỉ chạy trên Android/Web).
Bước 3: Thiết Lập Firebase
Tạo dự án Firebase:
Truy cập Firebase Console.
Nhấn "Add project" và tạo một dự án mới. Đặt tên dự án (ví dụ: MyFlutterShopApp).
Bật Google Analytics cho dự án (khuyến khích).
Kích hoạt các dịch vụ Firebase cần thiết:
Authentication:
Vào mục Authentication > tab "Sign-in method".
Bật các nhà cung cấp đăng nhập bạn muốn sử dụng (ví dụ: "Email/Password", "Google").
Nếu dùng Google Sign-In cho Android, bạn sẽ cần thêm SHA-1 fingerprint vào cài đặt ứng dụng Android trên Firebase.
Cloud Firestore:
Vào mục Firestore Database.
Nhấn "Create database".
Chọn chế độ "Start in production mode" (và sau đó cập nhật Security Rules) hoặc "Start in test mode" (nhớ cập nhật rules sau 30 ngày).
Chọn vị trí (location) cho database.
Firebase Storage (Nếu bạn dùng để upload ảnh từ app):
Vào mục Storage.
Nhấn "Get started".
Thiết lập quy tắc bảo mật ban đầu.
Lưu ý: Nếu gặp yêu cầu "Upgrade project", bạn có thể cần nâng cấp lên gói Blaze hoặc tạm thời sử dụng URL ảnh placeholder như đã thảo luận.
Bước 4: Cấu Hình Dự Án Flutter với Firebase
Cài đặt Firebase CLI:
npm install -g firebase-tools
Use code with caution.
Bash
(Yêu cầu Node.js và npm đã được cài đặt)
Đăng nhập Firebase CLI:
firebase login
Use code with caution.
Bash
Cài đặt FlutterFire CLI:
dart pub global activate flutterfire_cli
Use code with caution.
Bash
Kết nối dự án Flutter với Firebase:
Mở terminal tại thư mục gốc của dự án Flutter và chạy:
flutterfire configure
Use code with caution.
Bash
Chọn dự án Firebase bạn đã tạo ở Bước 3.
Chọn các nền tảng bạn muốn cấu hình (Android, iOS, Web).
Lệnh này sẽ tự động tải về các file cấu hình cần thiết (ví dụ: google-services.json cho Android, GoogleService-Info.plist cho iOS) và tạo file lib/firebase_options.dart.
(Quan trọng cho Android - Google Sign-In và một số dịch vụ khác)
Nếu bạn sử dụng Google Sign-In hoặc các dịch vụ Firebase khác yêu cầu, bạn cần thêm SHA-1 fingerprint của debug keystore (và sau này là release keystore) vào cài đặt ứng dụng Android trên Firebase Console (Project Settings > Your apps > (Chọn app Android) > Add fingerprint).
Cách lấy debug SHA-1:
Mở terminal trong thư mục android của dự án Flutter.
Chạy: ./gradlew signingReport (macOS/Linux) hoặc gradlew signingReport (Windows).
Sau khi thêm SHA-1, tải lại file google-services.json từ Firebase Console và đặt vào thư mục android/app/.
Bước 5: Lấy Dependencies
Mở terminal tại thư mục gốc của dự án Flutter và chạy:
flutter pub get
Use code with caution.
Bash
Lệnh này sẽ tải về tất cả các package được khai báo trong file pubspec.yaml.
Bước 6: Chạy Ứng Dụng
Mở một emulator Android/iOS simulator hoặc kết nối thiết bị thật.
Trong Android Studio/VS Code:
Chọn thiết bị target.
Nhấn nút Run.
Hoặc từ terminal:
flutter run
```
