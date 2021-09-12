part of glacier_cli;

class GlacierException implements Exception {
  final String message;

  GlacierException(this.message);
}
