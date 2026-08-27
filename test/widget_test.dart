import 'package:flutter_test/flutter_test.dart';
import 'package:sweatsync/features/trainer_profile/data/datasources/trainer_profile_remote_datasource.dart';
import 'package:sweatsync/features/trainer_profile/data/repositories/trainer_profile_repository_impl.dart';

void main() {
  test('Trainer profile repository initial smoke test', () async {
    final datasource = TrainerProfileRemoteDataSource();
    final repository = TrainerProfileRepositoryImpl(datasource);

    final profile = await repository.getProfile(trainerId: 'trainer_001');
    expect(profile.name, equals('Coach Mike Torres'));
    expect(profile.title, equals('Senior Personal Trainer'));
  });
}
