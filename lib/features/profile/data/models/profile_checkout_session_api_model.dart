class ProfileCheckoutSessionApiModel {
  final String checkoutUrl;
  final String? sessionId;

  const ProfileCheckoutSessionApiModel({
    required this.checkoutUrl,
    this.sessionId,
  });

  factory ProfileCheckoutSessionApiModel.fromJson(Map<String, dynamic> json) {
    return ProfileCheckoutSessionApiModel(
      checkoutUrl: (json['checkoutUrl'] ?? '').toString(),
      sessionId: json['sessionId']?.toString(),
    );
  }
}
