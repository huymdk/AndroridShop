import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Đảm bảo các đường dẫn import này chính xác
import '../../../services/banner_service.dart';
import '../../../data/models/banner_model.dart';

// Import màn hình thêm/sửa banner
import 'admin_add_edit_banner_screen.dart';

class AdminBannerManagementScreen extends StatelessWidget {
  const AdminBannerManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bannerService = Provider.of<BannerService>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Banner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Thêm banner mới',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminAddEditBannerScreen(banner: null)),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<BannerModel>>(
        stream: bannerService.getAllBannersForAdmin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("Lỗi tải danh sách banner: ${snapshot.error}");
            return Center(child: Text('Lỗi tải danh sách banner: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Chưa có banner nào. Hãy thêm mới!'));
          }

          final banners = snapshot.data!;
          banners.sort((a, b) => a.order.compareTo(b.order));

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: banners.length,
            itemBuilder: (ctx, index) {
              final banner = banners[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: SizedBox(
                    width: 100,
                    height: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: banner.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: banner.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey[200], child: const Center(child: CircularProgressIndicator(strokeWidth: 1.5))),
                        errorWidget: (context, url, error) => Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey)),
                      )
                          : Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey)),
                    ),
                  ),
                  title: Text( // ĐIỀN NỘI DUNG CHO TITLE
                    'Banner Thứ Tự: ${banner.order}', // Ví dụ
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column( // ĐIỀN NỘI DUNG CHO SUBTITLE
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        banner.isActive ? "Trạng thái: Đang hoạt động" : "Trạng thái: Không hoạt động",
                        style: TextStyle(fontSize: 12, color: banner.isActive ? Colors.green[700] : Colors.red[700]),
                      ),
                      if (banner.linkUrl != null && banner.linkUrl!.isNotEmpty)
                        Text('Link: ${banner.linkUrl}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                      Text('ID: ${banner.id}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                        tooltip: 'Sửa banner',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AdminAddEditBannerScreen(banner: banner)),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                        tooltip: 'Xóa banner',
                        onPressed: () async {
                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          // final navigator = Navigator.of(context); // Không cần thiết nếu chỉ pop dialog

                          final confirmDelete = await showDialog<bool>(
                            context: context,
                            builder: (dialogCtx) => AlertDialog(
                              title: const Text('Xác nhận xóa'),
                              content: Text('Bạn có chắc muốn xóa banner order ${banner.order}?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(dialogCtx).pop(false), child: const Text('Hủy')),
                                TextButton(
                                  onPressed: () => Navigator.of(dialogCtx).pop(true),
                                  child: Text('Xóa', style: TextStyle(color: theme.colorScheme.error)),
                                ),
                              ],
                            ),
                          );
                          if (confirmDelete == true) {
                            try {
                              await bannerService.deleteBanner(banner.id);
                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text('Đã xóa banner order ${banner.order}'), backgroundColor: Colors.green),
                              );
                            } catch (e) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text('Lỗi khi xóa banner: $e'), backgroundColor: theme.colorScheme.error),
                              );
                            }
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          banner.isActive ? Icons.toggle_on : Icons.toggle_off_outlined,
                          color: banner.isActive ? Colors.green : Colors.grey[600],
                          size: 32,
                        ),
                        tooltip: banner.isActive ? 'Vô hiệu hóa banner' : 'Kích hoạt banner',
                        onPressed: () async {
                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          final currentTheme = Theme.of(context);
                          final bool newIsActiveStatus = !banner.isActive;
                          try {
                            await bannerService.updateBanner(
                              bannerId: banner.id,
                              imageUrl: banner.imageUrl,
                              linkUrl: banner.linkUrl,
                              order: banner.order,
                              isActive: newIsActiveStatus,
                            );
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text('Banner order #${banner.order} đã được ${newIsActiveStatus ? "kích hoạt" : "vô hiệu hóa"}'),
                                backgroundColor: Colors.blue,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } catch (e) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text('Lỗi cập nhật trạng thái banner: ${e.toString()}'),
                                backgroundColor: currentTheme.colorScheme.error,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}