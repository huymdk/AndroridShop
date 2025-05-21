import 'package:flutter/material.dart';

// Import các màn hình Admin bạn đã tạo (hoặc sẽ tạo)
import 'admin_product_list_screen.dart';
import 'admin_order_list_screen.dart';
import 'admin_banner_management_screen.dart';
// import 'admin_statistics_screen.dart'; // Nếu bạn quyết định làm thống kê
// import 'admin_user_management_screen.dart';
// import 'admin_category_management_screen.dart';
// import 'admin_promotion_management_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 1,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: <Widget>[
          _buildDashboardItem(
            context,
            icon: Icons.inventory_2_outlined,
            label: 'Quản lý Sản Phẩm',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminProductListScreen()),
              );
            },
          ),
          _buildDashboardItem(
            context,
            icon: Icons.receipt_long_outlined,
            label: 'Quản lý Đơn Hàng',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminOrderListScreen()),
              );
            },
          ),
          _buildDashboardItem(
            context,
            icon: Icons.view_carousel_outlined,
            label: 'Quản lý Banner',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminBannerManagementScreen()),
              );
            },
          ),
          _buildDashboardItem(
            context,
            icon: Icons.bar_chart_outlined, // Giữ lại icon thống kê hoặc đổi
            label: 'Xem Thống Kê', // Hoặc tên chức năng khác bạn muốn
            onTap: () {
              // TODO: Tạo AdminStatisticsScreen và điều hướng nếu bạn làm thống kê
              // Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminStatisticsScreen()));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng Xem Thống Kê (Admin) chưa triển khai!')),
              );
            },
          ),
          _buildDashboardItem(
            context,
            icon: Icons.people_alt_outlined,
            label: 'Quản lý Người Dùng',
            onTap: () {
              // TODO: Tạo AdminUserManagementScreen và điều hướng
              // Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUserManagementScreen()));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng Quản lý Người dùng (Admin) chưa triển khai!')),
              );
            },
          ),
          _buildDashboardItem(
            context,
            icon: Icons.category_outlined,
            label: 'Quản lý Danh Mục',
            onTap: () {
              // TODO: Tạo AdminCategoryManagementScreen và điều hướng
              // Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCategoryManagementScreen()));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng Quản lý Danh mục (Admin) chưa triển khai!')),
              );
            },
          ),
          _buildDashboardItem(
            context,
            icon: Icons.local_offer_outlined,
            label: 'Quản lý Khuyến Mãi',
            onTap: () {
              // TODO: Tạo AdminPromotionManagementScreen và điều hướng
              // Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPromotionManagementScreen()));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng Quản lý Khuyến mãi (Admin) chưa triển khai!')),
              );
            },
          ),
          // Bạn có thể thêm hoặc bớt các item tùy theo chức năng admin bạn muốn có
        ],
      ),
    );
  }

  Widget _buildDashboardItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}