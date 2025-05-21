import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Cho định dạng ngày tháng
import '../../../services/order_service.dart';
import '../../../data/models/order_model.dart';
// Import màn hình chi tiết đơn hàng (sẽ tạo sau)
// import 'admin_order_detail_screen.dart';

class AdminOrderListScreen extends StatelessWidget {
  const AdminOrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderService = Provider.of<OrderService>(context, listen: false);
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Đơn Hàng'),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: orderService.getAllOrders(), // Lấy tất cả đơn hàng
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải danh sách đơn hàng: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Chưa có đơn hàng nào.'));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (ctx, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                child: ListTile(
                  title: Text('ĐH: ${order.id?.substring(0, 8)}... - ${order.shippingAddress.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(order.orderDate.toDate())}'),
                      Text('Tổng tiền: ${currencyFormatter.format(order.totalAmount)}'),
                      Text('Trạng thái: ${order.status.toUpperCase()}', style: TextStyle(fontWeight: FontWeight.w500, color: _getStatusColor(order.status, context))),
                    ],
                  ),
                  trailing: Icon(Icons.chevron_right, color: Theme.of(context).primaryColor),
                  onTap: () {
                    // TODO: Điều hướng đến AdminOrderDetailScreen với order hiện tại
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (_) => AdminOrderDetailScreen(order: order)),
                    // );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Xem chi tiết ĐH: ${order.id} (chưa triển khai)')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Theme.of(context).colorScheme.error;
      default:
        return Colors.grey;
    }
  }
}