import 'package:fashion_e_commerce/features/auth/data/datasources/in_memory_auth_data_source.dart';
import 'package:fashion_e_commerce/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('auth starts as guest and can sign in and out', () async {
    final repository = AuthRepositoryImpl(InMemoryAuthDataSource());

    final guest = await repository.getCurrentUser();
    expect(guest.isGuest, isTrue);

    final member = await repository.signIn(
      email: 'hussein@example.com',
      password: '1234',
    );
    expect(member.isGuest, isFalse);
    expect(member.email, 'hussein@example.com');

    final signedOut = await repository.signOut();
    expect(signedOut.isGuest, isTrue);
  });
}
