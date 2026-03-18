
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/features/laundry/domain/entities/laundry_machine_status.dart';
import 'package:myapp/features/laundry/domain/entities/laundry_machine_type.dart';

Future<void> main() async {
  await Firebase.initializeApp();
  final firestore = FirebaseFirestore.instance;

  final batch = firestore.batch();

  final laundryMachines = [
    {
      'name': 'Washer 1',
      'type': LaundryMachineType.washer.toString(),
      'status': LaundryMachineStatus.available.toString(),
    },
    {
      'name': 'Washer 2',
      'type': LaundryMachineType.washer.toString(),
      'status': LaundryMachineStatus.inUse.toString(),
      'estimatedCompletionTime': DateTime.now().add(const Duration(minutes: 30)),
    },
    {
      'name': 'Dryer 1',
      'type': LaundryMachineType.dryer.toString(),
      'status': LaundryMachineStatus.outOfOrder.toString(),
    },
    {
      'name': 'Dryer 2',
      'type': LaundryMachineType.dryer.toString(),
      'status': LaundryMachineStatus.available.toString(),
    },
  ];

  for (final machine in laundryMachines) {
    final docRef = firestore.collection('laundry_machines').doc();
    batch.set(docRef, machine);
  }

  await batch.commit();

  print('Sample laundry data added to Firestore.');
}
