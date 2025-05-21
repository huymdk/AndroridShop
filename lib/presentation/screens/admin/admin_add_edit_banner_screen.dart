import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/banner_service.dart';
import '../../../data/models/banner_model.dart';
import 'package:cached_network_image/cached_network_image.dart';


class AdminAddEditBannerScreen extends StatefulWidget {
  final BannerModel? banner; // Null nếu thêm mới

  const AdminAddEditBannerScreen({super.key, this.banner});

  @override
  State<AdminAddEditBannerScreen> createState() => _AdminAddEditBannerScreenState();
}

class _AdminAddEditBannerScreenState extends State<AdminAddEditBannerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _imageUrlController;
  late TextEditingController _linkUrlController;
  late TextEditingController _orderController;
  bool _isActive = true;
  bool _isLoading = false;

  String _previewImageUrl = ''; // Để hiển thị preview ảnh

  @override
  void initState() {
    super.initState();
    _imageUrlController = TextEditingController(text: widget.banner?.imageUrl ?? '');
    _linkUrlController = TextEditingController(text: widget.banner?.linkUrl ?? '');
    _orderController = TextEditingController(text: widget.banner?.order.toString() ?? '0');
    _isActive = widget.banner?.isActive ?? true;
    _previewImageUrl = widget.banner?.imageUrl ?? '';

    _imageUrlController.addListener(() { // Lắng nghe thay đổi URL để cập nhật preview
      if (mounted && Uri.tryParse(_imageUrlController.text.trim())?.isAbsolute == true) {
        setState(() {
          _previewImageUrl = _imageUrlController.text.trim();
        });
      } else if (mounted && _imageUrlController.text.trim().isEmpty){
        setState(() {
          _previewImageUrl = '';
        });
      }
    });
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    _linkUrlController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _saveBanner() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final bannerService = Provider.of<BannerService>(context, listen: false);

    final String imageUrl = _imageUrlController.text.trim();
    final String? linkUrl = _linkUrlController.text.trim().isNotEmpty ? _linkUrlController.text.trim() : null;
    final int order = int.tryParse(_orderController.text.trim()) ?? 0;

    try {
      if (widget.banner == null) { // Thêm mới
        await bannerService.addBanner(
          imageUrl: imageUrl,
          linkUrl: linkUrl,
          order: order,
          isActive: _isActive,
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm banner mới!'), backgroundColor: Colors.green));
      } else { // Sửa
        await bannerService.updateBanner(
          bannerId: widget.banner!.id,
          imageUrl: imageUrl,
          linkUrl: linkUrl,
          order: order,
          isActive: _isActive,
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật banner!'), backgroundColor: Colors.blue));
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.banner != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa Banner' : 'Thêm Banner Mới'),
        actions: [
          IconButton(icon: const Icon(Icons.save_alt_outlined), onPressed: _isLoading ? null : _saveBanner),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'URL Hình Ảnh Banner', border: OutlineInputBorder(), hintText: 'https://example.com/image.jpg'),
                keyboardType: TextInputType.url,
                validator: (value) => (value == null || value.trim().isEmpty || !Uri.tryParse(value.trim())!.isAbsolute) ? 'Vui lòng nhập URL ảnh hợp lệ.' : null,
              ),
              const SizedBox(height: 10),
              // Hiển thị ảnh preview
              if (_previewImageUrl.isNotEmpty)
                Center(
                  child: CachedNetworkImage(
                    imageUrl: _previewImageUrl,
                    height: 150,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
                    errorWidget: (context, url, error) => const Text('Không thể hiển thị ảnh preview', style: TextStyle(color: Colors.red)),
                  ),
                ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _linkUrlController,
                decoration: const InputDecoration(labelText: 'URL Liên Kết (khi nhấn banner, tùy chọn)', border: OutlineInputBorder()),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty && Uri.tryParse(value.trim())?.isAbsolute != true) {
                    return 'URL liên kết không hợp lệ.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _orderController,
                decoration: const InputDecoration(labelText: 'Thứ Tự Hiển Thị', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) { /* ... */ }, // Giữ nguyên validator
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Kích hoạt banner này?'),
                value: _isActive,
                onChanged: (bool value) => setState(() => _isActive = value),
                activeColor: Theme.of(context).colorScheme.primary,
                contentPadding: EdgeInsets.zero, // Xóa padding mặc định
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveBanner,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: Text(isEditing ? 'Lưu Thay Đổi Banner' : 'Thêm Banner'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}