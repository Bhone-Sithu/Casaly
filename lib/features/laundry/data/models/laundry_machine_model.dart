
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/features/laundry/domain/entities/laundry_machine.dart';
import 'package:myapp/features/laundry/domain/entities/laundry_machine_status.dart';
import 'package:myapp/features/laundry/domain/entities/laundry_machine_type.dart';

class LaundryMachineModel extends LaundryMachine {
  LaundryMachineModel({
    required super.id,
    required super.name,
    required super.type,
    required super.status,
    super.estimatedCompletionTime,
  });

  factory LaundryMachineModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LaundryMachineModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: LaundryMachineType.values.firstWhere((e) => e.toString() == data['type'], orElse: () => LaundryMachineType.washer),
      status: LaundryMachineStatus.values.firstWhere((e) => e.toString() == data['status'], orElse: () => LaundryMachineStatus.available),
      estimatedCompletionTime: data['estimatedCompletionTime']?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type.toString(),
      'status': status.toString(),
      'estimatedCompletionTime': estimatedCompletionTime,
    };
  }
}
