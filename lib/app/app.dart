import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../core/storage/session_storage.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/auth_repository.dart';
import '../features/groups/groups_controller.dart';
import '../features/groups/groups_repository.dart';
import '../features/home/home_controller.dart';
import '../features/home/home_repository.dart';
import '../features/notifications/notifications_controller.dart';
import '../features/notifications/notifications_repository.dart';
import '../features/profile/profile_controller.dart';
import '../features/profile/profile_repository.dart';
import '../features/wallet/wallet_controller.dart';
import '../features/wallet/wallet_repository.dart';
import 'router.dart';

class EmatonyApp extends StatelessWidget {
  const EmatonyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ── Core ──
        Provider(create: (_) => SessionStorage()),
        Provider(
          create: (ctx) =>
              ApiClient(sessionStorage: ctx.read<SessionStorage>()),
        ),

        // ── Auth ──
        Provider(
          create: (ctx) => AuthRepository(
            apiClient: ctx.read<ApiClient>(),
            sessionStorage: ctx.read<SessionStorage>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => AuthController(
            repository: ctx.read<AuthRepository>(),
          )..bootstrap(),
        ),

        // ── Home ──
        Provider(
          create: (ctx) =>
              HomeRepository(apiClient: ctx.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              HomeController(repository: ctx.read<HomeRepository>()),
        ),

        // ── Groups ──
        Provider(
          create: (ctx) =>
              GroupsRepository(apiClient: ctx.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              GroupsController(repository: ctx.read<GroupsRepository>()),
        ),

        // ── Wallet ──
        Provider(
          create: (ctx) =>
              WalletRepository(apiClient: ctx.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              WalletController(repository: ctx.read<WalletRepository>()),
        ),

        // ── Profile ──
        Provider(
          create: (ctx) =>
              ProfileRepository(apiClient: ctx.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              ProfileController(repository: ctx.read<ProfileRepository>()),
        ),

        // ── Notifications ──
        Provider(
          create: (ctx) =>
              NotificationsRepository(apiClient: ctx.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => NotificationsController(
              repository: ctx.read<NotificationsRepository>()),
        ),
      ],
      child: Builder(
        builder: (ctx) {
          final authController = ctx.watch<AuthController>();
          return MaterialApp.router(
            title: 'Ajo Family',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.create(authController),
          );
        },
      ),
    );
  }
}
