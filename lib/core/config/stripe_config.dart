class StripeConfig {
  StripeConfig._();

  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue:
        'pk_test_51S6pMbRZVOYD6qjBukBi2VyPiTtIhzAyYzmfyAo4izzIwemOo7I3fUYELhxmTJeNln7zMiztFA4CKihsybqrJlo800nWzvIXZY',
  );

  static const String merchantIdentifier = String.fromEnvironment(
    'STRIPE_MERCHANT_IDENTIFIER',
    defaultValue: 'merchant.com.ematony.ajofamily',
  );
}
