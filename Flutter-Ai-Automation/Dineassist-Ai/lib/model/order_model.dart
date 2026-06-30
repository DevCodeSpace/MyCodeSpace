class OrderItem {
  final String name;
  final int quantity;
  final int price;

  OrderItem({required this.name, required this.quantity, required this.price});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(name: json['name'], quantity: json['quantity'], price: json['price']);
  }
}

class RestaurantOrderModel {
  final List<OrderItem> items;
  final int total;
  final String suggestion;

  RestaurantOrderModel({required this.items, required this.total, required this.suggestion});

  factory RestaurantOrderModel.fromJson(Map<String, dynamic> json) {
    return RestaurantOrderModel(items: (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList(), total: json['total'], suggestion: json['suggestion']);
  }
}
