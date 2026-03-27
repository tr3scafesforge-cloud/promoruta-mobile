import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:promoruta/main.dart';
import 'package:promoruta/shared/providers/providers.dart';
import 'package:promoruta/shared/services/push_notification_service.dart';

class MockPushNotificationService extends Mock
    implements PushNotificationService {}

void main() {
  testWidgets('App builds with ProviderScope', (WidgetTester tester) async {
    final mockPushNotificationService = MockPushNotificationService();
    when(() => mockPushNotificationService.initialize())
        .thenAnswer((_) async {});
    when(() => mockPushNotificationService.registerCurrentToken())
        .thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pushNotificationServiceProvider
              .overrideWithValue(mockPushNotificationService),
        ],
        child: const PromorutaApp(),
      ),
    );

    expect(find.byType(PromorutaApp), findsOneWidget);
  });
}
