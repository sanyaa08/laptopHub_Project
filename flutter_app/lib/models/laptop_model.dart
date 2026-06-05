class LaptopModel {
  final int id;
  final String name;
  final String brand;
  final double price;
  final String? imageUrl;
  final String? processor;
  final String? ram;
  final String? storage;
  final String? display;
  final String? graphics;
  final String? battery;
  final String? weight;
  final String? os;
  final String? description;
  final int stock;
  final bool isFeatured;
  final String? createdAt;

  LaptopModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    this.imageUrl,
    this.processor,
    this.ram,
    this.storage,
    this.display,
    this.graphics,
    this.battery,
    this.weight,
    this.os,
    this.description,
    this.stock = 0,
    this.isFeatured = false,
    this.createdAt,
  });

  bool get inStock => stock > 0;

  factory LaptopModel.fromJson(Map<String, dynamic> json) {
    return LaptopModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl: json['image_url'],
      processor: json['processor'],
      ram: json['ram'],
      storage: json['storage'],
      display: json['display'],
      graphics: json['graphics'],
      battery: json['battery'],
      weight: json['weight'],
      os: json['os'],
      description: json['description'],
      stock: json['stock'] ?? 0,
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'brand': brand,
      'price': price,
      'image_url': imageUrl,
      'processor': processor,
      'ram': ram,
      'storage': storage,
      'display': display,
      'graphics': graphics,
      'battery': battery,
      'weight': weight,
      'os': os,
      'description': description,
      'stock': stock,
      'is_featured': isFeatured,
    };
  }
}
