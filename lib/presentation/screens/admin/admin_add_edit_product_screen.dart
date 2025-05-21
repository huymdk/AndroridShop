import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Cho preview ảnh

import '../../../services/product_service.dart';
import '../../../data/models/product_model.dart';

class AdminAddEditProductScreen extends StatefulWidget {
  final Product? product; // Null nếu thêm mới, có giá trị nếu sửa

  const AdminAddEditProductScreen({super.key, this.product});

  @override
  State<AdminAddEditProductScreen> createState() => _AdminAddEditProductScreenState();
}

class _AdminAddEditProductScreenState extends State<AdminAddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockQuantityController;
  String? _selectedCategoryId;

  // TODO: Lấy danh sách danh mục từ Firebase hoặc một nguồn động
  // Hiện tại là dummy data, đảm bảo 'id' khớp với categoryId bạn lưu trên Firestore
  final List<Map<String, String>> _availableCategories = [
    {'id': 'cat_jeans', 'name': 'Quần Jean'},
    {'id': 'cat_tshirt', 'name': 'Áo Thun'},
    {'id': 'cat_sneakers', 'name': 'Giày Sneaker'},
    {'id': 'cat_accessories', 'name': 'Phụ Kiện'},
    // Thêm các danh mục khác nếu cần
  ];

  List<TextEditingController> _imageUrlControllers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toStringAsFixed(0) ?? ''); // Bỏ .0 nếu giá là số nguyên
    _stockQuantityController = TextEditingController(text: widget.product?.stockQuantity.toString() ?? '');
    _selectedCategoryId = widget.product?.categoryId;

    if (widget.product != null && widget.product!.imageUrls.isNotEmpty) {
      _imageUrlControllers = widget.product!.imageUrls.map((url) => TextEditingController(text: url)).toList();
    } else {
      // Thêm một ô nhập URL trống khi thêm mới hoặc khi sản phẩm cũ không có ảnh
      _imageUrlControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockQuantityController.dispose();
    for (var controller in _imageUrlControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addImageUrlField() {
    setState(() {
      _imageUrlControllers.add(TextEditingController());
    });
  }

  void _removeImageUrlField(int index) {
    if (_imageUrlControllers.length > 1) { // Chỉ cho phép xóa nếu còn nhiều hơn 1 ô
      setState(() {
        _imageUrlControllers[index].dispose();
        _imageUrlControllers.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cần ít nhất một URL ảnh sản phẩm.')),
      );
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn danh mục sản phẩm.')));
      return;
    }

    List<String> imageUrls = _imageUrlControllers
        .map((controller) => controller.text.trim())
        .where((url) => url.isNotEmpty && Uri.tryParse(url)?.isAbsolute == true)
        .toList();

    if (imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập ít nhất một URL ảnh hợp lệ.')));
      return;
    }

    setState(() => _isLoading = true);
    final productService = Provider.of<ProductService>(context, listen: false);

    try {
      final String name = _nameController.text.trim();
      final String description = _descriptionController.text.trim();
      final double price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final int stockQuantity = int.tryParse(_stockQuantityController.text.trim()) ?? 0;

      if (widget.product == null) { // Thêm mới
        await productService.addProduct(
          name: name,
          description: description,
          price: price,
          categoryId: _selectedCategoryId!,
          stockQuantity: stockQuantity,
          imageUrls: imageUrls,
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm sản phẩm thành công!'), backgroundColor: Colors.green));
      } else { // Sửa sản phẩm
        await productService.updateProduct(
          existingProduct: widget.product!,
          name: name,
          description: description,
          price: price,
          categoryId: _selectedCategoryId!,
          stockQuantity: stockQuantity,
          imageUrls: imageUrls,
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật sản phẩm!'), backgroundColor: Colors.blue));
      }
      if (mounted) Navigator.of(context).pop(); // Quay lại màn hình danh sách sau khi lưu
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.product != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa Sản Phẩm' : 'Thêm Sản Phẩm Mới'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_outlined),
            tooltip: 'Lưu sản phẩm',
            onPressed: _isLoading ? null : _saveProduct,
          ),
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
              // Tên sản phẩm
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm', border: OutlineInputBorder(), prefixIcon: Icon(Icons.label_outline)),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Vui lòng nhập tên sản phẩm.' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Mô tả
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả sản phẩm', border: OutlineInputBorder(), prefixIcon: Icon(Icons.description_outlined)),
                maxLines: 4, // Tăng số dòng cho mô tả
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Vui lòng nhập mô tả.' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Giá
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Giá (VNĐ)', border: OutlineInputBorder(), prefixText: 'đ ', prefixIcon: Icon(Icons.price_change_outlined)),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Vui lòng nhập giá.';
                  if (double.tryParse(value.trim()) == null || double.parse(value.trim()) <= 0) return 'Giá không hợp lệ.';
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Số lượng tồn kho
              TextFormField(
                controller: _stockQuantityController,
                decoration: const InputDecoration(labelText: 'Số lượng tồn kho', border: OutlineInputBorder(), prefixIcon: Icon(Icons.inventory_2_outlined)),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Vui lòng nhập số lượng.';
                  if (int.tryParse(value.trim()) == null || int.parse(value.trim()) < 0) return 'Số lượng không hợp lệ.';
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Danh mục
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Danh mục sản phẩm',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _availableCategories.map((Map<String, String> category) {
                  return DropdownMenuItem<String>(
                    value: category['id'],
                    child: Text(category['name']!),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategoryId = newValue;
                  });
                },
                validator: (value) => value == null ? 'Vui lòng chọn danh mục.' : null,
                hint: const Text('Chọn danh mục'),
                isExpanded: true,
              ),
              const SizedBox(height: 24),

              Text('URL Hình Ảnh Sản Phẩm', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              // Hiển thị các ô nhập URL ảnh
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _imageUrlControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _imageUrlControllers[index],
                            decoration: InputDecoration(
                              labelText: 'URL Ảnh ${index + 1}',
                              border: const OutlineInputBorder(),
                              hintText: 'https://example.com/image.jpg',
                            ),
                            keyboardType: TextInputType.url,
                            validator: (value) {
                              // Chỉ bắt buộc URL đầu tiên, các URL sau có thể rỗng (để admin có thể xóa bớt)
                              if (index == 0 && (value == null || value.trim().isEmpty)) {
                                return 'Cần ít nhất một URL ảnh.';
                              }
                              if (value != null && value.trim().isNotEmpty && Uri.tryParse(value.trim())?.isAbsolute != true) {
                                return 'URL không hợp lệ.';
                              }
                              return null;
                            },
                            onChanged: (value) { // Rebuild để cập nhật preview ảnh
                              setState(() {});
                            },
                          ),
                        ),
                        if (_imageUrlControllers.length > 1) // Chỉ hiển thị nút xóa nếu có nhiều hơn 1 ô URL
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                            tooltip: 'Xóa URL này',
                            onPressed: () => _removeImageUrlField(index),
                          ),
                      ],
                    ),
                  );
                },
              ),
              // Hiển thị preview ảnh (nếu có URL hợp lệ)
              if (_imageUrlControllers.any((c) => c.text.trim().isNotEmpty && Uri.tryParse(c.text.trim())?.isAbsolute == true))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _imageUrlControllers
                        .where((c) => c.text.trim().isNotEmpty && Uri.tryParse(c.text.trim())?.isAbsolute == true)
                        .map((controller) => ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        imageUrl: controller.text.trim(),
                        width: 80, height: 80, fit: BoxFit.cover,
                        placeholder: (ctx, url) => Container(width: 80, height: 80, color: Colors.grey[200]),
                        errorWidget: (ctx, url, err) => Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.error_outline, color: Colors.redAccent)),
                      ),
                    ))
                        .toList(),
                  ),
                ),

              TextButton.icon(
                icon: const Icon(Icons.add_link),
                label: const Text('Thêm Ô Nhập URL Ảnh'),
                onPressed: _addImageUrlField,
              ),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(isEditing ? 'Lưu Thay Đổi' : 'Thêm Sản Phẩm'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                onPressed: _isLoading ? null : _saveProduct,
              ),
            ],
          ),
        ),
      ),
    );
  }
}