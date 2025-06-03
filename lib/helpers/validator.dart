class Validator {
  static checkEmail(email) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern.toString());
    if (!regex.hasMatch(email)) {
      return 'Please enter a valid email address';
    } else {
      return null;
    }
  }

  static validateEmail(String email) {
    if (email.isEmpty) {
      return 'Please provide your email';
    } else {
      return checkEmail(email);
    }
  }
}
