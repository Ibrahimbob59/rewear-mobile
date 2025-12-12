class Charity {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? description;
  final String? logo;
  final bool isVerified;
  final int totalDonationsReceived;
  final int peopleHelped;
  final DateTime? createdAt;

  Charity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.description,
    this.logo,
    required this.isVerified,
    required this.totalDonationsReceived,
    required this.peopleHelped,
    this.createdAt,
  });

  factory Charity.fromJson(Map<String, dynamic> json) {
    return Charity(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      description: json['description'],
      logo: json['logo'],
      isVerified: json['is_verified'] ?? false,
      totalDonationsReceived: json['total_donations_received'] ?? 0,
      peopleHelped: json['people_helped'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }
}

class DonatedItem {
  final int id;
  final int itemId;
  final int? charityId;
  final String status;
  final String itemTitle;
  final String? itemImage;
  final String donorName;
  final String? charityName;
  final DateTime donatedAt;
  final DateTime? acceptedAt;

  DonatedItem({
    required this.id,
    required this.itemId,
    this.charityId,
    required this.status,
    required this.itemTitle,
    this.itemImage,
    required this.donorName,
    this.charityName,
    required this.donatedAt,
    this.acceptedAt,
  });

  factory DonatedItem.fromJson(Map<String, dynamic> json) {
    return DonatedItem(
      id: json['id'] ?? 0,
      itemId: json['item_id'] ?? 0,
      charityId: json['charity_id'],
      status: json['status'] ?? 'pending',
      itemTitle: json['item_title'] ?? '',
      itemImage: json['item_image'],
      donorName: json['donor_name'] ?? '',
      charityName: json['charity_name'],
      donatedAt: DateTime.parse(json['donated_at']),
      acceptedAt: json['accepted_at'] != null 
          ? DateTime.parse(json['accepted_at']) 
          : null,
    );
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
}