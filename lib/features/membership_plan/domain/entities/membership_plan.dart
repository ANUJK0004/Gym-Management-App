class MembershipPlan {
  const MembershipPlan({
    required this.id,
    required this.gymId,
    required this.name,
    required this.price,
    required this.durationInDays,
    this.description,
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String gymId;

  final String name;
  final double price;
  final int durationInDays;

  final String? description;

  final bool isActive;

  final DateTime? createdAt;

  MembershipPlan copyWith({
    String? id,
    String? gymId,
    String? name,
    double? price,
    int? durationInDays,
    String? description,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return MembershipPlan(
      id: id ?? this.id,
      gymId: gymId ?? this.gymId,
      name: name ?? this.name,
      price: price ?? this.price,
      durationInDays:
      durationInDays ?? this.durationInDays,
      description:
      description ?? this.description,
      isActive:
      isActive ?? this.isActive,
      createdAt:
      createdAt ?? this.createdAt,
    );
  }
}