import 'package:biux/data/models/group.dart';

List<Group> groups = [];
Group searchGroupById(id) {
  return groups.firstWhere((place) => place.id == id);
}

List<Group> groupsbyId(id) {
  return groups.where((group) => group.id == id).toList();
}
