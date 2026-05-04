import 'package:flutter/widgets.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'app/app.dart';
import 'core/config/stripe_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = StripeConfig.publishableKey;
  if (StripeConfig.merchantIdentifier.isNotEmpty) {
    Stripe.merchantIdentifier = StripeConfig.merchantIdentifier;
  }
  await Stripe.instance.applySettings();
  runApp(const EmatonyApp());
}
