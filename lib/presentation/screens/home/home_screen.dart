import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Đảm bảo các đường dẫn import này chính xác với cấu trúc dự án của bạn
import '../../../services/auth_service.dart';
import '../../../services/product_service.dart';
import '../../../data/models/product_model.dart';
import '../../providers_or_blocs/user_provider.dart';
import '../../providers_or_blocs/cart_provider.dart';

// Bỏ comment và sửa đường dẫn nếu bạn đã tạo các màn hình này
import '../product/product_detail_screen.dart';
import '../product/product_list_screen.dart';
import '../product/search_result_screen.dart';
import '../cart/cart_screen.dart';
import '../admin/admin_dashboard_screen.dart'; // Import màn hình Admin

// import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Nếu dùng

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _bannerAssetPaths = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpeg',
    'assets/images/banner3.jpg',
  ];

  // TODO: Lấy danh mục từ Firebase hoặc CategoryService/Provider
  final List<Map<String, String>> _categories = [
    {'id': 'all', 'name': 'Tất cả'},
    {'id': 'cat_jeans', 'name': 'Quần Jean'},
    {'id': 'cat_tshirt', 'name': 'Áo Thun'},
    {'id': 'cat_sneakers', 'name': 'Giày Sneaker'},
    {'id': 'cat_accessories', 'name': 'Phụ Kiện'},
  ];

  String _selectedCategoryId = 'all';
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (_bannerAssetPaths.length > 1) {
      _bannerTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
        if (!mounted || !_bannerController.hasClients || _bannerController.page == null) return;
        int nextPage = _bannerController.page!.round() + 1;
        if (nextPage >= _bannerAssetPaths.length) nextPage = 0;
        _bannerController.animateToPage(nextPage,
            duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      });
    }
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _bannerTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => SearchResultScreen(searchQuery: trimmedQuery),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập từ khóa tìm kiếm.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context, listen: false);
    final theme = Theme.of(context); // Lấy theme một lần để tái sử dụng

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext scaffoldContext) {
            return IconButton(
              icon: Icon(Icons.menu, color: theme.appBarTheme.iconTheme?.color ?? theme.iconTheme.color),
              onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
            );
          },
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: theme.inputDecorationTheme.fillColor ?? Colors.grey[200],
            borderRadius: BorderRadius.circular(25), // Tăng bo góc
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm sản phẩm...',
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
              contentPadding: const EdgeInsets.only(left: 15, right: 15, top: 11, bottom: 9), // Điều chỉnh padding
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: _performSearch,
          ),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart_outlined, color: theme.appBarTheme.actionsIconTheme?.color ?? theme.iconTheme.color),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const CartScreen()));
                  },
                ),
                if (cart.totalItemsInCart > 0)
                  Positioned(
                    right: 8, top: 8, // Điều chỉnh vị trí badge
                    child: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle), // Badge hình tròn
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${cart.totalItemsInCart}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        elevation: 1,
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          if (mounted) setState(() {}); // Trigger StreamBuilders để fetch lại dữ liệu
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Banner Quảng Cáo
              if (_bannerAssetPaths.isNotEmpty)
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.55, // Tăng chiều cao banner 1 chút
                  child: PageView.builder(
                    controller: _bannerController,
                    itemCount: _bannerAssetPaths.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 6.0), // Giảm padding banner
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0), // Giảm bo góc banner
                          child: Image.asset(
                            _bannerAssetPaths[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print("Lỗi load asset banner: ${_bannerAssetPaths[index]} - $error");
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              // TODO: Thêm chỉ báo trang cho Banner (ví dụ dùng package smooth_page_indicator)

              // 2. Danh Mục Nhanh
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0), // Điều chỉnh padding
                child: Text("Danh Mục", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 40.0, // Giảm chiều cao ChoiceChip một chút
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    bool isSelected = category['id'] == _selectedCategoryId;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(category['name']!, style: const TextStyle(fontSize: 13)), // Giảm font size
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedCategoryId = category['id']!);
                        },
                        selectedColor: theme.colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? theme.colorScheme.onPrimary : theme.textTheme.bodyMedium?.color,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        backgroundColor: theme.chipTheme.backgroundColor ?? theme.colorScheme.surfaceVariant,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), // Bo góc nhiều hơn
                        pressElevation: 0,
                        elevation: isSelected ? 1 : 0,
                        side: isSelected ? BorderSide.none : BorderSide(color: Colors.grey[350]!),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Điều chỉnh padding của chip
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20.0),

              // 3. Tiêu đề Mục Sản Phẩm và Nút Xem Thêm
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategoryId == 'all'
                          ? "Sản Phẩm Nổi Bật"
                          : _categories.firstWhere((cat) => cat['id'] == _selectedCategoryId, orElse: () => {'name': 'Sản phẩm'})['name']!,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (_selectedCategoryId != 'all')
                      TextButton(
                        onPressed: () {
                          final selectedCategoryData = _categories.firstWhere((cat) => cat['id'] == _selectedCategoryId);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => ProductListScreen(
                                categoryId: _selectedCategoryId,
                                categoryName: selectedCategoryData['name']!,
                              ),
                            ),
                          );
                        },
                        child: Text("Xem tất cả", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),

              // 4. Lưới Sản Phẩm
              StreamBuilder<List<Product>>(
                stream: productService.getProductsByCategory(_selectedCategoryId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40.0), child: CircularProgressIndicator()));
                  }
                  if (snapshot.hasError) {
                    print("Lỗi StreamBuilder sản phẩm: ${snapshot.error}");
                    return Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text('Lỗi tải sản phẩm.\n${snapshot.error}')));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40.0), child: Text('Không có sản phẩm nào trong mục này.')));
                  }
                  final products = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 0.60, // Giảm tỉ lệ để item cao hơn một chút
                      crossAxisSpacing: 10, mainAxisSpacing: 10, // Giảm khoảng cách
                    ),
                    itemBuilder: (ctx, index) => ProductGridItem(product: products[index]),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductGridItem extends StatelessWidget {
  final Product product;
  const ProductGridItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Card(
      elevation: 2, // Giảm elevation
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Giảm bo góc
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => ProductDetailScreen(productId: product.id)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 3, // Giữ nguyên tỉ lệ ảnh
              child: (product.imageUrls.isNotEmpty && product.imageUrls.first.isNotEmpty)
                  ? Hero(
                tag: 'product_image_${product.id}',
                child: CachedNetworkImage(
                  imageUrl: product.imageUrls.first,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200], child: const Center(child: CircularProgressIndicator(strokeWidth: 1.5))),
                  errorWidget: (context, url, error) => Container(color: Colors.grey[200], child: Icon(Icons.broken_image_outlined, size: 30, color: Colors.grey[400])),
                ),
              )
                  : Container(color: Colors.grey[200], child: Center(child: Icon(Icons.image_not_supported_outlined, size: 30, color: Colors.grey[400]))),
            ),
            Padding( // Sử dụng Padding thay vì Expanded cho phần text
              padding: const EdgeInsets.all(8.0), // Giảm padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Để Column chỉ chiếm không gian cần thiết
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, height: 1.2), // Dùng bodyMedium
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                    style: TextStyle(fontSize: 14, color: theme.colorScheme.primary, fontWeight: FontWeight.bold), // Giảm font size giá
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 28, // Giảm chiều cao nút
                    width: double.infinity,
                    child: ElevatedButton.icon( // Đổi thành ElevatedButton cho nổi bật hơn
                      icon: Icon(Icons.add_shopping_cart, size: 14), // Bỏ _outlined
                      label: Text('Thêm', style: TextStyle(fontSize: 11)), // Giảm font size
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), // Giảm bo góc nút
                      ),
                      onPressed: product.stockQuantity == 0 ? null : () {
                        cartProvider.addItem(product);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('${product.name} đã được thêm vào giỏ!'),
                          duration: const Duration(seconds: 2),
                          action: SnackBarAction(
                            label: 'XEM GIỎ',
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const CartScreen()));
                            },
                          ),
                        ));
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              userProvider.appUserWithRole?.displayName ?? 'Khách Vãng Lai',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(
              userProvider.appUserWithRole?.email ?? '',
              style: const TextStyle(color: Colors.white70),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: (userProvider.appUserWithRole?.photoUrl != null && userProvider.appUserWithRole!.photoUrl!.isNotEmpty)
                  ? CachedNetworkImageProvider(userProvider.appUserWithRole!.photoUrl!)
                  : null,
              onBackgroundImageError: (userProvider.appUserWithRole?.photoUrl != null && userProvider.appUserWithRole!.photoUrl!.isNotEmpty)
                  ? (Object exception, StackTrace? stackTrace) {
                print('AppDrawer: Lỗi tải ảnh đại diện: $exception');
              }
                  : null,
              child: (userProvider.appUserWithRole?.photoUrl == null || userProvider.appUserWithRole!.photoUrl!.isEmpty)
                  ? Icon(Icons.person, size: 50, color: Theme.of(context).colorScheme.primary)
                  : null,
            ),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
          ),
          ListTile(leading: const Icon(Icons.home_outlined), title: const Text('Trang Chủ'), onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.category_outlined), title: const Text('Danh Mục'), onTap: () { Navigator.pop(context); /* TODO */ }),
          ListTile(leading: const Icon(Icons.shopping_bag_outlined), title: const Text('Đơn Hàng'), onTap: () { Navigator.pop(context); /* TODO */ }),
          ListTile(leading: const Icon(Icons.account_circle_outlined), title: const Text('Tài Khoản'), onTap: () { Navigator.pop(context); /* TODO */ }),
          if (userProvider.isLoggedIn && userProvider.isAdmin) ...[
            const Divider(thickness: 1),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), child: Text("QUẢN TRỊ VIÊN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12))),
            ListTile(
              leading: const Icon(Icons.dashboard_customize_outlined),
              title: const Text('Admin Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
              },
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Đăng Xuất', style: TextStyle(color: Colors.redAccent)),
            onTap: () async {
              final scaffoldContext = Scaffold.maybeOf(context)?.context ?? context;
              Navigator.pop(context);
              final confirmLogout = await showDialog<bool>(
                context: scaffoldContext,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Xác nhận Đăng xuất'),
                    content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                    actions: <Widget>[
                      TextButton(child: const Text('Hủy'), onPressed: () => Navigator.of(dialogContext).pop(false)),
                      TextButton(
                        child: Text('Đăng xuất', style: TextStyle(color: Theme.of(dialogContext).colorScheme.error)),
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                      ),
                    ],
                  );
                },
              );
              if (confirmLogout == true) {
                try {
                  await authService.signOut();
                  print("Đã gọi hàm signOut từ AppDrawer.");
                } catch (e) {
                  print("Lỗi khi đăng xuất từ AppDrawer: ${e.toString()}");
                  if (ScaffoldMessenger.maybeOf(scaffoldContext) != null) {
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(SnackBar(content: Text('Lỗi khi đăng xuất: ${e.toString()}'), backgroundColor: Colors.red));
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }
}