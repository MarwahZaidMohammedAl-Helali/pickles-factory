class Restaurant {
  final String id;
  final String name;
  final double? balance;
  final String? photoUrl;

  Restaurant({
    required this.id,
    required this.name,
    this.balance,
    this.photoUrl,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      balance: json['balance'] != null ? (json['balance'] as num).toDouble() : null,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (balance != null) 'balance': balance,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }
}
