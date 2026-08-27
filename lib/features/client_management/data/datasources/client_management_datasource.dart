import '../models/trainer_client_model.dart';

abstract class ClientManagementDatasource {
  Future<List<TrainerClientModel>> getClients();
  Future<TrainerClientModel> addClient(TrainerClientModel client);
  Future<TrainerClientModel> updateClient(TrainerClientModel client);
  Future<void> deleteClient(String clientId);
  Future<void> toggleClientActiveStatus(String clientId);
}
