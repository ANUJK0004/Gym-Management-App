import '../entities/trainer_client.dart';

abstract class ClientManagementRepository {
  Stream<List<TrainerClient>> watchClients({String? trainerId});
  Future<List<TrainerClient>> getClients({String? trainerId});
  Future<TrainerClient> addClient(TrainerClient client, {String? trainerId});
  Future<TrainerClient> updateClient(TrainerClient client, {String? trainerId});
  Future<void> updateNotes(String clientId, String notes, {String? trainerId});
  Future<void> deleteClient(String clientId, {String? trainerId});
  Future<void> toggleClientActiveStatus(String clientId, {String? trainerId});
}
