import 'dart:io';
import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/members/data/models/user_membership.dart';

abstract class UserRepositoryAbstract {
  Future<List<BiuxUser>> getUsers(int limit, int offset);
  Future<bool> login(String biuxUser, String password);
  Future<List<BiuxUser>> getUsernames();
  Future uploadPhoto(String id, File filePhoto);
  Future uploadProfileCover(String id, File fileProfileCover);
  Future sendEmail(String user);
  Future<BiuxUser> getPerson(String nUsername);
  Future<BiuxUser> getUser(String username);
  Future<BiuxUser> getValidationEmails(String email);
  Future<bool> getValidationUserName(String userName);
  Future<BiuxUser> getValidationFacebook(String facebook);
  Future<BiuxUser> updateUser(BiuxUser user);
  Future<UserMembership> getMembershipPerson(String id);
  Future<List<UserMembership>> getMembershipList();
  Future<UserMembership> getMembership(UserMembership userMembership);
}
