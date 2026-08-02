import '../datasources/gym_remote_datasource.dart';
import '../models/gym_model.dart';

import '../../domain/entities/gym.dart';
import '../../domain/repositories/gym_repository.dart';

class GymRepositoryImpl
    implements GymRepository {
  GymRepositoryImpl(
      this._dataSource,
      );

  final GymRemoteDataSource _dataSource;

  @override
  Future<Gym> createGym(
      Gym gym,
      ) {
    final model = GymModel(
      id: gym.id,
      ownerId: gym.ownerId,
      name: gym.name,
      description: gym.description,
      address: gym.address,
      phone: gym.phone,
      email: gym.email,
      logoUrl: gym.logoUrl,
      createdAt: gym.createdAt,
    );

    return _dataSource.createGym(
      model,
    );
  }

  @override
  Future<Gym?> getGym(
      String gymId,
      ) {
    return _dataSource.getGym(
      gymId,
    );
  }

  @override
  Future<Gym?> getGymByOwnerId(
      String ownerId,
      ) {
    return _dataSource.getGymByOwnerId(
      ownerId,
    );
  }

  @override
  Future<void> updateGym(
      Gym gym,
      ) {
    final model = GymModel(
      id: gym.id,
      ownerId: gym.ownerId,
      name: gym.name,
      description: gym.description,
      address: gym.address,
      phone: gym.phone,
      email: gym.email,
      logoUrl: gym.logoUrl,
      createdAt: gym.createdAt,
    );

    return _dataSource.updateGym(
      model,
    );
  }

  @override
  Future<void> deleteGym(
      String gymId,
      ) {
    return _dataSource.deleteGym(
      gymId,
    );
  }
}