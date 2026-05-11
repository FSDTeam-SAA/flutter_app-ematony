import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/widgets/ajo_chrome.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/screens/forgot_password_screens.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/groups/groups_repository.dart';
import '../features/groups/groups_screen.dart';
import '../features/home/home_screen.dart';
import '../features/kyc/kyc_screens.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/wallet/wallet_screen.dart';
import '../features/wheel/wheel_feature.dart';

class AppRouter {
  static GoRouter create(AuthController authController) {
    // ── Performance Optimization ──
    // The router should only refresh when auth state changes (logged in/out/ready),
    // NOT when the loading state (isBusy) changes. 
    // This prevents unnecessary re-evaluations and "flashing" during auth flows.
    final routerListenable = _AuthRouterListenable(authController);

    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: routerListenable,
      redirect: (context, state) {
        // ── Wait for bootstrap to finish ──
        if (!authController.isReady) return null;

        final loc = state.matchedLocation;

        // Routes that are always accessible (no auth required)
        const alwaysPublic = {
          '/splash',
          '/onboarding',
          '/login',
          '/signup',
          '/forgot-password',
          '/terms',
          '/privacy',
        };
        // Routes accessible mid-password-reset flow (public but path-prefixed)
        final isPasswordResetRoute =
            loc.startsWith('/verify-otp') ||
            loc.startsWith('/reset-password') ||
            loc.startsWith('/new-password');

        final isPublic =
            alwaysPublic.any((r) => loc.startsWith(r)) || isPasswordResetRoute;
        final isKycRoute = loc.startsWith('/kyc');
        final isAuthenticated = authController.isAuthenticated;
        final isVerified = authController.isKycVerified;

        // Leave the splash route as soon as bootstrap completes.
        //
        // Important: an authenticated-but-NOT-verified user that's restored
        // from disk on cold start is treated as logged-out here. Bootstrap
        // clears that session (see AuthController.bootstrap) so cold restarts
        // always land on Login unless KYC was actually completed.
        if (loc == '/splash') {
          if (!isAuthenticated) {
            return authController.hasSeenOnboarding ? '/login' : '/onboarding';
          }
          return isVerified ? '/home' : '/kyc';
        }

        // Block returning to onboarding once it's been seen and the user
        // is unauthenticated — send them straight to login.
        if (loc == '/onboarding' &&
            !isAuthenticated &&
            authController.hasSeenOnboarding) {
          return '/login';
        }

        // ── Rule 1: Not logged in — send to login (except public routes) ──
        if (!isAuthenticated && !isPublic && !isKycRoute) {
          return '/login';
        }

        // ── Rule 2: Logged in but not KYC verified ──
        // Auth pages (/login, /signup) and the marketing onboarding screen
        // shouldn't be shown to a user who is mid-KYC — bounce them to the
        // KYC flow. They can still complete it from any /kyc/* route.
        if (isAuthenticated && !isVerified) {
          if (isKycRoute) return null;
          if (loc == '/login' || loc == '/signup' || loc == '/onboarding') {
            return '/kyc';
          }
          if (!isPublic) return '/kyc';
        }

        // ── Rule 3: Logged in AND verified — redirect away from auth pages ──
        if (isAuthenticated && isVerified) {
          if (loc == '/login' ||
              loc == '/signup' ||
              loc == '/onboarding' ||
              loc == '/splash') {
            return '/home';
          }
        }

        return null;
      },
      routes: [
        // ─────────────────────────────────────────────────────────────────
        // Public routes
        // ─────────────────────────────────────────────────────────────────
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
        // Public legal pages — accessible before login/signup so prospective
        // users can read them before creating an account.
        GoRoute(
          path: '/terms',
          builder: (_, _) => const TermsConditionsScreen(),
        ),
        GoRoute(
          path: '/privacy',
          builder: (_, _) => const PrivacyPolicyScreen(),
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

        // ─────────────────────────────────────────────────────────────────
        // KYC (requires login, does NOT require prior KYC completion)
        // ─────────────────────────────────────────────────────────────────
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

        // ─────────────────────────────────────────────────────────────────
        // Main tabs — persistent shell (requires auth + KYC)
        // ─────────────────────────────────────────────────────────────────
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
                  path: '/wheel',
                  builder: (_, _) => const WheelScreen(),
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

        // ─────────────────────────────────────────────────────────────────
        // Sub-screens (no bottom nav bar, require auth)
        // ─────────────────────────────────────────────────────────────────
        GoRoute(
          path: '/notifications',
          builder: (_, _) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/transactions',
          builder: (_, _) => const TransactionHistoryScreen(),
        ),
        GoRoute(
          path: '/wheel/winner',
          builder: (context, state) => WinnerCongratulationsScreen(
            winnerName:
                state.uri.queryParameters['name'] ?? 'Ajo Family Member',
            amount: state.uri.queryParameters['amount'] ?? '₦25,000',
          ),
        ),

        // ── Groups sub-screens ──
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

        // ── Profile sub-screens ──
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

        // ── Support ──
        GoRoute(
          path: '/support/new',
          builder: (_, _) => const ContactAdminScreen(),
        ),
      ],
    );
  }
}

/// A specialized listenable that filters [AuthController] updates.
/// It only notifies the router when auth-relevant state changes,
/// preventing "auto-reload" jitters when isBusy or other transient
/// UI state changes in the controller.
class _AuthRouterListenable extends ChangeNotifier {
  _AuthRouterListenable(this._authController) {
    _authController.addListener(_handleUpdate);
    _lastIsAuthenticated = _authController.isAuthenticated;
    _lastIsReady = _authController.isReady;
    _lastIsVerified = _authController.isKycVerified;
    _lastHasSeenOnboarding = _authController.hasSeenOnboarding;
  }

  final AuthController _authController;
  late bool _lastIsAuthenticated;
  late bool _lastIsReady;
  late bool _lastIsVerified;
  late bool _lastHasSeenOnboarding;

  void _handleUpdate() {
    final newIsAuthenticated = _authController.isAuthenticated;
    final newIsReady = _authController.isReady;
    final newIsVerified = _authController.isKycVerified;
    final newHasSeenOnboarding = _authController.hasSeenOnboarding;

    if (newIsAuthenticated != _lastIsAuthenticated ||
        newIsReady != _lastIsReady ||
        newIsVerified != _lastIsVerified ||
        newHasSeenOnboarding != _lastHasSeenOnboarding) {
      _lastIsAuthenticated = newIsAuthenticated;
      _lastIsReady = newIsReady;
      _lastIsVerified = newIsVerified;
      _lastHasSeenOnboarding = newHasSeenOnboarding;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authController.removeListener(_handleUpdate);
    super.dispose();
  }
}
