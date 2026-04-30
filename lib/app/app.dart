import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../core/storage/session_storage.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/auth_repository.dart';
import '../features/groups/groups_feature.dart';
import '../features/home/home_feature.dart';
import '../features/wallet/wallet_feature.dart';
import 'router.dart';

class EmatonyApp extends StatelessWidget {
  const EmatonyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => SessionStorage()),
        Provider(
          create: (ctx) => ApiClient(sessionStorage: ctx.read<SessionStorage>()),
        ),
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
        Provider(
          create: (ctx) => HomeRepository(apiClient: ctx.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => HomeController(repository: ctx.read<HomeRepository>()),
        ),
        Provider(
          create: (ctx) => GroupsRepository(apiClient: ctx.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => GroupsController(repository: ctx.read<GroupsRepository>()),
        ),
        Provider(
          create: (ctx) => WalletRepository(apiClient: ctx.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => WalletController(repository: ctx.read<WalletRepository>()),
        ),
      ],
      child: Builder(
        builder: (ctx) {
          final authController = ctx.watch<AuthController>();
          return MaterialApp.router(
            title: 'Ematony',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.create(authController),
          );
        },
      ),
    );
  }
}
