import 'dart:typed_data';
import '../repositories/profile_repository.dart';

class GetAvatarUseCase {
  final ProfileRepository repo;
  GetAvatarUseCase(this.repo);

  Future<Uint8List?> call() => repo.getAvatarBytes();
}
