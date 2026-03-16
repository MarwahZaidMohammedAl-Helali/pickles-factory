class Transaction {
  final String id;
  final String restaurantId;
  final String productId;
  final String? productName; // Optional, for display
  final double? productPrice; // Optional, for display
  final DateTime deliveryDate; // When jars were delivered
  final DateTime? returnDate; // When jars were returned (optional)
  final int jarsDelivered; // Jars given to restaurant
  final int jarsReturned; // Jars returned by restaurant
  final int jarsUsed; // Calculated: delivered - returned
  final bool isCompleted; // Has returns been added?

  Transaction({
    required this.id,
    required this.restaurantId,
    required this.productId,
    this.productName,
    this.productPrice,
    required this.deliveryDate,
    this.returnDate,
    required this.jarsDelivered,
    this.jarsReturned = 0,
    int? jarsUsed,
    this.isCompleted = false,
  }) : jarsUsed = jarsUsed ?? (jarsDelivered - jarsReturned);

  // Legacy support for old API
  int get jarsSold => jarsDelivered;
  DateTime get date => deliveryDate;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final deliveryDate = json['deliveryDate'] != null 
        ? DateTime.parse(json['deliveryDate'] as String)
        : DateTime.parse(json['date'] as String); // Fallback to old field
    
    final returnDate = json['returnDate'] != null
        ? DateTime.parse(json['returnDate'] as String)
        : null;

    final jarsDelivered = (json['jarsDelivered'] ?? json['jarsSold'] ?? 0) as int;
    final jarsReturned = (json['jarsReturned'] ?? 0) as int;

    return Transaction(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String?,
      productPrice: json['productPrice'] != null 
          ? (json['productPrice'] as num).toDouble()
          : null,
      deliveryDate: deliveryDate,
      returnDate: returnDate,
      jarsDelivered: jarsDelivered,
      jarsReturned: jarsReturned,
      jarsUsed: (json['jarsUsed'] ?? (jarsDelivered - jarsReturned)) as int,
      isCompleted: json['isCompleted'] as bool? ?? (jarsReturned > 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'productId': productId,
      'deliveryDate': deliveryDate.toIso8601String(),
      if (returnDate != null) 'returnDate': returnDate!.toIso8601String(),
      'jarsDelivered': jarsDelivered,
      'jarsReturned': jarsReturned,
      'jarsUsed': jarsUsed,
      'isCompleted': isCompleted,
      // Legacy fields for backward compatibility
      'date': deliveryDate.toIso8601String(),
      'jarsSold': jarsDelivered,
    };
  }

  // Create a copy with updated fields
  Transaction copyWith({
    String? id,
    String? restaurantId,
    String? productId,
    String? productName,
    double? productPrice,
    DateTime? deliveryDate,
    DateTime? returnDate,
    int? jarsDelivered,
    int? jarsReturned,
    int? jarsUsed,
    bool? isCompleted,
  }) {
    return Transaction(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      returnDate: returnDate ?? this.returnDate,
      jarsDelivered: jarsDelivered ?? this.jarsDelivered,
      jarsReturned: jarsReturned ?? this.jarsReturned,
      jarsUsed: jarsUsed ?? this.jarsUsed,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
