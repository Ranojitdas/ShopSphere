import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class FetchUserProfileUseCase {
  final AuthRepository repository;

  const FetchUserProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() => repository.fetchUserProfile();
}
