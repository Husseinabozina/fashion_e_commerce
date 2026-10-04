class ShoppingPreferences {
  const ShoppingPreferences({
    required this.hasCompletedOnboarding,
    this.interests = const <String>{},
  });

  const ShoppingPreferences.initial()
      : hasCompletedOnboarding = false,
        interests = const <String>{};

  final bool hasCompletedOnboarding;
  final Set<String> interests;
}
