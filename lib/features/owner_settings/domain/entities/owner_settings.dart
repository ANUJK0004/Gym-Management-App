class OwnerSettings {
  const OwnerSettings({
    required this.gymId,
    required this.ownerId,
    this.gymName,
    this.address,
    this.phone,
    this.website,
    this.logoUrl,
    this.operatingHours,
    this.isVerified = false,
  });

  final String gymId;
  final String ownerId;

  final String? gymName;
  final String? address;
  final String? phone;
  final String? website;
  final String? logoUrl;

  final Map<String, String>? operatingHours;

  final bool isVerified;
}