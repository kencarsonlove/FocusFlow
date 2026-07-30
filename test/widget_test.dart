import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:focusflow/main.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    focusFlowDarkMode.value = false;
    focusFlowOnboardingDone.value = false;
    focusFlowUserEmail.value = '';
    focusFlowAccountEmail.value = '';
    focusFlowFirebaseReady.value = false;
    focusFlowUserName.value = 'Focus Builder';
    focusFlowProfileIcon.value = 'person';
    focusFlowSchoolName.value = '';
    focusFlowClassSchedule.value = [];
    focusFlowTutorialCompleted.value = false;
    focusFlowTutorialReplayRequests.value = 0;
  });

  test('validates real-looking email addresses', () {
    expect(isValidFocusFlowEmail('person@example.com'), isTrue);
    expect(isValidFocusFlowEmail('hello'), isFalse);
    expect(isValidFocusFlowEmail('person@'), isFalse);
    expect(isValidFocusFlowEmail('person@example'), isFalse);
    expect(isValidFocusFlowEmail('person @example.com'), isFalse);
  });

  testWidgets('shows onboarding before signup is complete', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FocusFlowApp());

    expect(find.text('Welcome to FocusFlow'), findsOneWidget);
    expect(
      find.text('A faster way to run your school day.'),
      findsOneWidget,
    );
  });

  testWidgets('shows Firebase signup before entering the app', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FocusFlowApp());

    await tester.tap(find.text('Start Setup'));
    await tester.pumpAndSettle();
    expect(find.text('What school are you focused at?'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Central High');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(focusFlowSchoolName.value, 'Central High');

    await tester.tap(find.text('Skip For Now'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).at(0),
      'person@example.com',
    );
    await tester.enterText(
      find.byType(TextField).at(1),
      'password123',
    );

    expect(find.text('Create Account'), findsOneWidget);
    expect(focusFlowOnboardingDone.value, isFalse);
  });

  testWidgets('shows Firebase verification-code login', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      'focusFlowAccountEmail': 'person@example.com',
      'focusFlowAccountPassword': 'password123',
    });

    await tester.pumpWidget(const FocusFlowApp());

    await tester.tap(find.text('Start Setup'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Central High');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip For Now'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Already have an account? Log in'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).at(0),
      'person@example.com',
    );
    await tester.enterText(
      find.byType(TextField).at(1),
      'password123',
    );

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Send Verification Code'), findsOneWidget);
    expect(focusFlowOnboardingDone.value, isFalse);
  });

  test('firebase account creation falls back locally when unconfigured',
      () async {
    focusFlowFirebaseReady.value = false;

    await createFocusFlowFirebaseAccount(
      email: 'person@example.com',
      password: 'password123',
    );

    expect(focusFlowOnboardingDone.value, isTrue);
    expect(focusFlowUserEmail.value, 'person@example.com');
    expect(focusFlowAccountEmail.value, 'person@example.com');
  });

  test('login code sender requires Firebase configuration', () async {
    focusFlowFirebaseReady.value = false;

    expect(
      sendFocusFlowFirebaseLoginCode(
        email: 'person@example.com',
        code: '123456',
      ),
      throwsA(isA<FocusFlowEmailDeliveryException>()),
    );
  });
}
