// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $appStartupRoute,
      $onboardingRoute,
      $homeRoute,
      $loginRoute,
      $forgotPasswordRoute,
      $verifyResetCodeRoute,
      $chooseRoleRoute,
      $permissionsRoute,
      $languageSettingsRoute,
      $userProfileRoute,
      $paymentMethodsRoute,
      $changePasswordRoute,
      $twoFactorAuthRoute,
      $startPageRoute,
      $promoterHomeRoute,
      $advertiserHomeRoute,
      $advertiserSecuritySettingsRoute,
      $createCampaignRoute,
      $campaignDetailsRoute,
    ];

RouteBase get $appStartupRoute => GoRouteData.$route(
      path: '/',
      factory: _$AppStartupRoute._fromState,
    );

mixin _$AppStartupRoute on GoRouteData {
  static AppStartupRoute _fromState(GoRouterState state) =>
      const AppStartupRoute();

  @override
  String get location => GoRouteData.$location(
        '/',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $onboardingRoute => GoRouteData.$route(
      path: '/onboarding',
      factory: _$OnboardingRoute._fromState,
    );

mixin _$OnboardingRoute on GoRouteData {
  static OnboardingRoute _fromState(GoRouterState state) =>
      const OnboardingRoute();

  @override
  String get location => GoRouteData.$location(
        '/onboarding',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $homeRoute => GoRouteData.$route(
      path: '/home',
      factory: _$HomeRoute._fromState,
    );

mixin _$HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  @override
  String get location => GoRouteData.$location(
        '/home',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $loginRoute => GoRouteData.$route(
      path: '/login',
      factory: _$LoginRoute._fromState,
    );

mixin _$LoginRoute on GoRouteData {
  static LoginRoute _fromState(GoRouterState state) => LoginRoute(
        role: _$convertMapValue(
            'role', state.uri.queryParameters, _$UserRoleEnumMap._$fromName),
      );

  LoginRoute get _self => this as LoginRoute;

  @override
  String get location => GoRouteData.$location(
        '/login',
        queryParams: {
          if (_self.role != null) 'role': _$UserRoleEnumMap[_self.role!],
        },
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

const _$UserRoleEnumMap = {
  UserRole.promoter: 'promoter',
  UserRole.advertiser: 'advertiser',
};

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}

extension<T extends Enum> on Map<T, String> {
  T? _$fromName(String? value) =>
      entries.where((element) => element.value == value).firstOrNull?.key;
}

RouteBase get $forgotPasswordRoute => GoRouteData.$route(
      path: '/forgot-password',
      factory: _$ForgotPasswordRoute._fromState,
    );

mixin _$ForgotPasswordRoute on GoRouteData {
  static ForgotPasswordRoute _fromState(GoRouterState state) =>
      const ForgotPasswordRoute();

  @override
  String get location => GoRouteData.$location(
        '/forgot-password',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $verifyResetCodeRoute => GoRouteData.$route(
      path: '/verify-reset-code',
      factory: _$VerifyResetCodeRoute._fromState,
    );

mixin _$VerifyResetCodeRoute on GoRouteData {
  static VerifyResetCodeRoute _fromState(GoRouterState state) =>
      VerifyResetCodeRoute(
        email: state.uri.queryParameters['email']!,
      );

  VerifyResetCodeRoute get _self => this as VerifyResetCodeRoute;

  @override
  String get location => GoRouteData.$location(
        '/verify-reset-code',
        queryParams: {
          'email': _self.email,
        },
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $chooseRoleRoute => GoRouteData.$route(
      path: '/choose-role',
      factory: _$ChooseRoleRoute._fromState,
    );

mixin _$ChooseRoleRoute on GoRouteData {
  static ChooseRoleRoute _fromState(GoRouterState state) =>
      const ChooseRoleRoute();

  @override
  String get location => GoRouteData.$location(
        '/choose-role',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $permissionsRoute => GoRouteData.$route(
      path: '/permissions',
      factory: _$PermissionsRoute._fromState,
    );

mixin _$PermissionsRoute on GoRouteData {
  static PermissionsRoute _fromState(GoRouterState state) =>
      const PermissionsRoute();

  @override
  String get location => GoRouteData.$location(
        '/permissions',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $languageSettingsRoute => GoRouteData.$route(
      path: '/language-settings',
      factory: _$LanguageSettingsRoute._fromState,
    );

mixin _$LanguageSettingsRoute on GoRouteData {
  static LanguageSettingsRoute _fromState(GoRouterState state) =>
      const LanguageSettingsRoute();

  @override
  String get location => GoRouteData.$location(
        '/language-settings',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $userProfileRoute => GoRouteData.$route(
      path: '/user-profile',
      factory: _$UserProfileRoute._fromState,
    );

mixin _$UserProfileRoute on GoRouteData {
  static UserProfileRoute _fromState(GoRouterState state) =>
      const UserProfileRoute();

  @override
  String get location => GoRouteData.$location(
        '/user-profile',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $paymentMethodsRoute => GoRouteData.$route(
      path: '/payment-methods',
      factory: _$PaymentMethodsRoute._fromState,
    );

mixin _$PaymentMethodsRoute on GoRouteData {
  static PaymentMethodsRoute _fromState(GoRouterState state) =>
      const PaymentMethodsRoute();

  @override
  String get location => GoRouteData.$location(
        '/payment-methods',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $changePasswordRoute => GoRouteData.$route(
      path: '/change-password',
      factory: _$ChangePasswordRoute._fromState,
    );

mixin _$ChangePasswordRoute on GoRouteData {
  static ChangePasswordRoute _fromState(GoRouterState state) =>
      const ChangePasswordRoute();

  @override
  String get location => GoRouteData.$location(
        '/change-password',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $twoFactorAuthRoute => GoRouteData.$route(
      path: '/two-factor-auth',
      factory: _$TwoFactorAuthRoute._fromState,
    );

mixin _$TwoFactorAuthRoute on GoRouteData {
  static TwoFactorAuthRoute _fromState(GoRouterState state) =>
      const TwoFactorAuthRoute();

  @override
  String get location => GoRouteData.$location(
        '/two-factor-auth',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $startPageRoute => GoRouteData.$route(
      path: '/start',
      factory: _$StartPageRoute._fromState,
    );

mixin _$StartPageRoute on GoRouteData {
  static StartPageRoute _fromState(GoRouterState state) =>
      const StartPageRoute();

  @override
  String get location => GoRouteData.$location(
        '/start',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $promoterHomeRoute => GoRouteData.$route(
      path: '/promoter-home',
      factory: _$PromoterHomeRoute._fromState,
    );

mixin _$PromoterHomeRoute on GoRouteData {
  static PromoterHomeRoute _fromState(GoRouterState state) =>
      const PromoterHomeRoute();

  @override
  String get location => GoRouteData.$location(
        '/promoter-home',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $advertiserHomeRoute => GoRouteData.$route(
      path: '/advertiser-home',
      factory: _$AdvertiserHomeRoute._fromState,
    );

mixin _$AdvertiserHomeRoute on GoRouteData {
  static AdvertiserHomeRoute _fromState(GoRouterState state) =>
      const AdvertiserHomeRoute();

  @override
  String get location => GoRouteData.$location(
        '/advertiser-home',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $advertiserSecuritySettingsRoute => GoRouteData.$route(
      path: '/advertiser-security-settings',
      factory: _$AdvertiserSecuritySettingsRoute._fromState,
    );

mixin _$AdvertiserSecuritySettingsRoute on GoRouteData {
  static AdvertiserSecuritySettingsRoute _fromState(GoRouterState state) =>
      const AdvertiserSecuritySettingsRoute();

  @override
  String get location => GoRouteData.$location(
        '/advertiser-security-settings',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $createCampaignRoute => GoRouteData.$route(
      path: '/create-campaign',
      factory: _$CreateCampaignRoute._fromState,
    );

mixin _$CreateCampaignRoute on GoRouteData {
  static CreateCampaignRoute _fromState(GoRouterState state) =>
      const CreateCampaignRoute();

  @override
  String get location => GoRouteData.$location(
        '/create-campaign',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $campaignDetailsRoute => GoRouteData.$route(
      path: '/campaign-details/:campaignId',
      factory: _$CampaignDetailsRoute._fromState,
    );

mixin _$CampaignDetailsRoute on GoRouteData {
  static CampaignDetailsRoute _fromState(GoRouterState state) =>
      CampaignDetailsRoute(
        campaignId: state.pathParameters['campaignId']!,
      );

  CampaignDetailsRoute get _self => this as CampaignDetailsRoute;

  @override
  String get location => GoRouteData.$location(
        '/campaign-details/${Uri.encodeComponent(_self.campaignId)}',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
