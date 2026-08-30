import '../models/trainer_client_model.dart';

abstract class ClientManagementDatasource {
  Stream<List<TrainerClientModel>> watchClients({String? trainerId});
  Future<List<TrainerClientModel>> getClients({String? trainerId});
  Future<TrainerClientModel> addClient(TrainerClientModel client, {String? trainerId});
  Future<TrainerClientModel> updateClient(TrainerClientModel client, {String? trainerId});
  Future<void> updateNotes(String clientId, String notes, {String? trainerId});
  Future<void> deleteClient(String clientId, {String? trainerId});
  Future<void> toggleClientActiveStatus(String clientId, {String? trainerId});
}
