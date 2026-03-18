
import 'package:myapp/features/laundry/domain/entities/laundry_machine.dart';

abstract class LaundryRepository {
  Stream<List<LaundryMachine>> getLaundryMachines();
  Future<void> updateLaundryMachineStatus(String id, String status);
}
