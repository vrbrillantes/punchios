class ItemProfile {
  String photo;
  String name;
  String email;

  ItemProfile.create(this.name, this.email, this.photo);
  ItemProfile.saveCredentials(c) {
    this.name = c.currentUser.displayName;
    this.email = c.currentUser.email;
    this.photo = c.currentUser.photoUrl;
  }
}