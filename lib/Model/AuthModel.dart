class AuthModel {
  final String? email;
  final String? password;
  final String? token;

  AuthModel({
    this.email,
    this.password,
    this.token,
  });

  /// للإرسال (login / register)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (email != null) data['email'] = email;
    if (password != null) data['password'] = password;
    if (token != null) data['token'] = token;
    return data;
  }

  /// للاستقبال (token)
  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      email: json['email'],
      password: json['password'],
      token: json['token'],
    );
  }
}
