class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final Map<String, dynamic>? meta;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.meta,
  });

  factory ApiResponse.success(T data, {String? message, Map<String, dynamic>? meta}) {
    return ApiResponse(success: true, data: data, message: message, meta: meta);
  }

  factory ApiResponse.failure(String error) {
    return ApiResponse(success: false, error: error);
  }
}
