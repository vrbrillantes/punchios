class AccountUtils {
  static String getUserKey(String email) {
    String userKey = email.replaceAll("@", "");
    userKey = userKey.replaceAll(".", "");
    userKey = userKey.replaceAll("-", "");
    userKey = userKey.replaceAll("_", "");

    return userKey;
  }
}