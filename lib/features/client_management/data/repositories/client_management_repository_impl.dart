import '../../domain/entities/trainer_client.dart';
import '../../domain/repositories/client_management_repository.dart';
import '../datasources/client_management_datasource.dart';
import '../models/trainer_client_model.dart';

class ClientManagementRepositoryImpl implements ClientManagementRepository {
  ClientManagementRepositoryImpl(this._datasource);

  final ClientManagementDatasource _datasource;

  @override
  Future<List<TrainerClient>> getClients() async {
    final models = await _datasource.getClients();
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<TrainerClient> addClient(TrainerClient client) async {
    final model = TrainerClientModel.fromDomain(client);
    final saved = await _datasource.addClient(model);
    return saved.toDomain();
  }

  @override
  Future<TrainerClient> updateClient(TrainerClient client) async {
    final model = TrainerClientModel.fromDomain(client);
    final updated = await _datasource.updateClient(model);
    return updated.toDomain();
  }

  @override
  Future<void> deleteClient(String clientId) async {
    await _datasource.deleteClient(clientId);
  }

  @override
  Future<void> toggleClientActiveStatus(String clientId) async {
    await _datasource.toggleClientActiveStatus(clientId);
  }
}
