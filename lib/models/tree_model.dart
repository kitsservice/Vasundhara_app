class TreeModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double co2Offset; // kg per year
  final double price;

  TreeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.co2Offset,
    required this.price,
  });

  TreeModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    double? co2Offset,
    double? price,
  }) {
    return TreeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      co2Offset: co2Offset ?? this.co2Offset,
      price: price ?? this.price,
    );
  }

  factory TreeModel.fromJson(Map<String, dynamic> json) {
    return TreeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      co2Offset: (json['co2Offset'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'co2Offset': co2Offset,
      'price': price,
    };
  }
}

// Sample Data
final List<TreeModel> availableTrees = [
  TreeModel(
    id: 't1',
    name: 'Neem Tree',
    description:
        'Known as the natural air purifier. Fast-growing and highly beneficial for the environment.',
    imageUrl:
        'https://images.unsplash.com/photo-1542273917363-3b1817f69a2d?auto=format&fit=crop&w=500&q=80',
    co2Offset: 20.0,
    price: 150.0,
  ),
  TreeModel(
    id: 't2',
    name: 'Banyan Tree',
    description:
        'The national tree of India. Provides massive shade and supports a large ecosystem.',
    imageUrl:
        'https://images.unsplash.com/photo-1502082553048-f009c37129b9?auto=format&fit=crop&w=500&q=80',
    co2Offset: 35.0,
    price: 250.0,
  ),
  TreeModel(
    id: 't3',
    name: 'Mango Tree',
    description:
        'Provides delicious fruits and dense shade. A favorite among communities.',
    imageUrl:
        'https://images.unsplash.com/photo-1605553531998-380652750eeb?auto=format&fit=crop&w=500&q=80',
    co2Offset: 15.0,
    price: 200.0,
  ),
];
