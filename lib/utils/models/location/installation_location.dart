class InstallationLocation {
  final String country;
  final String region;
  final String city;

  final double latitude;
  final double longitude;

  final String timezone;

  const InstallationLocation({
    required this.country,
    required this.region,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });
}