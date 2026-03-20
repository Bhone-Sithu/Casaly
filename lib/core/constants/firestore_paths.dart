abstract class FirestorePaths {
  static const users = 'users';
  static const dorms = 'dorms';
  static const members = 'members';
  static const cleaningGroups = 'cleaningGroups';
  static const cleaningSchedule = 'cleaningSchedule';
  static const cleaningSwaps = 'cleaningSwaps';
  static const washingMachines = 'washingMachines'; // Legacy - kept for compatibility
  static const laundryMachines = 'laundry_machines';
  static const shoppingList = 'shoppingList';

  static String dormMembers(String dormId) => '$dorms/$dormId/$members';
  static String dormSchedule(String dormId) => '$dorms/$dormId/$cleaningSchedule';
  static String dormMachines(String dormId) => '$dorms/$dormId/$washingMachines'; // Legacy
  static String dormLaundryMachines(String dormId) => '$dorms/$dormId/$laundryMachines';
  static String dormGroups(String dormId) => '$dorms/$dormId/$cleaningGroups';
  static String dormSwaps(String dormId) => '$dorms/$dormId/$cleaningSwaps';
}