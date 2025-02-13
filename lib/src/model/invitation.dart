class InvitationCode {
  String email, code;
  InvitationCode({required this.email, required this.code});

  static const collection = "invitation", emailKey = "email", codeKey = "code";

  static InvitationCode? fromDocSnapshot(Map<String, dynamic>? data) {
    if(data == null) return null;

    return InvitationCode(
      email: data[emailKey],
      code: data[codeKey],
      );
  }
}