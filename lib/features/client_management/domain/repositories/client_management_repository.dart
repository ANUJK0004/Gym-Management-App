import '../entities/trainer_client.dart';

abstract class ClientManagementRepository {
  Future<List<TrainerClient>> getClients();
  Future<TrainerClient> addClient(TrainerClient client);
  Future<TrainerClient> updateClient(TrainerClient client);
  Future<void> deleteClient(String clientId);
  Future<void> toggleClientActiveStatus(String clientId);
}
