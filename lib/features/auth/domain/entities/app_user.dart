class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.isGuest,
  });

  const AppUser.guest()
      : id = 'guest',
        name = 'Guest',
        email = '',
        isGuest = true;

  final String id;
  final String name;
  final String email;
  final bool isGuest;
}
