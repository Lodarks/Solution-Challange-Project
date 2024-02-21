import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../repository/auth_repository.dart';

final authControllerProvider = Provider((ref) {
  return AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  );
});

final class AuthController {
  final AuthRepository authRepository;
  final ProviderRef ref;

  AuthController({required this.authRepository, required this.ref});

  Future<void> signUpWithEmail(
      String email, String password, BuildContext context) async {
    ref
        .read(authRepositoryProvider)
        .signUpWithEmail(email: email, password: password, context: context);
  }

  Future<void> loginWithEmail(
      String email, String password, BuildContext context) async {
    ref
        .read(authRepositoryProvider)
        .loginWithEmail(email: email, password: password, context: context);
  }
}
