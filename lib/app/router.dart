import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/auth_screens.dart';
import '../features/groups/groups_feature.dart';
import '../features/home/home_feature.dart';
import '../features/kyc/kyc_feature.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/wallet/wallet_feature.dart';
import '../features/wheel/wheel_feature.dart';

class AppRouter {
  static GoRouter create(AuthController authController) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: authController,
      redirect: (context, state) {
        if (!authController.isReady) return null;

        const publicRoutes = {
          '/splash',
          '/onboarding',
          '/login',
          '/signup',
          '/forgot-password',
          '/verify-otp',
          '/new-password',
          '/reset-password',
        };

        final loc = state.matchedLocation;
        final isPublic = publicRoutes.any((r) => loc.startsWith(r));
        final isAuthenticated = authController.isAuthenticated;

        if (!isAuthenticated && !isPublic) return '/login';
        if (isAuthenticated && (loc == '/login' || loc == '/signup')) return '/home';
        return null;
      },
      routes: [
        // ── Public ──
        GoRoute(
          path: '/splash',
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (_, __) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (_, __) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/verify-otp',
          builder: (context, state) => OtpVerificationScreen(
            prefilledEmail: state.uri.queryParameters['email'],
          ),
        ),
        GoRoute(
          path: '/new-password',
          builder: (context, state) => NewPasswordScreen(
            prefilledEmail: state.uri.queryParameters['email'],
            prefilledOtp: state.uri.queryParameters['otp'],
          ),
        ),
        GoRoute(
          path: '/reset-password',
          builder: (context, state) => OtpVerificationScreen(
            prefilledEmail: state.uri.queryParameters['email'],
          ),
        ),

        // ── KYC ──
        GoRoute(
          path: '/kyc',
          builder: (_, __) => const IdentityVerificationScreen(),
        ),
        GoRoute(
          path: '/kyc/personal-info',
          builder: (_, __) => const KycPersonalInfoScreen(),
        ),
        GoRoute(
          path: '/kyc/document',
          builder: (_, __) => const KycDocumentScreen(),
        ),
        GoRoute(
          path: '/kyc/upload-id',
          builder: (_, __) => const KycUploadIdScreen(),
        ),
        GoRoute(
          path: '/kyc/face',
          builder: (_, __) => const KycFaceVerificationScreen(),
        ),
        GoRoute(
          path: '/kyc/complete',
          builder: (_, __) => const KycFaceCompleteScreen(),
        ),
        GoRoute(
          path: '/kyc/review',
          builder: (_, __) => const KycReviewScreen(),
        ),
        GoRoute(
          path: '/kyc/verified',
          builder: (_, __) => const KycVerifiedScreen(),
        ),

        // ── Main Tabs ──
        GoRoute(
          path: '/home',
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (_, __) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/groups',
          builder: (_, __) => const GroupsScreen(),
        ),
        GoRoute(
          path: '/groups/create',
          builder: (_, __) => const CreateGroupScreen(),
        ),
        GoRoute(
          path: '/groups/created',
          builder: (_, __) => const GroupCreatedScreen(),
        ),
        GoRoute(
          path: '/groups/enter-code',
          builder: (_, __) => const EnterCodeScreen(),
        ),
        GoRoute(
          path: '/groups/:id',
          builder: (context, state) => GroupDetailScreen(
            groupId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/wallet',
          builder: (_, __) => const WalletScreen(),
        ),
        GoRoute(
          path: '/wheel',
          builder: (_, __) => const WheelScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (_, __) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/profile/personal-info',
          builder: (_, __) => const PersonalInfoScreen(),
        ),
        GoRoute(
          path: '/profile/password',
          builder: (_, __) => const PasswordSecurityScreen(),
        ),
        GoRoute(
          path: '/profile/payments',
          builder: (_, __) => const PaymentMethodsScreen(),
        ),
        GoRoute(
          path: '/profile/privacy',
          builder: (_, __) => const PrivacyPolicyScreen(),
        ),
        GoRoute(
          path: '/profile/terms',
          builder: (_, __) => const TermsConditionsScreen(),
        ),

        // ── Support (legacy contact admin) ──
        GoRoute(
          path: '/support/new',
          builder: (_, __) => const ContactAdminScreen(),
        ),
      ],
    );
  }
}
