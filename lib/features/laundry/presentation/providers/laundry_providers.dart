
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/features/laundry/data/repositories/laundry_repository_impl.dart';
import 'package:myapp/features/laundry/domain/entities/laundry_machine.dart';
import 'package:myapp/features/laundry/domain/repositories/laundry_repository.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final laundryRepositoryProvider = Provider<LaundryRepository>((ref) {
  return LaundryRepositoryImpl(ref.watch(firestoreProvider));
});

final laundryMachinesProvider = StreamProvider<List<LaundryMachine>>((ref) {
  return ref.watch(laundryRepositoryProvider).getLaundryMachines();
});
