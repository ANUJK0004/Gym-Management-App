class Gym {
  const Gym({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    this.address,
    this.phone,
    this.email,
    this.logoUrl,
    this.createdAt,
  });

  final String id;
  final String ownerId;

  final String name;

  final String? description;
  final String? address;
  final String? phone;
  final String? email;

  final String? logoUrl;

  final DateTime? createdAt;
}