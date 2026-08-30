import '../../domain/entities/trainer_client.dart';
import '../../domain/repositories/client_management_repository.dart';
import '../datasources/client_management_datasource.dart';
import '../models/trainer_client_model.dart';

class ClientManagementRepositoryImpl implements ClientManagementRepository {
  ClientManagementRepositoryImpl(this._datasource);

  final ClientManagementDatasource _datasource;

  @override
  Stream<List<TrainerClient>> watchClients({String? trainerId}) {
    return _datasource
        .watchClients(trainerId: trainerId)
        .map((models) => models.map((m) => m.toDomain()).toList());
  }

  @override
  Future<List<TrainerClient>> getClients({String? trainerId}) async {
    final models = await _datasource.getClients(trainerId: trainerId);
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<TrainerClient> addClient(
    TrainerClient client, {
    String? trainerId,
  }) async {
    final model = TrainerClientModel.fromDomain(client);
    final saved = await _datasource.addClient(model, trainerId: trainerId);
    return saved.toDomain();
  }

  @override
  Future<TrainerClient> updateClient(
    TrainerClient client, {
    String? trainerId,
  }) async {
    final model = TrainerClientModel.fromDomain(client);
    final updated = await _datasource.updateClient(model, trainerId: trainerId);
    return updated.toDomain();
  }

  @override
  Future<void> updateNotes(
    String clientId,
    String notes, {
    String? trainerId,
  }) async {
    await _datasource.updateNotes(clientId, notes, trainerId: trainerId);
  }

  @override
  Future<void> deleteClient(String clientId, {String? trainerId}) async {
    await _datasource.deleteClient(clientId, trainerId: trainerId);
  }

  @override
  Future<void> toggleClientActiveStatus(
    String clientId, {
    String? trainerId,
  }) async {
    await _datasource.toggleClientActiveStatus(clientId, trainerId: trainerId);
  }
}
