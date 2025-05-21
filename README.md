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

Thực hiện các bước sau để cài đặt và chạy dự án trên máy của bạn.

### Bước 1: Clone Repository (Hoặc Giải Nén Dự Án)

- **Nếu dự án được lưu trữ trên Git (ví dụ: GitHub, GitLab):**
  Mở terminal hoặc command prompt và chạy các lệnh sau:

  ```bash
  git clone <URL_CUA_REPOSITORY_CUA_BAN>
  cd <TEN_THU_MUC_DU_AN>
  ```

  Thay thế `<URL_CUA_REPOSITORY_CUA_BAN>` bằng URL thực tế của repository và `<TEN_THU_MUC_DU_AN>` bằng tên thư mục dự án sau khi clone.

- **Nếu bạn nhận được project dưới dạng file nén (.zip, .rar, ...):**
  Hãy giải nén file đó ra một thư mục trên máy tính của bạn. Sau đó, mở terminal và điều hướng vào thư mục dự án vừa giải nén.

### Bước 2: Cài Đặt Flutter SDK

1.  **Kiểm tra cài đặt Flutter:**
    Mở terminal và chạy lệnh:

    ```bash
    flutter --version
    ```

    Nếu Flutter chưa được cài đặt hoặc không được nhận diện, bạn cần cài đặt Flutter SDK.

2.  **Cài đặt Flutter (nếu chưa có):**
    Làm theo hướng dẫn chi tiết trên trang chủ của Flutter:
    [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
    Chọn hệ điều hành của bạn (Windows, macOS, Linux) và làm theo các bước.

3.  **Kiểm tra môi trường Flutter:**
    Sau khi cài đặt, chạy lệnh:
    ```bash
    flutter doctor
    ```
    Đảm bảo không có lỗi nghiêm trọng nào (`[✗]`). Các cảnh báo (`[!]`) liên quan đến thiết bị iOS/macOS hoặc Android Studio có thể bỏ qua nếu bạn không phát triển cho nền tảng đó hoặc đã có các công cụ cần thiết khác. Quan trọng là Flutter SDK, Dart SDK, và các công cụ build cho Android (nếu bạn chạy trên Android) phải được thiết lập đúng.

### Bước 3: Thiết Lập Dự Án Firebase

1.  **Tạo dự án trên Firebase Console:**

    - Truy cập [https://console.firebase.google.com/](https://console.firebase.google.com/).
    - Nhấn **"Add project"** (Thêm dự án) và làm theo hướng dẫn để tạo một dự án Firebase mới.
    - Đặt tên cho dự án của bạn (ví dụ: `MyFlutterShopApp`).
    - **Bật Google Analytics** cho dự án (khuyến khích).

2.  **Kích hoạt các dịch vụ Firebase cần thiết trong dự án vừa tạo:**

    - **Authentication (Xác thực):**

      1.  Trong menu bên trái của Firebase Console, chọn **Authentication**.
      2.  Nhấn **"Get started"**.
      3.  Chuyển qua tab **"Sign-in method"**.
      4.  Tìm và **Bật (Enable)** các nhà cung cấp đăng nhập bạn muốn sử dụng:
          - **Email/Password**: Bắt buộc cho chức năng đăng ký/đăng nhập bằng email.
          - **Google**: Nếu bạn muốn có chức năng đăng nhập bằng Google.
            - Khi bật Google Sign-In, bạn sẽ cần cung cấp "Project support email".
            - **Lưu ý quan trọng cho Android:** Để Google Sign-In hoạt động trên Android, bạn cần thêm **SHA-1 fingerprint** của ứng dụng vào cài đặt ứng dụng Android trên Firebase Console (xem chi tiết ở Bước 4.5).

    - **Cloud Firestore (Cơ sở dữ liệu):**

      1.  Trong menu bên trái, chọn **Firestore Database**.
      2.  Nhấn **"Create database"**.
      3.  **Chế độ bảo mật:**
          - **Production mode (Chế độ sản xuất):** `allow read, write: if false;`. Bạn sẽ cần cập nhật Security Rules sau. Đây là lựa chọn an toàn hơn để bắt đầu.
          - **Test mode (Chế độ thử nghiệm):** `allow read, write: if request.time < timestamp.date(YYYY, MM, DD);`. Cho phép truy cập trong 30 ngày. **Nhớ cập nhật rules trước khi đưa ứng dụng lên production.**
      4.  **Vị trí (Location):** Chọn vị trí máy chủ cho Firestore gần với người dùng của bạn nhất (ví dụ: `asia-southeast1` cho Đông Nam Á). **Lưu ý:** Vị trí này không thể thay đổi sau khi đã chọn.
      5.  Nhấn **"Enable"**.

    - **Storage (Lưu trữ file - nếu bạn cho phép Admin upload ảnh từ app):**
      1.  Trong menu bên trái, chọn **Storage**.
      2.  Nhấn **"Get started"**.
      3.  Thiết lập quy tắc bảo mật ban đầu. Ví dụ, để dễ test (nhưng kém bảo mật):
          ```
          rules_version = '2';
          service firebase.storage {
            match /b/{bucket}/o {
              match /{allPaths=**} {
                allow read, write: if request.auth != null; // Chỉ cho phép nếu đã đăng nhập
              }
            }
          }
          ```
          **Lưu ý:** Nếu Firebase yêu cầu "Upgrade project" để sử dụng Storage, bạn có thể cần nâng cấp lên gói Blaze (trả phí theo dung lượng sử dụng) hoặc tạm thời sử dụng URL ảnh placeholder/ảnh từ `assets` như đã thảo luận.

### Bước 4: Cấu Hình Dự Án Flutter với Firebase

1.  **Cài đặt Firebase CLI (nếu chưa có):**
    Yêu cầu Node.js và npm đã được cài đặt. Mở terminal và chạy:

    ```bash
    npm install -g firebase-tools
    ```

2.  **Đăng nhập Firebase CLI:**

    ```bash
    firebase login
    ```

    Làm theo hướng dẫn trên trình duyệt để đăng nhập.

3.  **Cài đặt FlutterFire CLI (nếu chưa có):**

    ```bash
    dart pub global activate flutterfire_cli
    ```

    Đảm bảo đường dẫn `~/.pub-cache/bin` (hoặc tương tự trên Windows) đã được thêm vào biến môi trường PATH của bạn.

4.  **Kết nối dự án Flutter với Firebase:**
    Mở terminal tại **thư mục gốc của dự án Flutter** (nơi chứa file `pubspec.yaml`) và chạy lệnh:

    ```bash
    flutterfire configure
    ```

    - Làm theo các bước hướng dẫn trên terminal:
      - Nó sẽ yêu cầu bạn chọn dự án Firebase bạn đã tạo ở Bước 3.
      - Chọn các nền tảng bạn muốn cấu hình cho ứng dụng Flutter (ví dụ: Android, iOS, Web).
    - Lệnh này sẽ tự động tải về các file cấu hình cần thiết (ví dụ: `android/app/google-services.json` cho Android, `ios/Runner/GoogleService-Info.plist` cho iOS) và tạo file `lib/firebase_options.dart`.

5.  **(Quan trọng cho Android - Google Sign-In và một số dịch vụ khác)**
    - Nếu bạn sử dụng Google Sign-In hoặc các dịch vụ Firebase khác yêu cầu, bạn cần thêm **SHA-1 fingerprint** của debug keystore (và sau này là release keystore) vào cài đặt ứng dụng Android trên Firebase Console.
    - **Đi đến:** Firebase Console > Project Settings (⚙️) > tab "General" > cuộn xuống "Your apps" > chọn ứng dụng Android của bạn > nhấn "Add fingerprint".
    - **Cách lấy debug SHA-1:**
      1.  Mở terminal.
      2.  Điều hướng vào thư mục `android` của dự án Flutter: `cd android`
      3.  Chạy lệnh:
          - Trên macOS/Linux: `./gradlew signingReport`
          - Trên Windows: `gradlew signingReport`
      4.  Tìm dòng `SHA1:` trong kết quả của variant `debug`. Copy giá trị đó.
    - Sau khi thêm SHA-1 fingerprint vào Firebase Console, **tải lại file `google-services.json`** từ Firebase Console (trong cài đặt ứng dụng Android) và đặt nó vào thư mục `android/app/` của dự án Flutter, ghi đè file cũ nếu có.

### Bước 5: Lấy Dependencies (Các Gói Cần Thiết)

Mở terminal tại thư mục gốc của dự án Flutter và chạy lệnh:

`````bash
flutter pub get
```
Lệnh này sẽ tải về tất cả các package (thư viện) đã được khai báo trong file pubspec.yaml.

Bước 6: Chạy Ứng Dụng

````bash
flutter run
```
`````
