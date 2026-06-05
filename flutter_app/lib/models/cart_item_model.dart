class CartItemModel {
  final int id;
  final int laptopId;
  final String name;
  final String brand;
  final double price;
  final String? imageUrl;
  final String? processor;
  final String? ram;
  final String? storage;
  int quantity;
  final double subtotal;

  CartItemModel({
    required this.id,
    required this.laptopId,
    required this.name,
    required this.brand,
    required this.price,
    this.imageUrl,
    this.processor,
    this.ram,
    this.storage,
    required this.quantity,
    required this.subtotal,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? 0,
      laptopId: json['laptop_id'] ?? 0,
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl: json['image_url'],
      processor: json['processor'],
      ram: json['ram'],
      storage: json['storage'],
      quantity: json['quantity'] ?? 1,
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0.0,
    );
  }
}
