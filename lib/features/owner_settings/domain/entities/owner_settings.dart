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
    this.pushNotifications = true,
    this.autoRenew = true,
    this.darkMode = true,
    this.maintenanceMode = false,
    this.lastBackupAt,
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
  final bool pushNotifications;
  final bool autoRenew;
  final bool darkMode;
  final bool maintenanceMode;
  final DateTime? lastBackupAt;

  String get operatingHoursDisplay {
    if (operatingHours != null && operatingHours!.isNotEmpty) {
      if (operatingHours!.containsKey('display') &&
          operatingHours!['display']!.isNotEmpty) {
        return operatingHours!['display']!;
      }
      if (operatingHours!.containsKey('weekdays') &&
          operatingHours!['weekdays']!.isNotEmpty) {
        return operatingHours!['weekdays']!;
      }
      return operatingHours!.values.first;
    }
    return '5:00 AM - 11:00 PM';
  }

  OwnerSettings copyWith({
    String? gymId,
    String? ownerId,
    String? gymName,
    String? address,
    String? phone,
    String? website,
    String? logoUrl,
    Map<String, String>? operatingHours,
    bool? isVerified,
    bool? pushNotifications,
    bool? autoRenew,
    bool? darkMode,
    bool? maintenanceMode,
    DateTime? lastBackupAt,
  }) {
    return OwnerSettings(
      gymId: gymId ?? this.gymId,
      ownerId: ownerId ?? this.ownerId,
      gymName: gymName ?? this.gymName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      operatingHours: operatingHours ?? this.operatingHours,
      isVerified: isVerified ?? this.isVerified,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      autoRenew: autoRenew ?? this.autoRenew,
      darkMode: darkMode ?? this.darkMode,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
    );
  }
}