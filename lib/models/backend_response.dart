class RegisterResponse {
  final String token;
  final int userId;
  final String role;

  const RegisterResponse({
    required this.token,
    required this.userId,
    required this.role,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      token: json['token'] as String,
      userId: json['user_id'] as int,
      role: json['role'] as String,
    );
  }
}

class QrCodeResponse {
  final String qrUrl;
  final int expireSeconds;

  const QrCodeResponse({
    required this.qrUrl,
    required this.expireSeconds,
  });

  factory QrCodeResponse.fromJson(Map<String, dynamic> json) {
    return QrCodeResponse(
      qrUrl: json['qr_url'] as String? ?? '',
      expireSeconds: json['expire_seconds'] as int? ?? 300,
    );
  }
}

class AuthStatusResponse {
  final String? status;
  final String? token;
  final int? userId;

  const AuthStatusResponse({
    this.status,
    this.token,
    this.userId,
  });

  factory AuthStatusResponse.fromJson(Map<String, dynamic> json) {
    return AuthStatusResponse(
      status: json['status'] as String?,
      token: json['token'] as String?,
      userId: json['user_id'] as int?,
    );
  }
}
