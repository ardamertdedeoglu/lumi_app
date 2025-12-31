class UserModel {
  final String id;
  final String name;
  final String? profileImageUrl;
  final bool hasNotification;

  const UserModel({
    required this.id,
    required this.name,
    this.profileImageUrl,
    this.hasNotification = false,
  });

  // Demo user for testing
  static const UserModel demo = UserModel(
    id: '1',
    name: 'Zeynep Yılmaz',
    hasNotification: true,
  );
}
