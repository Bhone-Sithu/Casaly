
import 'package:myapp/features/laundry/domain/entities/laundry_machine_status.dart';
import 'package:myapp/features/laundry/domain/entities/laundry_machine_type.dart';

class LaundryMachine {
  final String id;
  final String name;
  final LaundryMachineType type;
  final LaundryMachineStatus status;
  final DateTime? estimatedCompletionTime;

  LaundryMachine({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.estimatedCompletionTime,
  });
}
