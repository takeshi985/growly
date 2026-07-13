import 'package:shared_preferences/shared_preferences.dart';

enum DeviceRole { child, parent }

class DeviceSetup {
  const DeviceSetup({this.role, this.childId, this.pairedChildId});

  final DeviceRole? role;
  final int? childId;
  final int? pairedChildId;
}

class DevicePreferences {
  static const _roleKey = 'selected_role';
  static const _childIdKey = 'child_id';
  static const _pairedChildIdKey = 'paired_child_id';

  Future<DeviceSetup> load() async {
    final prefs = await SharedPreferences.getInstance();
    return DeviceSetup(
      role: switch (prefs.getString(_roleKey)) {
        'child' => DeviceRole.child,
        'parent' => DeviceRole.parent,
        _ => null,
      },
      childId: prefs.getInt(_childIdKey),
      pairedChildId: prefs.getInt(_pairedChildIdKey),
    );
  }

  Future<void> saveRole(DeviceRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role.name);
  }

  Future<void> saveChildId(int childId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_childIdKey, childId);
  }

  Future<void> savePairedChildId(int childId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pairedChildIdKey, childId);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleKey);
    await prefs.remove(_childIdKey);
    await prefs.remove(_pairedChildIdKey);
  }
}
