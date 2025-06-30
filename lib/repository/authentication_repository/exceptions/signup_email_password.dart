class SignupWithEmailAndPasswordFailure implements Exception {
  final String message;

  const SignupWithEmailAndPasswordFailure(
      [this.message = 'An Unknown error occured.']);

  factory SignupWithEmailAndPasswordFailure.code(String code) {
    switch (code) {
      case 'email-already-in-use':
        return const SignupWithEmailAndPasswordFailure(
            'The email is already in use by another account.');
      case 'invalid-email':
        return const SignupWithEmailAndPasswordFailure(
            'The email address is badly formatted.');
      case 'operation-not-allowed':
        return const SignupWithEmailAndPasswordFailure(
            'Email & Password accounts are not enabled.');
      case 'weak-password':
        return const SignupWithEmailAndPasswordFailure(
            'The password is too weak.');
      default:
        return const SignupWithEmailAndPasswordFailure();
    }
  }
}
