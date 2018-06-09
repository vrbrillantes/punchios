import 'util_account.dart';
class ItemProfile {
  String photo;
  String name;
  String email;
  String userKey;

  ItemProfile.create(this.name, this.email, this.photo, this.userKey);
  ItemProfile.saveCredentials(c) {
    this.name = c.currentUser.displayName;
    this.email = c.currentUser.email;
    this.photo = c.currentUser.photoUrl;
    this.userKey = AccountUtils.getUserKey(c.currentUser.email);
  }
}