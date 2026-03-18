
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/features/laundry/data/models/laundry_machine_model.dart';
import 'package:myapp/features/laundry/domain/entities/laundry_machine.dart';
import 'package:myapp/features/laundry/domain/repositories/laundry_repository.dart';

class LaundryRepositoryImpl implements LaundryRepository {
  final FirebaseFirestore firestore;

  LaundryRepositoryImpl(this.firestore);

  @override
  Stream<List<LaundryMachine>> getLaundryMachines() {
    return firestore.collection('laundry_machines').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => LaundryMachineModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> updateLaundryMachineStatus(String id, String status) {
    return firestore.collection('laundry_machines').doc(id).update({'status': status});
  }
}
