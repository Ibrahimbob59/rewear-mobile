import 'category_enum.dart';
import 'size_enum.dart';
import 'condition_enum.dart';
import 'gender_enum.dart';
import 'item_status_enum.dart';

class ItemImage {
  final int id;
  final String url;
  final bool isPrimary;

  ItemImage({
    required this.id,
    required this.url,
    required this.isPrimary,
  });

  factory ItemImage.fromJson(Map<String, dynamic> json) {
    return ItemImage(
      id: json['id'] as int,
      url: json['url'] as String,
      isPrimary: json['is_primary'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'is_primary': isPrimary,
    };
  }
}

class ItemSeller {
  final int id;
  final String name;
  final String? city;
  final String? profilePicture;
  final double? latitude;
  final double? longitude;

  ItemSeller({
    required this.id,
    required this.name,
    this.city,
    this.profilePicture,
    this.latitude,
    this.longitude,
  });

  factory ItemSeller.fromJson(Map<String, dynamic> json) {
    return ItemSeller(
      id: json['id'] as int,
      name: json['name'] as String,
      city: json['city'] as String?,
      profilePicture: json['profile_picture'] as String?,
      latitude: json['latitude'] != null 
          ? double.tryParse(json['latitude'].toString()) 
          : null,
      longitude: json['longitude'] != null 
          ? double.tryParse(json['longitude'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'profile_picture': profilePicture,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class Item {
  final int id;
  final String title;
  final String description;
  final Category category;
  final Size size;
  final Condition condition;
  final Gender? gender;
  final String? brand;
  final String? color;
  final double? price;
  final bool isDonation;
  final ItemStatus status;
  final int viewsCount;
  final ItemSeller seller;
  final List<ItemImage> images;
  final double? distanceKm;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.size,
    required this.condition,
    this.gender,
    this.brand,
    this.color,
    this.price,
    required this.isDonation,
    required this.status,
    required this.viewsCount,
    required this.seller,
    required this.images,
    this.distanceKm,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      category: Category.fromString(json['category'] as String),
      size: Size.fromString(json['size'] as String),
      condition: Condition.fromString(json['condition'] as String),
      gender: json['gender'] != null 
          ? Gender.fromString(json['gender'] as String) 
          : null,
      brand: json['brand'] as String?,
      color: json['color'] as String?,
      price: json['price'] != null 
          ? double.tryParse(json['price'].toString()) 
          : null,
      isDonation: json['is_donation'] as bool,
      status: ItemStatus.fromString(json['status'] as String),
      viewsCount: json['views_count'] as int,
      seller: ItemSeller.fromJson(json['seller'] as Map<String, dynamic>),
      images: (json['images'] as List<dynamic>)
          .map((img) => ItemImage.fromJson(img as Map<String, dynamic>))
          .toList(),
      distanceKm: json['distance_km'] != null 
          ? double.tryParse(json['distance_km'].toString()) 
          : null,
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.value,
      'size': size.value,
      'condition': condition.value,
      'gender': gender?.value,
      'brand': brand,
      'color': color,
      'price': price,
      'is_donation': isDonation,
      'status': status.value,
      'views_count': viewsCount,
      'seller': seller.toJson(),
      'images': images.map((img) => img.toJson()).toList(),
      'distance_km': distanceKm,
      'is_favorite': isFavorite,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  String get primaryImageUrl => 
      images.firstWhere((img) => img.isPrimary, orElse: () => images.first).url;

  String get priceDisplay {
    if (isDonation) return 'Free (Donation)';
    if (price == null) return 'N/A';
    return '\$${price!.toStringAsFixed(2)}';
  }

  String get distanceDisplay {
    if (distanceKm == null) return '';
    if (distanceKm! < 1) {
      return '${(distanceKm! * 1000).toStringAsFixed(0)}m away';
    }
    return '${distanceKm!.toStringAsFixed(1)}km away';
  }

  bool get canPurchase => status.canPurchase && !isDonation;
  bool get canEdit => status.canEdit;

  // Copy with method for state updates
  Item copyWith({
    int? id,
    String? title,
    String? description,
    Category? category,
    Size? size,
    Condition? condition,
    Gender? gender,
    String? brand,
    String? color,
    double? price,
    bool? isDonation,
    ItemStatus? status,
    int? viewsCount,
    ItemSeller? seller,
    List<ItemImage>? images,
    double? distanceKm,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      size: size ?? this.size,
      condition: condition ?? this.condition,
      gender: gender ?? this.gender,
      brand: brand ?? this.brand,
      color: color ?? this.color,
      price: price ?? this.price,
      isDonation: isDonation ?? this.isDonation,
      status: status ?? this.status,
      viewsCount: viewsCount ?? this.viewsCount,
      seller: seller ?? this.seller,
      images: images ?? this.images,
      distanceKm: distanceKm ?? this.distanceKm,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}