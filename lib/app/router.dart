import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/widgets/ajo_chrome.dart';
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
        final isKycRoute = loc.startsWith('/kyc');
        final isVerified = authController.isKycVerified;

        if (!isAuthenticated && !isPublic) return '/login';
        if (isAuthenticated &&
            !isVerified &&
            !isKycRoute &&
            loc != '/onboarding' &&
            loc != '/splash') {
          return '/onboarding';
        }
        if (isAuthenticated &&
            isVerified &&
            (loc == '/login' || loc == '/signup' || loc == '/onboarding')) {
          return '/home';
        }
        if (isAuthenticated &&
            !isVerified &&
            (loc == '/login' || loc == '/signup')) {
          return '/onboarding';
        }
        return null;
      },
      routes: [
        // ── Public ──
        GoRoute(
          path: '/splash',
          builder: (_, _) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (_, _) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (_, _) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (_, _) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (_, _) => const ForgotPasswordScreen(),
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
          builder: (_, _) => const IdentityVerificationScreen(),
        ),
        GoRoute(
          path: '/kyc/personal-info',
          builder: (_, _) => const KycPersonalInfoScreen(),
        ),
        GoRoute(
          path: '/kyc/document',
          builder: (_, _) => const KycDocumentScreen(),
        ),
        GoRoute(
          path: '/kyc/upload-id',
          builder: (_, _) => const KycUploadIdScreen(),
        ),
        GoRoute(
          path: '/kyc/upload-front',
          builder: (_, _) => const KycUploadFrontScreen(),
        ),
        GoRoute(
          path: '/kyc/upload-back',
          builder: (_, _) => const KycUploadBackScreen(),
        ),
        GoRoute(
          path: '/kyc/document-review',
          builder: (_, _) => const KycDocumentReviewScreen(),
        ),
        GoRoute(
          path: '/kyc/face',
          builder: (_, _) => const KycFaceStartScreen(),
        ),
        GoRoute(
          path: '/kyc/face/capture',
          builder: (_, _) => const KycFaceVerificationScreen(),
        ),
        GoRoute(
          path: '/kyc/under-review',
          builder: (_, _) => const KycReviewScreen(),
        ),
        GoRoute(
          path: '/kyc/complete',
          builder: (_, _) => const KycFaceCompleteScreen(),
        ),
        GoRoute(
          path: '/kyc/verified',
          builder: (_, _) => const KycVerifiedScreen(),
        ),

        // ── Main Tabs (persistent shell with animated transitions) ──
        StatefulShellRoute(
          navigatorContainerBuilder: (context, navigationShell, children) =>
              AnimatedBranchContainer(
                currentIndex: navigationShell.currentIndex,
                children: children,
              ),
          builder: (context, state, navigationShell) =>
              MainShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (_, _) => const HomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/groups',
                  builder: (_, _) => const GroupsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/wallet',
                  builder: (_, _) => const WalletScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (_, _) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),

        // ── Sub-routes (outside shell — no nav bar) ──
        GoRoute(
          path: '/notifications',
          builder: (_, _) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/groups/create',
          builder: (_, _) => const CreateGroupScreen(),
        ),
        GoRoute(
          path: '/groups/created',
          builder: (_, _) => const GroupCreatedScreen(),
        ),
        GoRoute(
          path: '/groups/enter-code',
          builder: (_, _) => const EnterCodeScreen(),
        ),
        GoRoute(
          path: '/groups/:id',
          builder: (context, state) => Provider.value(
            value: context.read<GroupsRepository>(),
            child: GroupDetailScreen(
              groupId: state.pathParameters['id']!,
            ),
          ),
        ),
        GoRoute(
          path: '/transactions',
          builder: (_, _) => const TransactionHistoryScreen(),
        ),
        GoRoute(
          path: '/wheel',
          builder: (_, _) => const WheelScreen(),
        ),
        GoRoute(
          path: '/wheel/winner',
          builder: (context, state) => WinnerCongratulationsScreen(
            winnerName:
                state.uri.queryParameters['name'] ?? 'Ajo Family Member',
            amount: state.uri.queryParameters['amount'] ?? '₦25,000',
          ),
        ),
        GoRoute(
          path: '/profile/personal-info',
          builder: (_, _) => const PersonalInfoScreen(),
        ),
        GoRoute(
          path: '/profile/password',
          builder: (_, _) => const PasswordSecurityScreen(),
        ),
        GoRoute(
          path: '/profile/payments',
          builder: (_, _) => const PaymentMethodsScreen(),
        ),
        GoRoute(
          path: '/profile/privacy',
          builder: (_, _) => const PrivacyPolicyScreen(),
        ),
        GoRoute(
          path: '/profile/terms',
          builder: (_, _) => const TermsConditionsScreen(),
        ),

        // ── Support (legacy contact admin) ──
        GoRoute(
          path: '/support/new',
          builder: (_, _) => const ContactAdminScreen(),
        ),
      ],
    );
  }
}
