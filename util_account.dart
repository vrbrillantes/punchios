class AccountUtils {
  static String getUserKey(String email) {
    if (email != null) {
      String userKey = email.replaceAll("@", "");
      userKey = userKey.replaceAll(".", "");
      userKey = userKey.replaceAll("-", "");
      userKey = userKey.replaceAll("_", "");
      return userKey;
    }
    return "";
  }
}