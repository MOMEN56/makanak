import 'package:dartz/dartz.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/features/auth/domain/entities/profile_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class AuthOperationResult {
  const AuthOperationResult({
    this.message,
    this.profile,
    this.session,
  });

  final String? message;
  final ProfileEntity? profile;
  final supa.Session? session;
}

abstract class AuthRepo {
  Stream<supa.AuthState> authStateChanges();

  supa.Session? getCurrentSession();

  Future<Either<Failure, AuthOperationResult>> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthOperationResult>> signUpWithEmailPassword({
    required String email,
    required String password,
    String? fullName,
  });

  Future<Either<Failure, AuthOperationResult>> signInWithGoogle();

  Future<Either<Failure, ProfileEntity?>> syncProfileForSession(
    supa.Session session,
  );

  Future<Either<Failure, void>> signOut();
}
