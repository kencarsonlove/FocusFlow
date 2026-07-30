import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri focusFlowStripeDonationUrl = Uri.parse(
  'https://buy.stripe.com/test_dRmcN50aN5Op7IWfmeefC00',
);

final ValueNotifier<bool> focusFlowDarkMode = ValueNotifier<bool>(false);
final ValueNotifier<bool> focusFlowAppBlocking = ValueNotifier<bool>(true);
final ValueNotifier<bool> focusFlowNotifications = ValueNotifier<bool>(true);
final ValueNotifier<String> focusFlowQuickStart =
    ValueNotifier<String>('Pomodoro');
final ValueNotifier<List<String>> focusFlowCompletedTasks =
    ValueNotifier<List<String>>([]);
final ValueNotifier<List<String>> focusFlowTodayTasks =
    ValueNotifier<List<String>>([]);
final ValueNotifier<List<String>> focusFlowSessionHistory =
    ValueNotifier<List<String>>([]);
final ValueNotifier<List<String>> focusFlowCustomTimers =
    ValueNotifier<List<String>>([]);
final ValueNotifier<String> focusFlowPremiumPlan =
    ValueNotifier<String>('Yearly');
final ValueNotifier<bool> focusFlowIsPro = ValueNotifier<bool>(false);
final ValueNotifier<int> focusFlowTotalSessions = ValueNotifier<int>(0);
final ValueNotifier<int> focusFlowTotalFocusMinutes = ValueNotifier<int>(0);
final ValueNotifier<bool> focusFlowOnboardingDone = ValueNotifier<bool>(false);
final ValueNotifier<String> focusFlowUserEmail = ValueNotifier<String>('');
final ValueNotifier<String> focusFlowAccountEmail = ValueNotifier<String>('');
final ValueNotifier<String> focusFlowUserName =
    ValueNotifier<String>('Focus Builder');
final ValueNotifier<String> focusFlowProfileIcon =
    ValueNotifier<String>('person');
final ValueNotifier<int> focusFlowDailyGoalMinutes = ValueNotifier<int>(50);
final ValueNotifier<String> focusFlowSchoolName = ValueNotifier<String>('');
final ValueNotifier<List<String>> focusFlowClassSchedule =
    ValueNotifier<List<String>>([]);
final ValueNotifier<bool> focusFlowTutorialCompleted =
    ValueNotifier<bool>(false);
final ValueNotifier<int> focusFlowTutorialReplayRequests =
    ValueNotifier<int>(0);
final ValueNotifier<int> focusFlowCurrentTab = ValueNotifier<int>(0);
final ValueNotifier<bool> focusFlowFirebaseReady = ValueNotifier<bool>(false);
final GlobalKey<ScaffoldMessengerState> focusFlowScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFocusFlowFirebase();

  final prefs = await SharedPreferences.getInstance();
  focusFlowDarkMode.value = prefs.getBool('focusFlowDarkMode') ?? false;
  focusFlowAppBlocking.value = prefs.getBool('focusFlowAppBlocking') ?? true;
  focusFlowNotifications.value =
      prefs.getBool('focusFlowNotifications') ?? true;
  focusFlowQuickStart.value =
      prefs.getString('focusFlowQuickStart') ?? 'Pomodoro';
  focusFlowCompletedTasks.value =
      prefs.getStringList('focusFlowCompletedTasks') ?? [];
  focusFlowTodayTasks.value =
      prefs.getStringList('focusFlowTodayTasks') ?? defaultFocusFlowTaskData();
  focusFlowSessionHistory.value =
      prefs.getStringList('focusFlowSessionHistory') ?? [];
  focusFlowCustomTimers.value =
      prefs.getStringList('focusFlowCustomTimers') ?? [];
  focusFlowPremiumPlan.value =
      prefs.getString('focusFlowPremiumPlan') ?? 'Yearly';
  focusFlowIsPro.value = prefs.getBool('focusFlowIsPro') ?? false;
  focusFlowTotalSessions.value = prefs.getInt('focusFlowTotalSessions') ?? 0;
  focusFlowTotalFocusMinutes.value =
      prefs.getInt('focusFlowTotalFocusMinutes') ?? 0;
  focusFlowOnboardingDone.value =
      prefs.getBool('focusFlowOnboardingDone') ?? false;
  focusFlowUserEmail.value = prefs.getString('focusFlowUserEmail') ?? '';
  focusFlowAccountEmail.value = prefs.getString('focusFlowAccountEmail') ?? '';
  focusFlowUserName.value =
      prefs.getString('focusFlowUserName') ?? 'Focus Builder';
  focusFlowProfileIcon.value =
      prefs.getString('focusFlowProfileIcon') ?? 'person';
  focusFlowDailyGoalMinutes.value =
      prefs.getInt('focusFlowDailyGoalMinutes') ?? 50;
  focusFlowSchoolName.value = prefs.getString('focusFlowSchoolName') ?? '';
  focusFlowClassSchedule.value =
      prefs.getStringList('focusFlowClassSchedule') ?? [];
  focusFlowTutorialCompleted.value =
      prefs.getBool('focusFlowTutorialCompleted') ?? false;
  if (focusFlowFirebaseReady.value) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      focusFlowUserEmail.value = currentUser.email ?? focusFlowUserEmail.value;
      focusFlowOnboardingDone.value = true;
      await loadFocusFlowCloudData();
    }
  }
  runApp(const FocusFlowApp());
}

Future<void> saveFocusFlowDarkMode(bool value) async {
  focusFlowDarkMode.value = value;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('focusFlowDarkMode', value);
  await saveFocusFlowCloudData();
}

Future<void> saveFocusFlowAppBlocking(bool value) async {
  focusFlowAppBlocking.value = value;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('focusFlowAppBlocking', value);
  await saveFocusFlowCloudData();
}

Future<void> saveFocusFlowNotifications(bool value) async {
  focusFlowNotifications.value = value;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('focusFlowNotifications', value);
  await saveFocusFlowCloudData();
}

Future<void> saveFocusFlowQuickStart(String value) async {
  focusFlowQuickStart.value = value;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('focusFlowQuickStart', value);
  await saveFocusFlowCloudData();
}

Future<void> toggleFocusFlowTask(String taskId) async {
  final currentTasks = List<String>.from(focusFlowCompletedTasks.value);

  if (currentTasks.contains(taskId)) {
    currentTasks.remove(taskId);
  } else {
    currentTasks.add(taskId);
  }

  focusFlowCompletedTasks.value = currentTasks;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('focusFlowCompletedTasks', currentTasks);
  await saveFocusFlowCloudData();
}

Future<void> clearFocusFlowTasks() async {
  focusFlowCompletedTasks.value = [];

  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('focusFlowCompletedTasks', []);
  await saveFocusFlowCloudData();
}

class FocusFlowTaskItem {
  final String id;
  final String title;
  final String subtitle;
  final String priority;
  final int estimateMinutes;

  const FocusFlowTaskItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.priority = 'Medium',
    this.estimateMinutes = 25,
  });

  String encode() => jsonEncode({
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'priority': priority,
        'estimateMinutes': estimateMinutes,
      });

  static FocusFlowTaskItem decode(String value) {
    final decoded = jsonDecode(value);

    if (decoded is Map<String, dynamic>) {
      return FocusFlowTaskItem(
        id: decoded['id']?.toString() ?? focusFlowNewId('task'),
        title: decoded['title']?.toString() ?? 'Untitled task',
        subtitle: decoded['subtitle']?.toString() ?? 'Custom task',
        priority: focusFlowNormalizePriority(decoded['priority']?.toString()),
        estimateMinutes:
            int.tryParse(decoded['estimateMinutes']?.toString() ?? '') ?? 25,
      );
    }

    return FocusFlowTaskItem(
      id: focusFlowNewId('task'),
      title: 'Untitled task',
      subtitle: 'Custom task',
      priority: 'Medium',
      estimateMinutes: 25,
    );
  }
}

class FocusFlowTimerMode {
  final String id;
  final String title;
  final int minutes;
  final IconData icon;

  const FocusFlowTimerMode({
    required this.id,
    required this.title,
    required this.minutes,
    required this.icon,
  });

  String encode() => jsonEncode({
        'id': id,
        'title': title,
        'minutes': minutes,
      });

  static FocusFlowTimerMode decode(String value) {
    final decoded = jsonDecode(value);

    if (decoded is Map<String, dynamic>) {
      return FocusFlowTimerMode(
        id: decoded['id']?.toString() ?? focusFlowNewId('timer'),
        title: decoded['title']?.toString() ?? 'Custom',
        minutes: int.tryParse(decoded['minutes']?.toString() ?? '') ?? 25,
        icon: Icons.tune_rounded,
      );
    }

    return FocusFlowTimerMode(
      id: focusFlowNewId('timer'),
      title: 'Custom',
      minutes: 25,
      icon: Icons.tune_rounded,
    );
  }
}

class FocusFlowSessionEntry {
  final String id;
  final DateTime startedAt;
  final String mode;
  final int minutes;
  final String note;

  const FocusFlowSessionEntry({
    required this.id,
    required this.startedAt,
    required this.mode,
    required this.minutes,
    required this.note,
  });

  String encode() => jsonEncode({
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'mode': mode,
        'minutes': minutes,
        'note': note,
      });

  static FocusFlowSessionEntry decode(String value) {
    final decoded = jsonDecode(value);

    if (decoded is Map<String, dynamic>) {
      return FocusFlowSessionEntry(
        id: decoded['id']?.toString() ?? focusFlowNewId('session'),
        startedAt: DateTime.tryParse(decoded['startedAt']?.toString() ?? '') ??
            DateTime.now(),
        mode: decoded['mode']?.toString() ?? 'Focus',
        minutes: int.tryParse(decoded['minutes']?.toString() ?? '') ?? 0,
        note: decoded['note']?.toString() ?? '',
      );
    }

    return FocusFlowSessionEntry(
      id: focusFlowNewId('session'),
      startedAt: DateTime.now(),
      mode: 'Focus',
      minutes: 0,
      note: '',
    );
  }
}

String focusFlowNewId(String prefix) {
  return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
}

String focusFlowNormalizePriority(String? value) {
  switch (value) {
    case 'High':
    case 'Medium':
    case 'Low':
      return value!;
    default:
      return 'Medium';
  }
}

int focusFlowPriorityScore(String priority) {
  switch (priority) {
    case 'High':
      return 0;
    case 'Medium':
      return 1;
    default:
      return 2;
  }
}

Color focusFlowPriorityColor(String priority) {
  switch (priority) {
    case 'High':
      return const Color(0xFFFF6B6B);
    case 'Medium':
      return const Color(0xFFFFB84D);
    default:
      return const Color(0xFF35C99F);
  }
}

List<String> defaultFocusFlowTaskData() {
  return const [
    FocusFlowTaskItem(
      id: 'finish-ui',
      title: 'Finish FocusFlow UI',
      subtitle: 'Design system and home screen',
      priority: 'High',
      estimateMinutes: 50,
    ),
    FocusFlowTaskItem(
      id: 'deep-work',
      title: 'Deep work session',
      subtitle: 'No social apps until complete',
      priority: 'High',
      estimateMinutes: 25,
    ),
    FocusFlowTaskItem(
      id: 'weekly-goals',
      title: 'Review weekly goals',
      subtitle: 'Plan tomorrow’s focus blocks',
      priority: 'Medium',
      estimateMinutes: 15,
    ),
  ].map((task) => task.encode()).toList();
}

List<FocusFlowTaskItem> focusFlowTasks() {
  return focusFlowTodayTasks.value.map((taskData) {
    try {
      return FocusFlowTaskItem.decode(taskData);
    } catch (_) {
      return FocusFlowTaskItem(
        id: focusFlowNewId('task'),
        title: 'Untitled task',
        subtitle: 'Custom task',
        priority: 'Medium',
        estimateMinutes: 25,
      );
    }
  }).toList()
    ..sort((a, b) {
      final priorityCompare = focusFlowPriorityScore(a.priority)
          .compareTo(focusFlowPriorityScore(b.priority));

      if (priorityCompare != 0) {
        return priorityCompare;
      }

      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
}

Future<void> saveFocusFlowTodayTasks(List<FocusFlowTaskItem> tasks) async {
  final encodedTasks = tasks.map((task) => task.encode()).toList();
  focusFlowTodayTasks.value = encodedTasks;

  final validTaskIds = tasks.map((task) => task.id).toSet();
  final completedTasks = focusFlowCompletedTasks.value
      .where((taskId) => validTaskIds.contains(taskId))
      .toList();
  focusFlowCompletedTasks.value = completedTasks;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('focusFlowTodayTasks', encodedTasks);
  await prefs.setStringList('focusFlowCompletedTasks', completedTasks);
  await saveFocusFlowCloudData();
}

Future<void> addFocusFlowTask(
  String title,
  String subtitle, {
  String priority = 'Medium',
  int estimateMinutes = 25,
}) async {
  final trimmedTitle = title.trim();
  final trimmedSubtitle = subtitle.trim();

  if (trimmedTitle.isEmpty) {
    return;
  }

  final tasks = focusFlowTasks()
    ..add(
      FocusFlowTaskItem(
        id: focusFlowNewId('task'),
        title: trimmedTitle,
        subtitle: trimmedSubtitle.isEmpty ? 'Custom task' : trimmedSubtitle,
        priority: focusFlowNormalizePriority(priority),
        estimateMinutes: estimateMinutes.clamp(5, 240),
      ),
    );

  await saveFocusFlowTodayTasks(tasks);
}

Future<void> updateFocusFlowTask(
  String id,
  String title,
  String subtitle, {
  String priority = 'Medium',
  int estimateMinutes = 25,
}) async {
  final trimmedTitle = title.trim();

  if (trimmedTitle.isEmpty) {
    return;
  }

  final tasks = focusFlowTasks()
      .map(
        (task) => task.id == id
            ? FocusFlowTaskItem(
                id: task.id,
                title: trimmedTitle,
                subtitle: subtitle.trim().isEmpty ? 'Custom task' : subtitle,
                priority: focusFlowNormalizePriority(priority),
                estimateMinutes: estimateMinutes.clamp(5, 240),
              )
            : task,
      )
      .toList();

  await saveFocusFlowTodayTasks(tasks);
}

Future<void> deleteFocusFlowTask(String id) async {
  final tasks = focusFlowTasks().where((task) => task.id != id).toList();
  await saveFocusFlowTodayTasks(tasks);
}

Future<void> resetFocusFlowTodayPlan() async {
  focusFlowTodayTasks.value = defaultFocusFlowTaskData();
  focusFlowCompletedTasks.value = [];

  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('focusFlowTodayTasks', focusFlowTodayTasks.value);
  await prefs.setStringList('focusFlowCompletedTasks', []);
  await saveFocusFlowCloudData();
}

int focusFlowTotalPlannedMinutes() {
  return focusFlowTasks().fold<int>(
    0,
    (total, task) => total + task.estimateMinutes,
  );
}

int focusFlowCompletedPlannedMinutes() {
  final completedIds = focusFlowCompletedTasks.value.toSet();

  return focusFlowTasks()
      .where((task) => completedIds.contains(task.id))
      .fold<int>(0, (total, task) => total + task.estimateMinutes);
}

Future<void> saveFocusFlowPremiumPlan(String value) async {
  focusFlowPremiumPlan.value = value;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('focusFlowPremiumPlan', value);
  await saveFocusFlowCloudData();
}

Future<void> saveFocusFlowIsPro(bool value) async {
  focusFlowIsPro.value = value;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('focusFlowIsPro', value);
  await saveFocusFlowCloudData();
}

Future<void> saveFocusFlowUserName(String value) async {
  final trimmedValue = value.trim();

  if (trimmedValue.isEmpty) {
    return;
  }

  focusFlowUserName.value = trimmedValue;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('focusFlowUserName', trimmedValue);
  await saveFocusFlowCloudData();
}

Future<void> saveFocusFlowProfileIcon(String value) async {
  focusFlowProfileIcon.value = value;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('focusFlowProfileIcon', value);
  await saveFocusFlowCloudData();
}

Future<void> saveFocusFlowDailyGoalMinutes(int value) async {
  focusFlowDailyGoalMinutes.value = value;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('focusFlowDailyGoalMinutes', value);
  await saveFocusFlowCloudData();
}

Future<void> saveFocusFlowSchoolName(String value) async {
  final trimmedValue = value.trim();

  if (trimmedValue.isEmpty) {
    return;
  }

  focusFlowSchoolName.value = trimmedValue;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('focusFlowSchoolName', trimmedValue);
  await saveFocusFlowCloudData();
}

Future<void> saveFocusFlowClassSchedule(List<String> value) async {
  focusFlowClassSchedule.value = value;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('focusFlowClassSchedule', value);
  await saveFocusFlowCloudData();
}

Future<void> saveFocusFlowTutorialCompleted(bool value) async {
  focusFlowTutorialCompleted.value = value;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('focusFlowTutorialCompleted', value);
  await saveFocusFlowCloudData();
}

Future<void> resetFocusFlowProgressData() async {
  focusFlowCompletedTasks.value = [];
  focusFlowTodayTasks.value = defaultFocusFlowTaskData();
  focusFlowSessionHistory.value = [];
  focusFlowCustomTimers.value = [];
  focusFlowTotalSessions.value = 0;
  focusFlowTotalFocusMinutes.value = 0;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('focusFlowCompletedTasks', []);
  await prefs.setStringList('focusFlowTodayTasks', focusFlowTodayTasks.value);
  await prefs.setStringList('focusFlowSessionHistory', []);
  await prefs.setStringList('focusFlowCustomTimers', []);
  await prefs.setInt('focusFlowTotalSessions', 0);
  await prefs.setInt('focusFlowTotalFocusMinutes', 0);
  await saveFocusFlowCloudData();
}

DocumentReference<Map<String, dynamic>>? focusFlowCloudUserDocument() {
  if (!focusFlowFirebaseReady.value) {
    return null;
  }

  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return null;
  }

  return FirebaseFirestore.instance.collection('users').doc(user.uid);
}

Map<String, dynamic> focusFlowCloudData() {
  return {
    'email': focusFlowUserEmail.value,
    'darkMode': focusFlowDarkMode.value,
    'appBlocking': focusFlowAppBlocking.value,
    'notifications': focusFlowNotifications.value,
    'quickStart': focusFlowQuickStart.value,
    'completedTasks': focusFlowCompletedTasks.value,
    'todayTasks': focusFlowTodayTasks.value,
    'sessionHistory': focusFlowSessionHistory.value,
    'customTimers': focusFlowCustomTimers.value,
    'premiumPlan': focusFlowPremiumPlan.value,
    'isPro': focusFlowIsPro.value,
    'totalSessions': focusFlowTotalSessions.value,
    'totalFocusMinutes': focusFlowTotalFocusMinutes.value,
    'userName': focusFlowUserName.value,
    'profileIcon': focusFlowProfileIcon.value,
    'dailyGoalMinutes': focusFlowDailyGoalMinutes.value,
    'schoolName': focusFlowSchoolName.value,
    'classSchedule': focusFlowClassSchedule.value,
    'tutorialCompleted': focusFlowTutorialCompleted.value,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

String focusFlowStringFromCloud(dynamic value, String fallback) {
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }

  return fallback;
}

bool focusFlowBoolFromCloud(dynamic value, bool fallback) {
  return value is bool ? value : fallback;
}

int focusFlowIntFromCloud(dynamic value, int fallback) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return fallback;
}

List<String> focusFlowStringListFromCloud(
  dynamic value,
  List<String> fallback,
) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }

  return fallback;
}

Future<void> persistFocusFlowLocalData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('focusFlowDarkMode', focusFlowDarkMode.value);
  await prefs.setBool('focusFlowAppBlocking', focusFlowAppBlocking.value);
  await prefs.setBool('focusFlowNotifications', focusFlowNotifications.value);
  await prefs.setString('focusFlowQuickStart', focusFlowQuickStart.value);
  await prefs.setStringList(
    'focusFlowCompletedTasks',
    focusFlowCompletedTasks.value,
  );
  await prefs.setStringList('focusFlowTodayTasks', focusFlowTodayTasks.value);
  await prefs.setStringList(
    'focusFlowSessionHistory',
    focusFlowSessionHistory.value,
  );
  await prefs.setStringList(
    'focusFlowCustomTimers',
    focusFlowCustomTimers.value,
  );
  await prefs.setString('focusFlowPremiumPlan', focusFlowPremiumPlan.value);
  await prefs.setBool('focusFlowIsPro', focusFlowIsPro.value);
  await prefs.setInt('focusFlowTotalSessions', focusFlowTotalSessions.value);
  await prefs.setInt(
    'focusFlowTotalFocusMinutes',
    focusFlowTotalFocusMinutes.value,
  );
  await prefs.setBool('focusFlowOnboardingDone', focusFlowOnboardingDone.value);
  await prefs.setString('focusFlowUserEmail', focusFlowUserEmail.value);
  await prefs.setString('focusFlowAccountEmail', focusFlowAccountEmail.value);
  await prefs.setString('focusFlowUserName', focusFlowUserName.value);
  await prefs.setString('focusFlowProfileIcon', focusFlowProfileIcon.value);
  await prefs.setInt(
    'focusFlowDailyGoalMinutes',
    focusFlowDailyGoalMinutes.value,
  );
  await prefs.setString('focusFlowSchoolName', focusFlowSchoolName.value);
  await prefs.setStringList(
    'focusFlowClassSchedule',
    focusFlowClassSchedule.value,
  );
  await prefs.setBool(
    'focusFlowTutorialCompleted',
    focusFlowTutorialCompleted.value,
  );
}

Future<void> loadFocusFlowCloudData() async {
  final document = focusFlowCloudUserDocument();

  if (document == null) {
    return;
  }

  try {
    final snapshot = await document.get();

    if (!snapshot.exists) {
      await saveFocusFlowCloudData();
      return;
    }

    final data = snapshot.data();

    if (data == null) {
      return;
    }

    focusFlowUserEmail.value = focusFlowStringFromCloud(
      data['email'],
      focusFlowUserEmail.value,
    );
    focusFlowDarkMode.value = focusFlowBoolFromCloud(
      data['darkMode'],
      focusFlowDarkMode.value,
    );
    focusFlowAppBlocking.value = focusFlowBoolFromCloud(
      data['appBlocking'],
      focusFlowAppBlocking.value,
    );
    focusFlowNotifications.value = focusFlowBoolFromCloud(
      data['notifications'],
      focusFlowNotifications.value,
    );
    focusFlowQuickStart.value = focusFlowStringFromCloud(
      data['quickStart'],
      focusFlowQuickStart.value,
    );
    focusFlowCompletedTasks.value = focusFlowStringListFromCloud(
      data['completedTasks'],
      focusFlowCompletedTasks.value,
    );
    focusFlowTodayTasks.value = focusFlowStringListFromCloud(
      data['todayTasks'],
      focusFlowTodayTasks.value,
    );
    focusFlowSessionHistory.value = focusFlowStringListFromCloud(
      data['sessionHistory'],
      focusFlowSessionHistory.value,
    );
    focusFlowCustomTimers.value = focusFlowStringListFromCloud(
      data['customTimers'],
      focusFlowCustomTimers.value,
    );
    focusFlowPremiumPlan.value = focusFlowStringFromCloud(
      data['premiumPlan'],
      focusFlowPremiumPlan.value,
    );
    focusFlowIsPro.value = focusFlowBoolFromCloud(
      data['isPro'],
      focusFlowIsPro.value,
    );
    focusFlowTotalSessions.value = focusFlowIntFromCloud(
      data['totalSessions'],
      focusFlowTotalSessions.value,
    );
    focusFlowTotalFocusMinutes.value = focusFlowIntFromCloud(
      data['totalFocusMinutes'],
      focusFlowTotalFocusMinutes.value,
    );
    focusFlowUserName.value = focusFlowStringFromCloud(
      data['userName'],
      focusFlowUserName.value,
    );
    focusFlowProfileIcon.value = focusFlowStringFromCloud(
      data['profileIcon'],
      focusFlowProfileIcon.value,
    );
    focusFlowDailyGoalMinutes.value = focusFlowIntFromCloud(
      data['dailyGoalMinutes'],
      focusFlowDailyGoalMinutes.value,
    );
    focusFlowSchoolName.value = focusFlowStringFromCloud(
      data['schoolName'],
      focusFlowSchoolName.value,
    );
    focusFlowClassSchedule.value = focusFlowStringListFromCloud(
      data['classSchedule'],
      focusFlowClassSchedule.value,
    );
    focusFlowTutorialCompleted.value = focusFlowBoolFromCloud(
      data['tutorialCompleted'],
      focusFlowTutorialCompleted.value,
    );

    focusFlowOnboardingDone.value = true;
    await persistFocusFlowLocalData();
  } catch (_) {
    // Keep the local cached data usable if Firestore is unavailable.
  }
}

Future<void> saveFocusFlowCloudData() async {
  final document = focusFlowCloudUserDocument();

  if (document == null) {
    return;
  }

  try {
    await document.set(focusFlowCloudData(), SetOptions(merge: true));
  } catch (_) {
    // Firestore sync failures should not block the local app experience.
  }
}

Future<void> initializeFocusFlowFirebase() async {
  try {
    await Firebase.initializeApp();
    focusFlowFirebaseReady.value = true;
  } catch (_) {
    focusFlowFirebaseReady.value = false;
  }
}

String focusFlowFirebaseAuthMessage(FirebaseAuthException error) {
  switch (error.code) {
    case 'email-already-in-use':
      return 'That email already has an account. Log in instead.';
    case 'invalid-email':
      return 'Enter a valid email address.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Email or password is incorrect.';
    case 'weak-password':
      return 'Use a stronger password.';
    case 'network-request-failed':
      return 'Network error. Check your connection and try again.';
    default:
      return error.message ?? 'Firebase sign-in failed. Try again.';
  }
}

Future<void> createFocusFlowFirebaseAccount({
  required String email,
  required String password,
}) async {
  if (!focusFlowFirebaseReady.value) {
    await createFocusFlowLocalAccount(email: email, password: password);
    return;
  }

  try {
    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.sendEmailVerification();
  } on FirebaseAuthException catch (error) {
    throw FocusFlowEmailDeliveryException(
      focusFlowFirebaseAuthMessage(error),
    );
  }

  await completeFocusFlowOnboarding(email);
}

String generateFocusFlowLoginCode() {
  return (Random.secure().nextInt(900000) + 100000).toString();
}

Future<void> verifyFocusFlowFirebasePassword({
  required String email,
  required String password,
}) async {
  if (!focusFlowFirebaseReady.value) {
    throw const FocusFlowEmailDeliveryException(
      'Firebase is not configured yet.',
    );
  }

  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  } on FirebaseAuthException catch (error) {
    throw FocusFlowEmailDeliveryException(
      focusFlowFirebaseAuthMessage(error),
    );
  }
}

Future<void> sendFocusFlowFirebaseLoginCode({
  required String email,
  required String code,
}) async {
  if (!focusFlowFirebaseReady.value) {
    throw const FocusFlowEmailDeliveryException(
      'Firebase is not configured yet.',
    );
  }

  final expiresAt = DateTime.now().add(const Duration(minutes: 10));

  try {
    await FirebaseFirestore.instance.collection('mail').add({
      'to': [email],
      'message': {
        'subject': 'Your FocusFlow verification code',
        'text':
            'Your FocusFlow verification code is $code. It expires in 10 minutes.',
        'html': '''
<div style="font-family:Arial,sans-serif;line-height:1.5;color:#111827">
  <h2>Your FocusFlow verification code</h2>
  <p>Use this 6-digit code to finish logging in:</p>
  <p style="font-size:32px;font-weight:700;letter-spacing:6px">$code</p>
  <p>This code expires in 10 minutes.</p>
</div>
''',
      },
      'focusFlow': {
        'type': 'loginVerification',
        'expiresAt': Timestamp.fromDate(expiresAt),
      },
      'createdAt': FieldValue.serverTimestamp(),
    });
  } on FirebaseException catch (error) {
    throw FocusFlowEmailDeliveryException(
      error.message ?? 'Unable to send the verification code with Firebase.',
    );
  }
}

Future<void> completeFocusFlowFirebaseLogin(String email) async {
  await completeFocusFlowOnboarding(email, syncCloud: false);
  await loadFocusFlowCloudData();
}

Future<void> completeFocusFlowOnboarding(
  String email, {
  bool syncCloud = true,
}) async {
  focusFlowUserEmail.value = email;
  focusFlowOnboardingDone.value = true;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('focusFlowUserEmail', email);
  await prefs.setBool('focusFlowOnboardingDone', true);

  if (syncCloud) {
    await saveFocusFlowCloudData();
  }
}

Future<void> createFocusFlowLocalAccount({
  required String email,
  required String password,
}) async {
  focusFlowAccountEmail.value = email;
  focusFlowUserEmail.value = email;
  focusFlowOnboardingDone.value = true;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('focusFlowAccountEmail', email);
  await prefs.setString('focusFlowAccountPassword', password);
  await prefs.setString('focusFlowUserEmail', email);
  await prefs.setBool('focusFlowOnboardingDone', true);
}

Future<void> logoutFocusFlow() async {
  if (focusFlowFirebaseReady.value) {
    await FirebaseAuth.instance.signOut();
  }

  focusFlowOnboardingDone.value = false;
  focusFlowUserEmail.value = '';

  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('focusFlowOnboardingDone', false);
  await prefs.remove('focusFlowUserEmail');
}

List<FocusFlowTimerMode> focusFlowTimerModes() {
  final customModes = focusFlowCustomTimers.value.map((timerData) {
    try {
      return FocusFlowTimerMode.decode(timerData);
    } catch (_) {
      return FocusFlowTimerMode(
        id: focusFlowNewId('timer'),
        title: 'Custom',
        minutes: 25,
        icon: Icons.tune_rounded,
      );
    }
  }).toList();

  return [
    const FocusFlowTimerMode(
      id: 'focus',
      title: 'Focus',
      minutes: 25,
      icon: Icons.bolt_rounded,
    ),
    const FocusFlowTimerMode(
      id: 'break',
      title: 'Break',
      minutes: 5,
      icon: Icons.coffee_rounded,
    ),
    const FocusFlowTimerMode(
      id: 'rest',
      title: 'Rest',
      minutes: 15,
      icon: Icons.nightlight_round,
    ),
    ...customModes,
  ];
}

Future<void> addFocusFlowCustomTimer(String title, int minutes) async {
  final trimmedTitle = title.trim();

  if (trimmedTitle.isEmpty || minutes < 1) {
    return;
  }

  final timers = List<String>.from(focusFlowCustomTimers.value)
    ..add(
      FocusFlowTimerMode(
        id: focusFlowNewId('timer'),
        title: trimmedTitle,
        minutes: minutes.clamp(1, 240),
        icon: Icons.tune_rounded,
      ).encode(),
    );

  focusFlowCustomTimers.value = timers;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('focusFlowCustomTimers', timers);
  await saveFocusFlowCloudData();
}

List<FocusFlowSessionEntry> focusFlowSessions() {
  return focusFlowSessionHistory.value.map((sessionData) {
    try {
      return FocusFlowSessionEntry.decode(sessionData);
    } catch (_) {
      return FocusFlowSessionEntry(
        id: focusFlowNewId('session'),
        startedAt: DateTime.now(),
        mode: 'Focus',
        minutes: 0,
        note: '',
      );
    }
  }).toList()
    ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
}

Future<void> saveFocusFlowCompletedSession(
  int minutes, {
  String mode = 'Focus',
  String note = '',
}) async {
  final session = FocusFlowSessionEntry(
    id: focusFlowNewId('session'),
    startedAt: DateTime.now(),
    mode: mode,
    minutes: minutes,
    note: note.trim(),
  );

  final sessionHistory = [
    session.encode(),
    ...focusFlowSessionHistory.value,
  ].take(50).toList();

  focusFlowSessionHistory.value = sessionHistory;
  focusFlowTotalSessions.value = focusFlowTotalSessions.value + 1;
  focusFlowTotalFocusMinutes.value = focusFlowTotalFocusMinutes.value + minutes;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('focusFlowSessionHistory', sessionHistory);
  await prefs.setInt('focusFlowTotalSessions', focusFlowTotalSessions.value);
  await prefs.setInt(
    'focusFlowTotalFocusMinutes',
    focusFlowTotalFocusMinutes.value,
  );
  await saveFocusFlowCloudData();
}

String focusFlowDayKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

int focusFlowMinutesForDay(DateTime date) {
  final key = focusFlowDayKey(date);

  return focusFlowSessions()
      .where((session) => focusFlowDayKey(session.startedAt) == key)
      .fold<int>(0, (total, session) => total + session.minutes);
}

int focusFlowCurrentStreakDays() {
  final sessionDays = focusFlowSessions()
      .where((session) => session.minutes > 0)
      .map((session) => focusFlowDayKey(session.startedAt))
      .toSet();

  if (sessionDays.isEmpty) {
    return 0;
  }

  var streak = 0;
  var cursor = DateTime.now();

  while (sessionDays.contains(focusFlowDayKey(cursor))) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  return streak;
}

String focusFlowWeekdayLabel(DateTime date) {
  const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  return labels[date.weekday - 1];
}

String formatFocusMinutes(int minutes) {
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;

  if (minutes <= 0) {
    return '0m';
  }

  if (hours == 0) {
    return '${remainingMinutes}m';
  }

  if (remainingMinutes == 0) {
    return '${hours}h';
  }

  return '${hours}h ${remainingMinutes}m';
}

final RegExp focusFlowEmailPattern = RegExp(
  r'^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,63}$',
  caseSensitive: false,
);

class FocusFlowEmailDeliveryException implements Exception {
  final String message;

  const FocusFlowEmailDeliveryException(this.message);
}

bool isValidFocusFlowEmail(String email) {
  final trimmedEmail = email.trim();

  if (trimmedEmail.isEmpty || trimmedEmail.contains(' ')) {
    return false;
  }

  return focusFlowEmailPattern.hasMatch(trimmedEmail);
}

void showFocusFlowGlobalMessage(String message) {
  final messenger = focusFlowScaffoldMessengerKey.currentState;

  if (messenger == null) {
    return;
  }

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
}

Future<void> openFocusFlowStripeDonation() async {
  final didLaunch = await launchUrl(
    focusFlowStripeDonationUrl,
    mode: LaunchMode.externalApplication,
  );

  if (!didLaunch) {
    showFocusFlowGlobalMessage('Unable to open Stripe Checkout.');
  }
}

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: focusFlowDarkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'FocusFlow',
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: focusFlowScaffoldMessengerKey,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF17BEBB),
              brightness: Brightness.light,
              primary: const Color(0xFF2563EB),
              secondary: const Color(0xFF17BEBB),
              tertiary: const Color(0xFFFF8A3D),
              surface: const Color(0xFFFFFFFF),
            ),
            textTheme: GoogleFonts.interTextTheme(),
            scaffoldBackgroundColor: const Color(0xFFF4F7FA),
            snackBarTheme: SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF111827),
              contentTextStyle: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: Color(0xFF17BEBB),
                  width: 1.4,
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF17BEBB),
              brightness: Brightness.dark,
              primary: const Color(0xFF6EA8FF),
              secondary: const Color(0xFF17BEBB),
              tertiary: const Color(0xFFFFA05C),
              surface: const Color(0xFF111827),
            ),
            textTheme: GoogleFonts.interTextTheme(
              ThemeData.dark().textTheme,
            ),
            scaffoldBackgroundColor: const Color(0xFF080B10),
            snackBarTheme: SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFFF8FAFC),
              contentTextStyle: GoogleFonts.inter(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF111827),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFF263244)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFF263244)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: Color(0xFF17BEBB),
                  width: 1.4,
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6EA8FF),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          home: ValueListenableBuilder<bool>(
            valueListenable: focusFlowOnboardingDone,
            builder: (context, onboardingDone, _) {
              if (onboardingDone) {
                return const FocusFlowShell();
              }

              return const FocusFlowOnboarding();
            },
          ),
        );
      },
    );
  }
}

class FocusFlowOnboarding extends StatefulWidget {
  const FocusFlowOnboarding({super.key});

  @override
  State<FocusFlowOnboarding> createState() => _FocusFlowOnboardingState();
}

class _FocusFlowOnboardingState extends State<FocusFlowOnboarding> {
  static const Duration loginCodeLifetime = Duration(minutes: 10);

  int pageIndex = 0;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final codeController = TextEditingController();
  final schoolController = TextEditingController();
  final classNameController = TextEditingController();
  final classTimeController = TextEditingController();

  bool isLoginMode = false;
  bool isSendingAuthEmail = false;
  bool isVerifyingLoginCode = false;
  List<String> onboardingClasses = [];
  String? loginVerificationEmail;
  String? loginVerificationCode;
  DateTime? loginCodeExpiresAt;
  Timer? loginCodeTimer;

  int get loginCodeSecondsRemaining {
    final expiresAt = loginCodeExpiresAt;

    if (expiresAt == null) {
      return 0;
    }

    return max(0, expiresAt.difference(DateTime.now()).inSeconds);
  }

  String get loginCodeTimeLabel {
    final seconds = loginCodeSecondsRemaining;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  bool get loginCodeExpired {
    return loginVerificationCode == null || loginCodeSecondsRemaining == 0;
  }

  @override
  void dispose() {
    loginCodeTimer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    codeController.dispose();
    schoolController.dispose();
    classNameController.dispose();
    classTimeController.dispose();
    super.dispose();
  }

  void nextPage() {
    setState(() {
      pageIndex++;
    });
  }

  Future<void> saveSchoolAndContinue() async {
    final schoolName = schoolController.text.trim();

    if (schoolName.isEmpty) {
      showSignupMessage('Enter your school name.');
      return;
    }

    await saveFocusFlowSchoolName(schoolName);
    nextPage();
  }

  void addOnboardingClass() {
    final className = classNameController.text.trim();
    final classTime = classTimeController.text.trim();

    if (className.isEmpty) {
      showSignupMessage('Enter a class name.');
      return;
    }

    final classLabel =
        classTime.isEmpty ? className : '$className • $classTime';

    setState(() {
      onboardingClasses = [...onboardingClasses, classLabel];
    });

    classNameController.clear();
    classTimeController.clear();
  }

  Future<void> saveClassesAndContinue() async {
    await saveFocusFlowClassSchedule(onboardingClasses);
    nextPage();
  }

  void removeOnboardingClass(String value) {
    setState(() {
      onboardingClasses =
          onboardingClasses.where((classItem) => classItem != value).toList();
    });
  }

  void showSignupMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  void startLoginCodeTimer() {
    loginCodeTimer?.cancel();
    loginCodeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (loginCodeSecondsRemaining == 0) {
        timer.cancel();
      }

      setState(() {});
    });
  }

  Future<void> submitAuthForm() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (!isValidFocusFlowEmail(email)) {
      showSignupMessage('Enter a valid email address.');
      return;
    }

    if (isLoginMode && password.isEmpty) {
      showSignupMessage('Enter your password.');
      return;
    }

    if (!isLoginMode && password.length < 8) {
      showSignupMessage('Use a password with at least 8 characters.');
      return;
    }

    if (isSendingAuthEmail) {
      return;
    }

    setState(() {
      isSendingAuthEmail = true;
    });

    try {
      if (isLoginMode) {
        final code = generateFocusFlowLoginCode();
        await verifyFocusFlowFirebasePassword(
          email: email,
          password: password,
        );
        await sendFocusFlowFirebaseLoginCode(email: email, code: code);
        await FirebaseAuth.instance.signOut();

        if (!mounted) {
          return;
        }

        setState(() {
          loginVerificationEmail = email;
          loginVerificationCode = code;
          loginCodeExpiresAt = DateTime.now().add(loginCodeLifetime);
          isVerifyingLoginCode = true;
          isSendingAuthEmail = false;
        });

        codeController.clear();
        startLoginCodeTimer();

        showSignupMessage('A 6-digit verification code was sent to $email.');
      } else {
        await createFocusFlowFirebaseAccount(
          email: email,
          password: password,
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isSendingAuthEmail = false;
      });

      if (error is FocusFlowEmailDeliveryException) {
        showSignupMessage(error.message);
      } else {
        showSignupMessage('Unable to send the verification code. Try again.');
      }
    }
  }

  Future<void> verifyLoginCode() async {
    final email = loginVerificationEmail;
    final expectedCode = loginVerificationCode;
    final enteredCode = codeController.text.trim();

    if (email == null || expectedCode == null) {
      showSignupMessage('Send a verification code first.');
      return;
    }

    if (loginCodeExpired) {
      showSignupMessage('That code expired. Send a new verification code.');
      return;
    }

    if (enteredCode.length != 6 || enteredCode != expectedCode) {
      showSignupMessage('Enter the 6-digit code sent to $email.');
      return;
    }

    try {
      await verifyFocusFlowFirebasePassword(
        email: email,
        password: passwordController.text.trim(),
      );
      loginCodeTimer?.cancel();
      await completeFocusFlowFirebaseLogin(email);
    } catch (error) {
      if (error is FocusFlowEmailDeliveryException) {
        showSignupMessage(error.message);
      } else {
        showSignupMessage('Unable to finish login. Try again.');
      }
    }
  }

  void toggleAuthMode() {
    loginCodeTimer?.cancel();
    codeController.clear();

    setState(() {
      isLoginMode = !isLoginMode;
      isVerifyingLoginCode = false;
      loginVerificationEmail = null;
      loginVerificationCode = null;
      loginCodeExpiresAt = null;
    });
  }

  void editLoginEmail() {
    loginCodeTimer?.cancel();
    codeController.clear();

    setState(() {
      isVerifyingLoginCode = false;
      loginVerificationEmail = null;
      loginVerificationCode = null;
      loginCodeExpiresAt = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: ffPageGradientColors(isDark),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _FocusFlowAtmosphere()),
            SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                child: switch (pageIndex) {
                  0 => OnboardingInfoPage(
                      key: const ValueKey('intro'),
                      currentIndex: 0,
                      badge: 'Welcome to FocusFlow',
                      title: 'A faster way to run your school day.',
                      subtitle:
                          'FocusFlow turns your classes, homework, timers, and stats into one clean daily command center.',
                      imageIcon: Icons.school_rounded,
                      buttonText: 'Start Setup',
                      onPressed: nextPage,
                    ),
                  1 => OnboardingSchoolPage(
                      key: const ValueKey('school'),
                      schoolController: schoolController,
                      onContinue: saveSchoolAndContinue,
                    ),
                  2 => OnboardingSchedulePage(
                      key: const ValueKey('schedule'),
                      classNameController: classNameController,
                      classTimeController: classTimeController,
                      classes: onboardingClasses,
                      onAddClass: addOnboardingClass,
                      onRemoveClass: removeOnboardingClass,
                      onContinue: saveClassesAndContinue,
                    ),
                  3 => OnboardingDemoPage(
                      key: const ValueKey('demo'),
                      onContinue: nextPage,
                    ),
                  _ => OnboardingSignupPage(
                      key: const ValueKey('signup'),
                      emailController: emailController,
                      passwordController: passwordController,
                      codeController: codeController,
                      isSendingAuthEmail: isSendingAuthEmail,
                      isVerifyingLoginCode: isVerifyingLoginCode,
                      isLoginMode: isLoginMode,
                      verificationEmail: loginVerificationEmail,
                      codeTimeLabel: loginCodeTimeLabel,
                      codeExpired: loginCodeExpired,
                      onSubmit: submitAuthForm,
                      onVerifyCode: verifyLoginCode,
                      onToggleAuthMode: toggleAuthMode,
                      onEditEmail: editLoginEmail,
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingInfoPage extends StatelessWidget {
  final int currentIndex;
  final String badge;
  final String title;
  final String subtitle;
  final IconData imageIcon;
  final String buttonText;
  final VoidCallback onPressed;

  const OnboardingInfoPage({
    super.key,
    required this.currentIndex,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.imageIcon,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingProgressDots(
            currentIndex: currentIndex,
          ),
          const SizedBox(height: 34),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4E7DFF).withOpacity(0.13),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Color(0xFF6F8DFF),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            title,
            style: TextStyle(
              color: ffTitleColor(),
              fontSize: 36,
              height: 1.05,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: TextStyle(
              color: ffSubtitleColor(),
              fontSize: 15,
              height: 1.55,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            height: 290,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: ffBrandGradientColors(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withOpacity(0.20)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF17BEBB).withOpacity(0.28),
                  blurRadius: 38,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -34,
                  top: -34,
                  child: CircleBlob(size: 130),
                ),
                Positioned(
                  left: -28,
                  bottom: -38,
                  child: CircleBlob(size: 120),
                ),
                Center(
                  child: Container(
                    width: 142,
                    height: 142,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.20),
                      ),
                    ),
                    child: Icon(
                      imageIcon,
                      color: Colors.white,
                      size: 78,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withOpacity(0.18)
                          : Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Designed for deep work, daily goals, and fewer distractions.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              height: 1.35,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OnboardingButton(
            text: buttonText,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class OnboardingSchoolPage extends StatelessWidget {
  final TextEditingController schoolController;
  final VoidCallback onContinue;

  const OnboardingSchoolPage({
    super.key,
    required this.schoolController,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingProgressDots(currentIndex: 1),
          const SizedBox(height: 34),
          const OnboardingBadge(
            label: 'School Setup',
            color: Color(0xFF17BEBB),
          ),
          const SizedBox(height: 22),
          Text(
            'What school are you focused at?',
            style: TextStyle(
              color: ffTitleColor(),
              fontSize: 36,
              height: 1.05,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'FocusFlow can shape your daily plan around your actual campus, classes, and study rhythm.',
            style: TextStyle(
              color: ffSubtitleColor(),
              fontSize: 15,
              height: 1.55,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 34),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: cardDecoration(),
            child: OnboardingTextField(
              controller: schoolController,
              hint: 'School name',
              icon: Icons.school_rounded,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => onContinue(),
            ),
          ),
          const SizedBox(height: 22),
          const OnboardingSetupPreview(),
          const SizedBox(height: 28),
          OnboardingButton(
            text: 'Continue',
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}

class OnboardingSchedulePage extends StatelessWidget {
  final TextEditingController classNameController;
  final TextEditingController classTimeController;
  final List<String> classes;
  final VoidCallback onAddClass;
  final ValueChanged<String> onRemoveClass;
  final VoidCallback onContinue;

  const OnboardingSchedulePage({
    super.key,
    required this.classNameController,
    required this.classTimeController,
    required this.classes,
    required this.onAddClass,
    required this.onRemoveClass,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingProgressDots(currentIndex: 4),
          const SizedBox(height: 34),
          const OnboardingBadge(
            label: 'Class Schedule',
            color: Color(0xFFFF8A3D),
          ),
          const SizedBox(height: 22),
          Text(
            'Add the classes in your week.',
            style: TextStyle(
              color: ffTitleColor(),
              fontSize: 36,
              height: 1.05,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Add class names and meeting times so your focus plan knows what your day really looks like.',
            style: TextStyle(
              color: ffSubtitleColor(),
              fontSize: 15,
              height: 1.55,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: cardDecoration(),
            child: Column(
              children: [
                OnboardingTextField(
                  controller: classNameController,
                  hint: 'Class name',
                  icon: Icons.menu_book_rounded,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 14),
                OnboardingTextField(
                  controller: classTimeController,
                  hint: 'Days and time',
                  icon: Icons.schedule_rounded,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onAddClass(),
                ),
                const SizedBox(height: 14),
                FocusFlowSettingsMiniButton(
                  icon: Icons.add_rounded,
                  label: 'Add Class',
                  onTap: onAddClass,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: classes.isEmpty
                ? const OnboardingEmptySchedule()
                : Column(
                    key: ValueKey(classes.length),
                    children: [
                      for (final classItem in classes)
                        OnboardingClassChip(
                          classItem: classItem,
                          onRemove: () => onRemoveClass(classItem),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
          OnboardingButton(
            text: classes.isEmpty ? 'Skip For Now' : 'Save Schedule',
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}

class OnboardingDemoPage extends StatelessWidget {
  final VoidCallback onContinue;

  const OnboardingDemoPage({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingProgressDots(currentIndex: 3),
          const SizedBox(height: 34),
          const OnboardingBadge(
            label: 'Quick Demo',
            color: Color(0xFF2563EB),
          ),
          const SizedBox(height: 22),
          Text(
            'Here is how to use FocusFlow best.',
            style: TextStyle(
              color: ffTitleColor(),
              fontSize: 36,
              height: 1.05,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Start with your classes, turn assignments into tasks, run a timer, then check your stats after each study block.',
            style: TextStyle(
              color: ffSubtitleColor(),
              fontSize: 15,
              height: 1.55,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 28),
          const OnboardingDemoStep(
            icon: Icons.today_rounded,
            title: 'Plan around class',
            subtitle: 'Add homework and study blocks between your classes.',
            accent: Color(0xFF17BEBB),
          ),
          const SizedBox(height: 12),
          const OnboardingDemoStep(
            icon: Icons.timer_rounded,
            title: 'Start a focus session',
            subtitle:
                'Use Pomodoro for quick work or Deep Work for longer assignments.',
            accent: Color(0xFF2563EB),
          ),
          const SizedBox(height: 12),
          const OnboardingDemoStep(
            icon: Icons.bar_chart_rounded,
            title: 'Review your progress',
            subtitle:
                'Check streaks, focus minutes, and what still needs attention.',
            accent: Color(0xFFFF8A3D),
          ),
          const SizedBox(height: 28),
          OnboardingButton(
            text: 'Create Account',
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}

class OnboardingBadge extends StatelessWidget {
  final String label;
  final Color color;

  const OnboardingBadge({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class OnboardingSetupPreview extends StatelessWidget {
  const OnboardingSetupPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: ffBrandGradientColors()),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal study setup',
                  style: TextStyle(
                    color: ffTitleColor(),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your school details help FocusFlow feel built for your actual day.',
                  style: TextStyle(
                    color: ffSubtitleColor(),
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingEmptySchedule extends StatelessWidget {
  const OnboardingEmptySchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('empty-schedule'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Text(
        'Add your classes now, or skip and add them later from settings.',
        style: TextStyle(
          color: ffSubtitleColor(),
          fontSize: 13,
          height: 1.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class OnboardingClassChip extends StatelessWidget {
  final String classItem;
  final VoidCallback onRemove;

  const OnboardingClassChip({
    super.key,
    required this.classItem,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF17BEBB),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              classItem,
              style: TextStyle(
                color: ffTitleColor(),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          PressableScale(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(99),
            child: Icon(
              Icons.close_rounded,
              color: ffSubtitleColor(),
              size: 20,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.04);
  }
}

class OnboardingDemoStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  const OnboardingDemoStep({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: accent, size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: ffTitleColor(),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: ffSubtitleColor(),
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingSignupPage extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController codeController;
  final bool isSendingAuthEmail;
  final bool isVerifyingLoginCode;
  final bool isLoginMode;
  final String? verificationEmail;
  final String codeTimeLabel;
  final bool codeExpired;
  final VoidCallback onSubmit;
  final VoidCallback onVerifyCode;
  final VoidCallback onToggleAuthMode;
  final VoidCallback onEditEmail;

  const OnboardingSignupPage({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.codeController,
    required this.isSendingAuthEmail,
    required this.isVerifyingLoginCode,
    required this.isLoginMode,
    required this.verificationEmail,
    required this.codeTimeLabel,
    required this.codeExpired,
    required this.onSubmit,
    required this.onVerifyCode,
    required this.onToggleAuthMode,
    required this.onEditEmail,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;
    final email = verificationEmail ?? emailController.text.trim();
    final showingCodeEntry = isLoginMode && isVerifyingLoginCode;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingProgressDots(currentIndex: 2),
          const SizedBox(height: 34),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF35C99F).withOpacity(0.13),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              'Account',
              style: TextStyle(
                color: Color(0xFF35C99F),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            showingCodeEntry
                ? 'Enter your verification code.'
                : isLoginMode
                    ? 'Log in to FocusFlow.'
                    : 'Sign up to start your focus journey.',
            style: TextStyle(
              color: ffTitleColor(),
              fontSize: 36,
              height: 1.05,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            showingCodeEntry
                ? 'Firebase sent a 6-digit code to $email.'
                : isLoginMode
                    ? 'Enter your email and password. Firebase will email you a code before opening the app.'
                    : 'Use an email and password to create your Firebase account.',
            style: TextStyle(
              color: ffSubtitleColor(),
              fontSize: 15,
              height: 1.55,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 34),
          showingCodeEntry
              ? Container(
                  padding: const EdgeInsets.all(18),
                  decoration: cardDecoration(),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.mark_email_read_rounded,
                            color: Color(0xFF35C99F),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              email,
                              style: TextStyle(
                                color: ffTitleColor(),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      OnboardingTextField(
                        controller: codeController,
                        hint: '6-digit code',
                        icon: Icons.pin_rounded,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        maxLength: 6,
                        autofillHints: const [AutofillHints.oneTimeCode],
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onSubmitted: (_) => onVerifyCode(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              codeExpired
                                  ? 'Code expired.'
                                  : 'Code expires in $codeTimeLabel.',
                              style: TextStyle(
                                color: codeExpired
                                    ? const Color(0xFFFF6B6B)
                                    : ffSubtitleColor(),
                                fontSize: 12,
                                height: 1.4,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: onEditEmail,
                            child: const Text('Edit email'),
                          ),
                          TextButton(
                            onPressed: isSendingAuthEmail ? null : onSubmit,
                            child: Text(
                              isSendingAuthEmail ? 'Sending...' : 'Resend',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(18),
                  decoration: cardDecoration(),
                  child: Column(
                    children: [
                      OnboardingTextField(
                        controller: emailController,
                        hint: 'Email address',
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: 14),
                      OnboardingTextField(
                        controller: passwordController,
                        hint: 'Password',
                        icon: Icons.lock_rounded,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: isLoginMode
                            ? const [AutofillHints.password]
                            : const [AutofillHints.newPassword],
                        onSubmitted: (_) => onSubmit(),
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: 18),
          Text(
            showingCodeEntry
                ? 'Enter the code before it expires to finish login.'
                : isLoginMode
                    ? 'The code is sent through Firebase using your Firestore mail collection.'
                    : 'A Firebase email verification link is sent when your account is created.',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.45)
                  : const Color(0xFF9CA5C4),
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 28),
          OnboardingButton(
            text: showingCodeEntry
                ? 'Verify Code'
                : isSendingAuthEmail
                    ? isLoginMode
                        ? 'Sending Code...'
                        : 'Creating Account...'
                    : isLoginMode
                        ? 'Send Verification Code'
                        : 'Create Account',
            onPressed: isSendingAuthEmail
                ? null
                : showingCodeEntry
                    ? onVerifyCode
                    : onSubmit,
          ),
          const SizedBox(height: 14),
          Center(
            child: TextButton(
              onPressed: onToggleAuthMode,
              child: Text(
                isLoginMode
                    ? 'Need an account? Sign up'
                    : 'Already have an account? Log in',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;
  final TextCapitalization textCapitalization;

  const OnboardingTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLength,
    this.autofillHints,
    this.inputFormatters,
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      maxLength: maxLength,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      onSubmitted: onSubmitted,
      style: TextStyle(
        color: ffTitleColor(),
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF6F8DFF),
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: ffSubtitleColor(),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        counterText: '',
        filled: true,
        fillColor: isDark ? const Color(0xFF111827) : const Color(0xFFF3F6FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.07) : Colors.transparent,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.07) : Colors.transparent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFF17BEBB),
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class OnboardingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const OnboardingButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return PressableScale(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: isEnabled
                ? ffBrandGradientColors()
                : const [
                    Color(0xFF9CA5C4),
                    Color(0xFFB6BED5),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF17BEBB).withOpacity(
                isEnabled ? 0.30 : 0.08,
              ),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class OnboardingProgressDots extends StatelessWidget {
  final int currentIndex;
  final int totalSteps;

  const OnboardingProgressDots({
    super.key,
    required this.currentIndex,
    this.totalSteps = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final selected = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.only(right: 8),
          width: selected ? 30 : 9,
          height: 9,
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF17BEBB)
                : const Color(0xFF9CA5C4).withOpacity(0.35),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class CircleBlob extends StatelessWidget {
  final double size;

  const CircleBlob({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        shape: BoxShape.circle,
      ),
    );
  }
}

class FocusFlowShell extends StatefulWidget {
  const FocusFlowShell({super.key});

  @override
  State<FocusFlowShell> createState() => _FocusFlowShellState();
}

class FocusFlowTutorialStep {
  final int tabIndex;
  final IconData icon;
  final String title;
  final String body;
  final String highlightLabel;
  final Alignment spotlightAlignment;
  final double spotlightWidthFactor;
  final double spotlightHeight;
  final String? actionLabel;
  final String? actionId;

  const FocusFlowTutorialStep({
    required this.tabIndex,
    required this.icon,
    required this.title,
    required this.body,
    required this.highlightLabel,
    required this.spotlightAlignment,
    required this.spotlightWidthFactor,
    required this.spotlightHeight,
    this.actionLabel,
    this.actionId,
  });
}

class _FocusFlowShellState extends State<FocusFlowShell> {
  static const List<FocusFlowTutorialStep> tutorialSteps = [
    FocusFlowTutorialStep(
      tabIndex: 0,
      icon: Icons.dashboard_customize_rounded,
      title: 'Your daily command center',
      body:
          'Home shows your focus goal, streak, quick starts, distraction shield, and today’s plan in one place.',
      highlightLabel: 'Home dashboard',
      spotlightAlignment: Alignment.topCenter,
      spotlightWidthFactor: 0.90,
      spotlightHeight: 116,
      actionLabel: 'Toggle Shield',
      actionId: 'toggleShield',
    ),
    FocusFlowTutorialStep(
      tabIndex: 0,
      icon: Icons.checklist_rounded,
      title: 'Turn school into a plan',
      body:
          'Use Today’s Plan for homework, projects, and study blocks between classes. I can add a sample task for you to try.',
      highlightLabel: 'Today’s Plan',
      spotlightAlignment: Alignment.bottomCenter,
      spotlightWidthFactor: 0.92,
      spotlightHeight: 236,
      actionLabel: 'Add Demo Task',
      actionId: 'addTask',
    ),
    FocusFlowTutorialStep(
      tabIndex: 1,
      icon: Icons.timer_rounded,
      title: 'Run focused study sessions',
      body:
          'The Focus tab starts timed sessions. Try logging a mini focus win so the Stats page has something to show.',
      highlightLabel: 'Focus Timer',
      spotlightAlignment: Alignment.center,
      spotlightWidthFactor: 0.86,
      spotlightHeight: 330,
      actionLabel: 'Log 5 Minutes',
      actionId: 'logSession',
    ),
    FocusFlowTutorialStep(
      tabIndex: 2,
      icon: Icons.bar_chart_rounded,
      title: 'Watch your progress build',
      body:
          'Stats shows focus minutes, streaks, trends, and what is helping you stay consistent. Add sample progress to see it react.',
      highlightLabel: 'Insights',
      spotlightAlignment: Alignment.topCenter,
      spotlightWidthFactor: 0.90,
      spotlightHeight: 260,
      actionLabel: 'Add Sample Stats',
      actionId: 'statsSample',
    ),
    FocusFlowTutorialStep(
      tabIndex: 3,
      icon: Icons.person_rounded,
      title: 'Personalize your profile',
      body:
          'Profile and Settings let you update your name, school, classes, theme, focus goal, and account details. Open Settings from here.',
      highlightLabel: 'Profile & Settings',
      spotlightAlignment: Alignment.topCenter,
      spotlightWidthFactor: 0.88,
      spotlightHeight: 240,
      actionLabel: 'Open Settings',
      actionId: 'settings',
    ),
    FocusFlowTutorialStep(
      tabIndex: 4,
      icon: Icons.auto_awesome_rounded,
      title: 'Unlock stronger tools',
      body:
          'Pro is where premium timers, deeper analytics, and advanced productivity upgrades live.',
      highlightLabel: 'FocusFlow Pro',
      spotlightAlignment: Alignment.center,
      spotlightWidthFactor: 0.90,
      spotlightHeight: 310,
    ),
  ];

  bool tutorialActive = false;
  int tutorialIndex = 0;

  @override
  void initState() {
    super.initState();
    focusFlowTutorialReplayRequests.addListener(handleTutorialReplayRequest);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || focusFlowTutorialCompleted.value) {
        return;
      }

      showFocusFlowTutorialPrompt();
    });
  }

  @override
  void dispose() {
    focusFlowTutorialReplayRequests.removeListener(handleTutorialReplayRequest);
    super.dispose();
  }

  void handleTutorialReplayRequest() {
    if (!mounted) {
      return;
    }

    startTutorial();
  }

  Widget pageForIndex(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const FocusScreen();
      case 2:
        return const InsightsScreen();
      case 3:
        return const ProfileScreen();
      case 4:
        return const PremiumScreen();
      default:
        return const HomeScreen();
    }
  }

  void showFocusFlowTutorialPrompt() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ffCardColor(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Want a quick tour?',
            style: TextStyle(
              color: ffTitleColor(),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'I can highlight the main parts of FocusFlow and explain how to use them for your school day.',
            style: TextStyle(
              color: ffSubtitleColor(),
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                saveFocusFlowTutorialCompleted(true);
                Navigator.pop(context);
              },
              child: const Text('Skip'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                startTutorial();
              },
              child: const Text('Show Me'),
            ),
          ],
        );
      },
    );
  }

  void startTutorial() {
    focusFlowCurrentTab.value = tutorialSteps.first.tabIndex;

    setState(() {
      tutorialIndex = 0;
      tutorialActive = true;
    });
  }

  Future<void> finishTutorial() async {
    setState(() {
      tutorialActive = false;
    });

    await saveFocusFlowTutorialCompleted(true);
  }

  void nextTutorialStep() {
    final nextIndex = tutorialIndex + 1;

    if (nextIndex >= tutorialSteps.length) {
      finishTutorial();
      return;
    }

    focusFlowCurrentTab.value = tutorialSteps[nextIndex].tabIndex;

    setState(() {
      tutorialIndex = nextIndex;
    });
  }

  Future<void> runTutorialAction(FocusFlowTutorialStep step) async {
    switch (step.actionId) {
      case 'toggleShield':
        await saveFocusFlowAppBlocking(!focusFlowAppBlocking.value);
        showFocusFlowGlobalMessage(
          focusFlowAppBlocking.value
              ? 'Distraction shield turned on.'
              : 'Distraction shield paused.',
        );
        break;
      case 'addTask':
        await addFocusFlowTask(
          'Study for next class',
          'Demo task from the tutorial',
          priority: 'High',
          estimateMinutes: 25,
        );
        showFocusFlowGlobalMessage('Demo task added to Today’s Plan.');
        break;
      case 'logSession':
        await saveFocusFlowCompletedSession(
          5,
          mode: 'Tutorial',
          note: 'Mini focus win',
        );
        showFocusFlowGlobalMessage('Logged a 5-minute focus session.');
        break;
      case 'statsSample':
        await saveFocusFlowCompletedSession(
          20,
          mode: 'Stats Demo',
          note: 'Sample study block',
        );
        showFocusFlowGlobalMessage('Sample stats added.');
        break;
      case 'settings':
        showFocusFlowSettingsSheet(context);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: focusFlowDarkMode,
      builder: (context, isDark, _) {
        return ValueListenableBuilder<int>(
          valueListenable: focusFlowCurrentTab,
          builder: (context, currentIndex, _) {
            return Scaffold(
              extendBody: true,
              backgroundColor:
                  isDark ? const Color(0xFF080B10) : const Color(0xFFF4F7FA),
              body: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: ffPageGradientColors(isDark),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    const Positioned.fill(child: _FocusFlowAtmosphere()),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 430),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final curvedAnimation = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        );

                        return FadeTransition(
                          opacity: curvedAnimation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.985, end: 1).animate(
                              curvedAnimation,
                            ),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.035, 0.012),
                                end: Offset.zero,
                              ).animate(curvedAnimation),
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey('$currentIndex-$isDark'),
                        child: pageForIndex(currentIndex),
                      ),
                    ),
                    if (tutorialActive)
                      FocusFlowTutorialOverlay(
                        step: tutorialSteps[tutorialIndex],
                        stepNumber: tutorialIndex + 1,
                        totalSteps: tutorialSteps.length,
                        onNext: nextTutorialStep,
                        onSkip: () => finishTutorial(),
                        onAction: () => runTutorialAction(
                          tutorialSteps[tutorialIndex],
                        ),
                      ),
                  ],
                ),
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A).withOpacity(0.82)
                            : Colors.white.withOpacity(0.76),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.10)
                              : const Color(0xFFDDE6F3).withOpacity(0.88),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.42)
                                : const Color(0xFF0F172A).withOpacity(0.10),
                            blurRadius: 28,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          NavItem(
                            icon: Icons.home_rounded,
                            label: 'Home',
                            selected: currentIndex == 0,
                            onTap: () => focusFlowCurrentTab.value = 0,
                          ),
                          NavItem(
                            icon: Icons.timer_rounded,
                            label: 'Focus',
                            selected: currentIndex == 1,
                            onTap: () => focusFlowCurrentTab.value = 1,
                          ),
                          NavItem(
                            icon: Icons.bar_chart_rounded,
                            label: 'Stats',
                            selected: currentIndex == 2,
                            onTap: () => focusFlowCurrentTab.value = 2,
                          ),
                          NavItem(
                            icon: Icons.person_rounded,
                            label: 'Profile',
                            selected: currentIndex == 3,
                            onTap: () => focusFlowCurrentTab.value = 3,
                          ),
                          NavItem(
                            icon: Icons.auto_awesome_rounded,
                            label: 'Pro',
                            selected: currentIndex == 4,
                            onTap: () => focusFlowCurrentTab.value = 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class FocusFlowTutorialOverlay extends StatelessWidget {
  final FocusFlowTutorialStep step;
  final int stepNumber;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onAction;

  const FocusFlowTutorialOverlay({
    super.key,
    required this.step,
    required this.stepNumber,
    required this.totalSteps,
    required this.onNext,
    required this.onSkip,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isLastStep = stepNumber == totalSteps;
    final isDark = focusFlowDarkMode.value;

    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              color: Colors.black.withOpacity(isDark ? 0.58 : 0.42),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 116),
                child: Column(
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              Align(
                                alignment: step.spotlightAlignment,
                                child: _TutorialSpotlightFrame(
                                  step: step,
                                  width: constraints.maxWidth *
                                      step.spotlightWidthFactor,
                                  height: step.spotlightHeight,
                                ),
                              ),
                              Align(
                                alignment: Alignment.topCenter,
                                child: _TutorialHighlightPill(step: step),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    _TutorialExplanationCard(
                      step: step,
                      stepNumber: stepNumber,
                      totalSteps: totalSteps,
                      isLastStep: isLastStep,
                      onNext: onNext,
                      onSkip: onSkip,
                      onAction: step.actionId == null ? null : onAction,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 220.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.015, end: 0, duration: 260.ms);
  }
}

class _TutorialSpotlightFrame extends StatelessWidget {
  final FocusFlowTutorialStep step;
  final double width;
  final double height;

  const _TutorialSpotlightFrame({
    required this.step,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF17BEBB).withOpacity(0.88),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17BEBB).withOpacity(0.32),
            blurRadius: 34,
            spreadRadius: 6,
          ),
          BoxShadow(
            color: const Color(0xFFFF8A3D).withOpacity(0.20),
            blurRadius: 54,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF17BEBB),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            step.highlightLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
          begin: const Offset(0.985, 0.985),
          end: const Offset(1.018, 1.018),
          duration: 850.ms,
          curve: Curves.easeInOut,
        );
  }
}

class _TutorialHighlightPill extends StatelessWidget {
  final FocusFlowTutorialStep step;

  const _TutorialHighlightPill({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: ffBrandGradientColors()),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17BEBB).withOpacity(0.34),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(step.icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            step.highlightLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
          begin: const Offset(0.98, 0.98),
          end: const Offset(1.04, 1.04),
          duration: 780.ms,
          curve: Curves.easeInOut,
        );
  }
}

class _TutorialExplanationCard extends StatelessWidget {
  final FocusFlowTutorialStep step;
  final int stepNumber;
  final int totalSteps;
  final bool isLastStep;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback? onAction;

  const _TutorialExplanationCard({
    required this.step,
    required this.stepNumber,
    required this.totalSteps,
    required this.isLastStep,
    required this.onNext,
    required this.onSkip,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ffCardColor(),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: focusFlowDarkMode.value
              ? Colors.white.withOpacity(0.10)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF17BEBB).withOpacity(0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  step.icon,
                  color: const Color(0xFF17A99E),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Step $stepNumber of $totalSteps',
                  style: TextStyle(
                    color: ffSubtitleColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: onSkip,
                child: const Text('Skip'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            step.title,
            style: TextStyle(
              color: ffTitleColor(),
              fontSize: 24,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            step.body,
            style: TextStyle(
              color: ffSubtitleColor(),
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          if (step.actionLabel != null) ...[
            PressableScale(
              onTap: onAction,
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: focusFlowDarkMode.value
                      ? Colors.white.withOpacity(0.08)
                      : const Color(0xFFEFF6F8),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFF17BEBB).withOpacity(0.26),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.touch_app_rounded,
                      color: Color(0xFF17A99E),
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      step.actionLabel!,
                      style: const TextStyle(
                        color: Color(0xFF17A99E),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: stepNumber / totalSteps,
                    minHeight: 8,
                    backgroundColor: focusFlowDarkMode.value
                        ? Colors.white.withOpacity(0.10)
                        : const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF17BEBB),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              PressableScale(
                onTap: onNext,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: ffBrandGradientColors()),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isLastStep ? 'Finish' : 'Next',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.92,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 14 : 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: ffBrandGradientColors(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(color: Colors.white.withOpacity(0.22))
              : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF17BEBB).withOpacity(0.26),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? Colors.white : ffSubtitleColor(),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              child: selected
                  ? Row(
                      children: [
                        const SizedBox(width: 7),
                        Text(
                          label,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeHeader(),
          const SizedBox(height: 22),
          const TodayFocusHero()
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.08, end: 0),
          const SizedBox(height: 18),
          ValueListenableBuilder<List<String>>(
            valueListenable: focusFlowSessionHistory,
            builder: (context, sessionHistory, _) {
              final streak = focusFlowCurrentStreakDays();
              final score = sessionHistory.isEmpty
                  ? 0
                  : min(99, 72 + sessionHistory.length * 3);

              return Row(
                children: [
                  Expanded(
                    child: FocusMetricCard(
                      icon: Icons.local_fire_department_rounded,
                      value: '$streak',
                      label: 'Day Streak',
                      accent: const Color(0xFFFF8A3D),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: FocusMetricCard(
                      icon: Icons.bolt_rounded,
                      value: '$score%',
                      label: 'Focus Score',
                      accent: const Color(0xFF4E7DFF),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          const FocusFlowProductivityOverviewCard(),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: SectionTitle(title: 'Quick Start'),
              ),
              GestureDetector(
                onTap: () => showFocusFlowSettingsSheet(context),
                child: Text(
                  'Customize',
                  style: TextStyle(
                    color: const Color(0xFF4E7DFF).withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ValueListenableBuilder<bool>(
            valueListenable: focusFlowIsPro,
            builder: (context, isPro, _) {
              return ValueListenableBuilder<String>(
                valueListenable: focusFlowQuickStart,
                builder: (context, selectedQuickStart, _) {
                  return Row(
                    children: [
                      Expanded(
                        child: QuickStartCard(
                          icon: Icons.timer_rounded,
                          title: 'Pomodoro',
                          subtitle: '25 min',
                          selected: selectedQuickStart == 'Pomodoro',
                          locked: false,
                          onTap: () => saveFocusFlowQuickStart('Pomodoro'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: QuickStartCard(
                          icon: isPro
                              ? Icons.psychology_rounded
                              : Icons.lock_rounded,
                          title: 'Deep Work',
                          subtitle: isPro ? '50 min' : 'Pro',
                          selected: isPro && selectedQuickStart == 'Deep Work',
                          locked: !isPro,
                          onTap: () {
                            if (isPro) {
                              saveFocusFlowQuickStart('Deep Work');
                            } else {
                              showFocusFlowProLockedSheet(context);
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Distraction Control'),
          const SizedBox(height: 14),
          const AppBlockerCard(),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Today’s Plan'),
          const SizedBox(height: 14),
          const InteractiveTodayPlan(),
        ],
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: focusFlowUserName,
      builder: (context, userName, _) {
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning, $userName',
                    style: TextStyle(
                      color: ffSubtitleColor(),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'FocusFlow',
                    style: TextStyle(
                      color: ffTitleColor(),
                      fontSize: 34,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            PressableScale(
              onTap: () => showFocusFlowSettingsSheet(context),
              child: ValueListenableBuilder<String>(
                valueListenable: focusFlowProfileIcon,
                builder: (context, profileIcon, _) {
                  return Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: ffBrandGradientColors(),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.24)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF17BEBB).withOpacity(0.24),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      focusFlowProfileIconData(profileIcon),
                      color: Colors.white,
                      size: 28,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

IconData focusFlowProfileIconData(String value) {
  switch (value) {
    case 'bolt':
      return Icons.bolt_rounded;
    case 'leaf':
      return Icons.eco_rounded;
    case 'star':
      return Icons.star_rounded;
    case 'verified':
      return Icons.verified_rounded;
    default:
      return Icons.person_rounded;
  }
}

void showFocusFlowSettingsSheet(BuildContext context) {
  final isDark = focusFlowDarkMode.value;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.55,
        maxChildSize: 0.94,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: ffPageGradientColors(isDark),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : const Color(0xFFE2E8F0).withOpacity(0.90),
              ),
            ),
            child: SafeArea(
              top: false,
              child: ListView(
                controller: scrollController,
                children: [
                  const FocusFlowSettingsSheetHeader(),
                  const SizedBox(height: 18),
                  const FocusFlowSettingsProfileCard(),
                  const SizedBox(height: 12),
                  const FocusFlowSchoolScheduleCard(),
                  const SizedBox(height: 22),
                  const FocusFlowSettingsSectionTitle(title: 'Basic Settings'),
                  const SizedBox(height: 12),
                  const NotificationsSettingTile(),
                  const SizedBox(height: 12),
                  const DarkModeSettingTile(),
                  const SizedBox(height: 12),
                  const FocusFlowDailyGoalSettingCard(),
                  const SizedBox(height: 12),
                  const FocusFlowQuickStartSettingCard(),
                  const SizedBox(height: 12),
                  ProfileSettingTile(
                    icon: Icons.tips_and_updates_rounded,
                    title: 'Replay Tutorial',
                    subtitle: 'Walk through the app features again.',
                    onTap: () {
                      Navigator.pop(context);
                      focusFlowTutorialReplayRequests.value =
                          focusFlowTutorialReplayRequests.value + 1;
                    },
                  ),
                  const SizedBox(height: 22),
                  const FocusFlowSettingsSectionTitle(
                    title: 'Advanced Settings',
                  ),
                  const SizedBox(height: 12),
                  const AppBlockingSettingTile(),
                  const SizedBox(height: 12),
                  const FocusFlowSettingsInfoTile(
                    icon: Icons.lock_rounded,
                    title: 'Privacy & Data',
                    subtitle:
                        'Your prototype data is stored locally on this device.',
                  ),
                  const SizedBox(height: 12),
                  const FocusFlowSettingsInfoTile(
                    icon: Icons.tune_rounded,
                    title: 'Focus Engine',
                    subtitle:
                        'Timers, task progress, and blocker state are editable locally.',
                  ),
                  const SizedBox(height: 12),
                  const FocusFlowDataSettingsCard(),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class FocusFlowSettingsSheetHeader extends StatelessWidget {
  const FocusFlowSettingsSheetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 5,
          decoration: BoxDecoration(
            color: focusFlowDarkMode.value
                ? Colors.white.withOpacity(0.18)
                : const Color(0xFFD9DEF0),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Text(
                'Settings',
                style: TextStyle(
                  color: ffTitleColor(),
                  fontSize: 28,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: CircleAvatar(
                radius: 19,
                backgroundColor: ffSoftPillColor(),
                child: Icon(
                  Icons.close_rounded,
                  color: ffSubtitleColor(),
                  size: 21,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class FocusFlowSettingsProfileCard extends StatelessWidget {
  const FocusFlowSettingsProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: focusFlowUserName,
      builder: (context, userName, _) {
        return ValueListenableBuilder<String>(
          valueListenable: focusFlowUserEmail,
          builder: (context, userEmail, _) {
            return ValueListenableBuilder<String>(
              valueListenable: focusFlowProfileIcon,
              builder: (context, profileIcon, _) {
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: cardDecoration(),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 31,
                            backgroundColor:
                                const Color(0xFF17BEBB).withOpacity(0.14),
                            child: Icon(
                              focusFlowProfileIconData(profileIcon),
                              color: const Color(0xFF17A99E),
                              size: 34,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: TextStyle(
                                    color: ffTitleColor(),
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userEmail.isEmpty
                                      ? 'Local profile'
                                      : userEmail,
                                  style: TextStyle(
                                    color: ffSubtitleColor(),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FocusFlowSettingsMiniButton(
                              icon: Icons.edit_rounded,
                              label: 'Edit Name',
                              onTap: () => showFocusFlowEditNameDialog(context),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FocusFlowSettingsMiniButton(
                              icon: Icons.account_circle_rounded,
                              label: 'Edit Profile',
                              onTap: () =>
                                  showFocusFlowEditProfileSheet(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class FocusFlowSchoolScheduleCard extends StatelessWidget {
  const FocusFlowSchoolScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: focusFlowSchoolName,
      builder: (context, schoolName, _) {
        return ValueListenableBuilder<List<String>>(
          valueListenable: focusFlowClassSchedule,
          builder: (context, classes, _) {
            final displaySchool =
                schoolName.trim().isEmpty ? 'School not set' : schoolName;
            final classLabel = classes.isEmpty
                ? 'No classes added'
                : '${classes.length} classes saved';

            return PressableScale(
              onTap: () => showFocusFlowSchoolScheduleSheet(context),
              borderRadius: BorderRadius.circular(22),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: cardDecoration(),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFF17BEBB).withOpacity(0.14),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Color(0xFF17A99E),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displaySchool,
                            style: TextStyle(
                              color: ffTitleColor(),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            classLabel,
                            style: TextStyle(
                              color: ffSubtitleColor(),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.edit_rounded,
                      color: ffSubtitleColor(),
                      size: 21,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

void showFocusFlowSchoolScheduleSheet(BuildContext context) {
  final schoolController =
      TextEditingController(text: focusFlowSchoolName.value);
  final classNameController = TextEditingController();
  final classTimeController = TextEditingController();
  var classes = List<String>.from(focusFlowClassSchedule.value);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          void addClass() {
            final className = classNameController.text.trim();
            final classTime = classTimeController.text.trim();

            if (className.isEmpty) {
              showFocusFlowGlobalMessage('Enter a class name.');
              return;
            }

            final classLabel =
                classTime.isEmpty ? className : '$className • $classTime';

            setSheetState(() {
              classes = [...classes, classLabel];
            });

            classNameController.clear();
            classTimeController.clear();
          }

          return Container(
            margin: const EdgeInsets.all(16),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: BoxDecoration(
              color: ffCardColor(),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: focusFlowDarkMode.value
                    ? Colors.white.withOpacity(0.08)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'School & Classes',
                      style: TextStyle(
                        color: ffTitleColor(),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OnboardingTextField(
                      controller: schoolController,
                      hint: 'School name',
                      icon: Icons.school_rounded,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 14),
                    OnboardingTextField(
                      controller: classNameController,
                      hint: 'Class name',
                      icon: Icons.menu_book_rounded,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 14),
                    OnboardingTextField(
                      controller: classTimeController,
                      hint: 'Days and time',
                      icon: Icons.schedule_rounded,
                      onSubmitted: (_) => addClass(),
                    ),
                    const SizedBox(height: 14),
                    FocusFlowSettingsMiniButton(
                      icon: Icons.add_rounded,
                      label: 'Add Class',
                      onTap: addClass,
                    ),
                    const SizedBox(height: 16),
                    for (final classItem in classes)
                      OnboardingClassChip(
                        classItem: classItem,
                        onRemove: () {
                          setSheetState(() {
                            classes = classes
                                .where((item) => item != classItem)
                                .toList();
                          });
                        },
                      ),
                    const SizedBox(height: 8),
                    OnboardingButton(
                      text: 'Save',
                      onPressed: () async {
                        await saveFocusFlowSchoolName(schoolController.text);
                        await saveFocusFlowClassSchedule(classes);

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  ).whenComplete(() {
    schoolController.dispose();
    classNameController.dispose();
    classTimeController.dispose();
  });
}

class FocusFlowSettingsMiniButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const FocusFlowSettingsMiniButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: ffSoftPillColor(),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: focusFlowDarkMode.value
                ? Colors.white.withOpacity(0.07)
                : const Color(0xFFDDE6F3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF17A99E), size: 18),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ffTitleColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FocusFlowSettingsSectionTitle extends StatelessWidget {
  final String title;

  const FocusFlowSettingsSectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Color(0xFFFF8A3D),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: TextStyle(
            color: ffTitleColor(),
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class FocusFlowSettingsInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const FocusFlowSettingsInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileSettingTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title: $subtitle'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }
}

class FocusFlowQuickStartSettingCard extends StatelessWidget {
  const FocusFlowQuickStartSettingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: focusFlowQuickStart,
      builder: (context, quickStart, _) {
        return Container(
          padding: const EdgeInsets.all(17),
          decoration: cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundColor: const Color(0xFF17BEBB).withOpacity(
                      focusFlowDarkMode.value ? 0.20 : 0.11,
                    ),
                    child: const Icon(
                      Icons.flash_on_rounded,
                      color: Color(0xFF17A99E),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Start',
                          style: TextStyle(
                            color: ffTitleColor(),
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Default focus mode',
                          style: TextStyle(
                            color: ffSubtitleColor(),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in const [
                    'Pomodoro',
                    'Short Sprint',
                    'Deep Work'
                  ])
                    FocusFlowSettingsChoiceChip(
                      label: option,
                      selected: quickStart == option,
                      onTap: () => saveFocusFlowQuickStart(option),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class FocusFlowDailyGoalSettingCard extends StatelessWidget {
  const FocusFlowDailyGoalSettingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: focusFlowDailyGoalMinutes,
      builder: (context, goalMinutes, _) {
        return Container(
          padding: const EdgeInsets.all(17),
          decoration: cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundColor: const Color(0xFF35C99F).withOpacity(
                      focusFlowDarkMode.value ? 0.20 : 0.12,
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: Color(0xFF35C99F),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Focus Goal',
                          style: TextStyle(
                            color: ffTitleColor(),
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatFocusMinutes(goalMinutes)} per day',
                          style: TextStyle(
                            color: ffSubtitleColor(),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final minutes in const [25, 50, 90, 120])
                    FocusFlowSettingsChoiceChip(
                      label: formatFocusMinutes(minutes),
                      selected: goalMinutes == minutes,
                      onTap: () => saveFocusFlowDailyGoalMinutes(minutes),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class FocusFlowDataSettingsCard extends StatelessWidget {
  const FocusFlowDataSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSettingTile(
      icon: Icons.delete_sweep_rounded,
      title: 'Reset Progress Data',
      subtitle: 'Clear tasks, timers, session history, and stats',
      onTap: () => showFocusFlowResetDataDialog(context),
    );
  }
}

class FocusFlowSettingsChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FocusFlowSettingsChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4E7DFF) : ffSoftPillColor(),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : ffSubtitleColor(),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

void showFocusFlowEditNameDialog(BuildContext context) {
  final controller = TextEditingController(text: focusFlowUserName.value);

  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: ffCardColor(),
        title: Text(
          'Edit Name',
          style: TextStyle(
            color: ffTitleColor(),
            fontWeight: FontWeight.w900,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Display name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              saveFocusFlowUserName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

void showFocusFlowEditProfileSheet(BuildContext context) {
  final isDark = focusFlowDarkMode.value;

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.42 : 0.12),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile',
                style: TextStyle(
                  color: ffTitleColor(),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a profile icon.',
                style: TextStyle(
                  color: ffSubtitleColor(),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              ValueListenableBuilder<String>(
                valueListenable: focusFlowProfileIcon,
                builder: (context, currentIcon, _) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final option in const [
                        'person',
                        'bolt',
                        'leaf',
                        'star',
                        'verified',
                      ])
                        FocusFlowProfileIconChoice(
                          value: option,
                          selected: currentIcon == option,
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showFocusFlowResetDataDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: ffCardColor(),
        title: Text(
          'Reset Progress Data?',
          style: TextStyle(
            color: ffTitleColor(),
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          'This clears your tasks, custom timers, session history, and stats. Your login and profile stay saved.',
          style: TextStyle(
            color: ffSubtitleColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await resetFocusFlowProgressData();

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Reset'),
          ),
        ],
      );
    },
  );
}

class FocusFlowProfileIconChoice extends StatelessWidget {
  final String value;
  final bool selected;

  const FocusFlowProfileIconChoice({
    super.key,
    required this.value,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => saveFocusFlowProfileIcon(value),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF17A99E) : ffSoftPillColor(),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF17BEBB)
                : focusFlowDarkMode.value
                    ? Colors.white.withOpacity(0.06)
                    : const Color(0xFFDDE6F3),
            width: 1.5,
          ),
        ),
        child: Icon(
          focusFlowProfileIconData(value),
          color: selected ? Colors.white : const Color(0xFF17A99E),
        ),
      ),
    );
  }
}

class TodayFocusHero extends StatelessWidget {
  const TodayFocusHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: focusFlowTodayTasks,
      builder: (context, todayTasks, _) {
        return ValueListenableBuilder<List<String>>(
          valueListenable: focusFlowCompletedTasks,
          builder: (context, completedTasks, _) {
            final taskCount = focusFlowTasks().length;
            final completedCount = completedTasks.length.clamp(0, taskCount);
            final progress = taskCount == 0 ? 0.0 : completedCount / taskCount;
            final percent = (progress * 100).round();

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: ffBrandGradientColors(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withOpacity(0.20)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF17BEBB).withOpacity(0.28),
                    blurRadius: 36,
                    offset: const Offset(0, 22),
                  ),
                  BoxShadow(
                    color: const Color(0xFFFF8A3D).withOpacity(0.16),
                    blurRadius: 54,
                    offset: const Offset(0, 28),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -34,
                    top: -34,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 30,
                    bottom: -50,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.flash_on_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Today’s Focus Goal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 260),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              '$percent%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        '$completedCount / $taskCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        taskCount > 0 && completedCount == taskCount
                            ? 'All focus tasks completed today'
                            : 'tasks completed from today’s plan',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.82),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 22),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 650),
                        curve: Curves.easeOutCubic,
                        builder: (context, animatedProgress, _) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: animatedProgress,
                              minHeight: 12,
                              backgroundColor: Colors.white.withOpacity(0.20),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          _HeroMiniInfo(
                            icon: taskCount > 0 && completedCount == taskCount
                                ? Icons.emoji_events_rounded
                                : Icons.check_circle_rounded,
                            text: taskCount > 0 && completedCount == taskCount
                                ? 'Goal complete'
                                : '$completedCount done',
                          ),
                          const SizedBox(width: 10),
                          _HeroMiniInfo(
                            icon: Icons.shield_rounded,
                            text: focusFlowAppBlocking.value
                                ? 'Apps blocked'
                                : 'Shield paused',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _HeroMiniInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeroMiniInfo({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class FocusMetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  const FocusMetricCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: accent.withOpacity(isDark ? 0.22 : 0.13),
                child: Icon(icon, color: accent),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up_rounded,
                color: accent.withOpacity(0.8),
                size: 21,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              color: ffTitleColor(),
              fontSize: 29,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: TextStyle(
              color: ffSubtitleColor(),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.08);
  }
}

class QuickStartCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  const QuickStartCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;

    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2563EB)
              : isDark
                  ? const Color(0xFF111827)
                  : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: locked
                ? const Color(0xFFFFB84D).withOpacity(0.35)
                : isDark && !selected
                    ? Colors.white.withOpacity(0.07)
                    : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.35)
                  : selected
                      ? const Color(0xFF4E7DFF).withOpacity(0.24)
                      : Colors.black.withOpacity(0.045),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Opacity(
          opacity: locked ? 0.72 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: selected
                    ? Colors.white.withOpacity(0.16)
                    : locked
                        ? const Color(0xFFFFB84D).withOpacity(0.16)
                        : isDark
                            ? const Color(0xFF172033)
                            : const Color(0xFFEAFBF8),
                child: Icon(
                  icon,
                  color: selected
                      ? Colors.white
                      : locked
                          ? const Color(0xFFFFB84D)
                          : const Color(0xFF17A99E),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.white : ffTitleColor(),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  color: selected ? Colors.white70 : ffSubtitleColor(),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppBlockerCard extends StatelessWidget {
  const AppBlockerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: focusFlowAppBlocking,
      builder: (context, isBlocking, _) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: cardDecoration(),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isBlocking
                            ? const [Color(0xFFFF7A7A), Color(0xFFFFB86B)]
                            : const [Color(0xFF6B7280), Color(0xFF9CA3AF)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      isBlocking
                          ? Icons.block_rounded
                          : Icons.lock_open_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBlocking
                              ? 'Block Distracting Apps'
                              : 'App Blocking Paused',
                          style: TextStyle(
                            color: ffTitleColor(),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isBlocking
                              ? 'Social apps paused during focus'
                              : 'Distraction shield is currently off',
                          style: TextStyle(
                            color: ffSubtitleColor(),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isBlocking,
                    activeColor: const Color(0xFF4E7DFF),
                    onChanged: saveFocusFlowAppBlocking,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Opacity(
                opacity: isBlocking ? 1 : 0.45,
                child: const Row(
                  children: [
                    BlockedAppPill(
                      icon: Icons.camera_alt_rounded,
                      label: 'Instagram',
                    ),
                    SizedBox(width: 9),
                    BlockedAppPill(
                      icon: Icons.music_note_rounded,
                      label: 'TikTok',
                    ),
                    SizedBox(width: 9),
                    BlockedAppPill(
                      icon: Icons.chat_bubble_rounded,
                      label: 'Messages',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BlockedAppPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const BlockedAppPill({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : const Color(0xFFEFF6F8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.block_rounded,
              color: Color(0xFF17A99E),
              size: 20,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ffSubtitleColor(),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showFocusFlowCustomTimerDialog(BuildContext context) async {
  final nameController = TextEditingController();
  final minutesController = TextEditingController(text: '30');

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          bottom: MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: ffCardColor(),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: focusFlowDarkMode.value
                  ? Colors.white.withOpacity(0.08)
                  : Colors.transparent,
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Custom Timer',
                  style: TextStyle(
                    color: ffTitleColor(),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                OnboardingTextField(
                  controller: nameController,
                  hint: 'Timer name',
                  icon: Icons.label_rounded,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                OnboardingTextField(
                  controller: minutesController,
                  hint: 'Minutes',
                  icon: Icons.timer_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 18),
                OnboardingButton(
                  text: 'Add Timer',
                  onPressed: () async {
                    final minutes =
                        int.tryParse(minutesController.text.trim()) ?? 0;
                    await addFocusFlowCustomTimer(
                      nameController.text,
                      minutes,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  nameController.dispose();
  minutesController.dispose();
}

Future<void> showFocusFlowSessionNoteSheet(
  BuildContext context, {
  required String mode,
  required int minutes,
}) async {
  final noteController = TextEditingController();

  await showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          bottom: MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: ffCardColor(),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: focusFlowDarkMode.value
                  ? Colors.white.withOpacity(0.08)
                  : Colors.transparent,
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session Complete',
                  style: TextStyle(
                    color: ffTitleColor(),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$mode • ${formatFocusMinutes(minutes)}',
                  style: TextStyle(
                    color: ffSubtitleColor(),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                OnboardingTextField(
                  controller: noteController,
                  hint: 'What did you work on?',
                  icon: Icons.edit_note_rounded,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 18),
                OnboardingButton(
                  text: 'Save Session',
                  onPressed: () async {
                    await saveFocusFlowCompletedSession(
                      minutes,
                      mode: mode,
                      note: noteController.text,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    await saveFocusFlowCompletedSession(minutes, mode: mode);

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: Center(
                    child: Text(
                      'Skip Note',
                      style: TextStyle(
                        color: ffSubtitleColor(),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  noteController.dispose();
}

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  static const int focusSeconds = 25 * 60;

  Timer? timer;

  int totalSeconds = focusSeconds;
  int secondsLeft = focusSeconds;
  bool isRunning = false;
  String selectedMode = 'Focus';

  double get progress {
    if (totalSeconds == 0) return 0;
    return ((totalSeconds - secondsLeft) / totalSeconds).clamp(0.0, 1.0);
  }

  String get formattedTime {
    final minutes = secondsLeft ~/ 60;
    final seconds = secondsLeft % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get shouldTrackSelectedMode {
    return selectedMode != 'Break' && selectedMode != 'Rest';
  }

  void toggleTimer() {
    if (isRunning) {
      timer?.cancel();
      setState(() {
        isRunning = false;
      });
      return;
    }

    if (secondsLeft == 0) {
      setState(() {
        secondsLeft = totalSeconds;
      });
    }

    setState(() {
      isRunning = true;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (secondsLeft <= 1) {
        timer?.cancel();

        setState(() {
          secondsLeft = 0;
          isRunning = false;
        });

        if (shouldTrackSelectedMode && mounted) {
          await showFocusFlowSessionNoteSheet(
            context,
            mode: selectedMode,
            minutes: totalSeconds ~/ 60,
          );
        }
      } else {
        setState(() {
          secondsLeft--;
        });
      }
    });
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      secondsLeft = totalSeconds;
      isRunning = false;
    });
  }

  void selectMode(String mode, int seconds) {
    timer?.cancel();
    setState(() {
      selectedMode = mode;
      totalSeconds = seconds;
      secondsLeft = seconds;
      isRunning = false;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TopHeader(
            title: 'Focus Timer',
            subtitle: 'Lock in and protect your attention.',
          ),
          const SizedBox(height: 24),
          FocusTimerCard(
            time: formattedTime,
            progress: progress,
            isRunning: isRunning,
            selectedMode: selectedMode,
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleButton(
                icon: Icons.refresh_rounded,
                background: ffCardColor(),
                color: ffSubtitleColor(),
                onTap: resetTimer,
              ),
              const SizedBox(width: 18),
              CircleButton(
                icon:
                    isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                background: const Color(0xFF4E7DFF),
                color: Colors.white,
                size: 76,
                iconSize: 38,
                onTap: toggleTimer,
              ),
              const SizedBox(width: 18),
              CircleButton(
                icon: Icons.stop_rounded,
                background: ffCardColor(),
                color: ffSubtitleColor(),
                onTap: resetTimer,
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              const Expanded(
                child: SectionTitle(title: 'Session Type'),
              ),
              GestureDetector(
                onTap: () => showFocusFlowCustomTimerDialog(context),
                child: const Icon(
                  Icons.add_circle_rounded,
                  color: Color(0xFF4E7DFF),
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ValueListenableBuilder<List<String>>(
            valueListenable: focusFlowCustomTimers,
            builder: (context, customTimers, _) {
              final modes = focusFlowTimerModes();

              return LayoutBuilder(
                builder: (context, constraints) {
                  final tileWidth = (constraints.maxWidth - 12) / 2;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final mode in modes)
                        SizedBox(
                          width: tileWidth,
                          child: FocusModeButton(
                            icon: mode.icon,
                            title: mode.title,
                            time: '${mode.minutes} min',
                            selected: selectedMode == mode.title,
                            onTap: () => selectMode(
                              mode.title,
                              mode.minutes * 60,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 26),
          const FocusStatsStrip(),
          const SizedBox(height: 26),
          const SectionTitle(title: 'Focus Protection'),
          const SizedBox(height: 14),
          const FocusProtectionCard(),
          const SizedBox(height: 24),
          const FocusTipCard(),
        ],
      ),
    );
  }
}

class FocusTimerCard extends StatelessWidget {
  final String time;
  final double progress;
  final bool isRunning;
  final String selectedMode;

  const FocusTimerCard({
    super.key,
    required this.time,
    required this.progress,
    required this.isRunning,
    required this.selectedMode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: isDark
              ? const [
                  Color(0xFF141D2B),
                  Color(0xFF0B1218),
                ]
              : const [
                  Color(0xFFFFFFFF),
                  Color(0xFFF8FCFB),
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.07) : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.38)
                : const Color(0xFF4E7DFF).withOpacity(0.12),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isRunning
                  ? const Color(0xFF35C99F).withOpacity(0.16)
                  : const Color(0xFF4E7DFF).withOpacity(0.16),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              isRunning ? 'Session in progress' : '$selectedMode session ready',
              style: TextStyle(
                color: isRunning
                    ? const Color(0xFF35C99F)
                    : const Color(0xFF6F8DFF),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 24),
          AnimatedScale(
            scale: isRunning ? 1.02 : 1,
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            child: CustomPaint(
              painter: TimerRingPainter(progress: progress),
              child: SizedBox(
                width: 250,
                height: 250,
                child: Center(
                  child: Container(
                    width: 185,
                    height: 185,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? const [
                                Color(0xFF0B1020),
                                Color(0xFF11182D),
                              ]
                            : const [
                                Color(0xFFFFFFFF),
                                Color(0xFFF4F7FF),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.07)
                            : Colors.white.withOpacity(0.88),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isRunning
                              ? const Color(0xFF35C99F).withOpacity(0.26)
                              : isDark
                                  ? Colors.black.withOpacity(0.42)
                                  : const Color(0xFF4E7DFF).withOpacity(0.10),
                          blurRadius: isRunning ? 34 : 25,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          time,
                          style: TextStyle(
                            color: ffTitleColor(),
                            fontSize: 48,
                            height: 1,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          selectedMode,
                          style: TextStyle(
                            color: ffSubtitleColor(),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isRunning
                ? 'Stay focused. Notifications are silenced.'
                : 'Tap play when you are ready to begin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ffSubtitleColor(),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class FocusModeButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final bool selected;
  final VoidCallback onTap;

  const FocusModeButton({
    super.key,
    required this.icon,
    required this.title,
    required this.time,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;

    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2563EB)
              : isDark
                  ? const Color(0xFF111827)
                  : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark && !selected
                ? Colors.white.withOpacity(0.07)
                : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.35)
                  : selected
                      ? const Color(0xFF4E7DFF).withOpacity(0.28)
                      : Colors.black.withOpacity(0.045),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : const Color(0xFF17A99E),
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : ffTitleColor(),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              time,
              style: TextStyle(
                color: selected ? Colors.white70 : ffSubtitleColor(),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FocusStatsStrip extends StatelessWidget {
  const FocusStatsStrip({super.key});

  String formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours == 0) {
      return '${remainingMinutes}m';
    }

    if (remainingMinutes == 0) {
      return '${hours}h';
    }

    return '${hours}h ${remainingMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: focusFlowTotalSessions,
      builder: (context, totalSessions, _) {
        return ValueListenableBuilder<int>(
          valueListenable: focusFlowTotalFocusMinutes,
          builder: (context, totalMinutes, _) {
            final score =
                totalSessions == 0 ? 0 : (70 + totalSessions * 3).clamp(0, 99);

            return Container(
              padding: const EdgeInsets.all(18),
              decoration: cardDecoration(),
              child: Row(
                children: [
                  Expanded(
                    child: FocusStatMini(
                      value: '$totalSessions',
                      label: 'Sessions',
                      icon: Icons.check_circle_rounded,
                      color: const Color(0xFF35C99F),
                    ),
                  ),
                  const FocusDivider(),
                  Expanded(
                    child: FocusStatMini(
                      value: formatMinutes(totalMinutes),
                      label: 'Total Focus',
                      icon: Icons.timer_rounded,
                      color: const Color(0xFF4E7DFF),
                    ),
                  ),
                  const FocusDivider(),
                  Expanded(
                    child: FocusStatMini(
                      value: '$score%',
                      label: 'Score',
                      icon: Icons.trending_up_rounded,
                      color: const Color(0xFFFFB84D),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class FocusStatMini extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const FocusStatMini({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withOpacity(0.13),
          child: Icon(icon, size: 19, color: color),
        ),
        const SizedBox(height: 9),
        Text(
          value,
          style: TextStyle(
            color: ffTitleColor(),
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: ffSubtitleColor(),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class FocusDivider extends StatelessWidget {
  const FocusDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 70,
      color: const Color(0xFFE8ECF8),
    );
  }
}

class FocusProtectionCard extends StatelessWidget {
  const FocusProtectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: focusFlowAppBlocking,
      builder: (context, isBlocking, _) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: cardDecoration(),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: isBlocking
                            ? const [Color(0xFF4E7DFF), Color(0xFF8364FF)]
                            : const [Color(0xFF6B7280), Color(0xFF9CA3AF)],
                      ),
                    ),
                    child: Icon(
                      isBlocking ? Icons.shield_rounded : Icons.shield_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Distraction Shield',
                          style: TextStyle(
                            color: ffTitleColor(),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isBlocking
                              ? 'Block apps while the timer runs'
                              : 'Apps are allowed during focus',
                          style: TextStyle(
                            color: ffSubtitleColor(),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isBlocking
                          ? const Color(0xFF35C99F).withOpacity(0.12)
                          : const Color(0xFFFF7A7A).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      isBlocking ? 'ON' : 'OFF',
                      style: TextStyle(
                        color: isBlocking
                            ? const Color(0xFF35C99F)
                            : const Color(0xFFFF7A7A),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Opacity(
                opacity: isBlocking ? 1 : 0.45,
                child: const Row(
                  children: [
                    BlockedAppPill(
                      icon: Icons.camera_alt_rounded,
                      label: 'Instagram',
                    ),
                    SizedBox(width: 9),
                    BlockedAppPill(
                      icon: Icons.music_note_rounded,
                      label: 'TikTok',
                    ),
                    SizedBox(width: 9),
                    BlockedAppPill(
                      icon: Icons.play_arrow_rounded,
                      label: 'YouTube',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FocusTipCard extends StatelessWidget {
  const FocusTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: ffTitleColor(),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17233D).withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: Colors.white12,
            child: Icon(
              Icons.lightbulb_rounded,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              'Pro tip: Put your phone face down and start with one clear task.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InsightHeader(),
          const SizedBox(height: 22),
          const ProductivityScoreCard()
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.08),
          const SizedBox(height: 22),
          const WeeklyReportCard(),
          const SizedBox(height: 22),
          const FocusStreakCard(),
          const SizedBox(height: 22),
          const FocusCalendarCard(),
          const SizedBox(height: 22),
          const SessionHistoryCard(),
          const SizedBox(height: 22),
          const InsightSummaryGrid(),
          const SizedBox(height: 24),
          const SectionTitle(title: 'App Usage'),
          const SizedBox(height: 14),
          const AppUsageCard(),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Recommendations'),
          const SizedBox(height: 14),
          const RecommendationCard(),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Recent Achievements'),
          const SizedBox(height: 14),
          const RecentAchievementsList(),
        ],
      ),
    );
  }
}

class InsightHeader extends StatelessWidget {
  const InsightHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Insights',
                style: TextStyle(
                  color: ffTitleColor(),
                  fontSize: 34,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your weekly productivity report',
                style: TextStyle(
                  color: ffSubtitleColor(),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.calendar_month_rounded,
            color: Color(0xFF4E7DFF),
          ),
        ),
      ],
    );
  }
}

class ProductivityScoreCard extends StatelessWidget {
  const ProductivityScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: focusFlowTotalSessions,
      builder: (context, totalSessions, _) {
        return ValueListenableBuilder<int>(
          valueListenable: focusFlowTotalFocusMinutes,
          builder: (context, totalMinutes, _) {
            final score =
                totalSessions == 0 ? 0 : min(99, 70 + totalSessions * 3);

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF17233D),
                    Color(0xFF4E7DFF),
                    Color(0xFF8364FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4E7DFF).withOpacity(0.28),
                    blurRadius: 34,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -35,
                    top: -35,
                    child: Container(
                      width: 125,
                      height: 125,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.09),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.trending_up_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Productivity Score',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF35C99F).withOpacity(0.18),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              totalSessions == 0 ? 'NEW' : '+$totalSessions',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        '$score',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 56,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        totalSessions == 0
                            ? 'Complete a focus session to build your score'
                            : '${formatFocusMinutes(totalMinutes)} focused across $totalSessions sessions',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.78),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 22),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: score / 100,
                          minHeight: 10,
                          backgroundColor: Colors.white.withOpacity(0.18),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class WeeklyReportCard extends StatelessWidget {
  const WeeklyReportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: focusFlowSessionHistory,
      builder: (context, sessionHistory, _) {
        final dates = List.generate(
          7,
          (index) => DateTime.now().subtract(Duration(days: 6 - index)),
        );
        final days = dates.map(focusFlowMinutesForDay).toList();
        final totalMinutes =
            days.fold<int>(0, (total, minutes) => total + minutes);

        final maxMinutes = days.fold<int>(
          1,
          (highest, value) => value > highest ? value : highest,
        );

        return Container(
          padding: const EdgeInsets.all(22),
          decoration: cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Weekly Focus',
                    style: TextStyle(
                      color: ffTitleColor(),
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formatFocusMinutes(totalMinutes),
                    style: const TextStyle(
                      color: Color(0xFF4E7DFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 190,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    DayBar(
                      day: focusFlowWeekdayLabel(dates[0]),
                      value: days[0] / maxMinutes,
                      hours: formatFocusMinutes(days[0]),
                    ),
                    DayBar(
                      day: focusFlowWeekdayLabel(dates[1]),
                      value: days[1] / maxMinutes,
                      hours: formatFocusMinutes(days[1]),
                    ),
                    DayBar(
                      day: focusFlowWeekdayLabel(dates[2]),
                      value: days[2] / maxMinutes,
                      hours: formatFocusMinutes(days[2]),
                    ),
                    DayBar(
                      day: focusFlowWeekdayLabel(dates[3]),
                      value: days[3] / maxMinutes,
                      hours: formatFocusMinutes(days[3]),
                    ),
                    DayBar(
                      day: focusFlowWeekdayLabel(dates[4]),
                      value: days[4] / maxMinutes,
                      hours: formatFocusMinutes(days[4]),
                    ),
                    DayBar(
                      day: focusFlowWeekdayLabel(dates[5]),
                      value: days[5] / maxMinutes,
                      hours: formatFocusMinutes(days[5]),
                    ),
                    DayBar(
                      day: focusFlowWeekdayLabel(dates[6]),
                      value: days[6] / maxMinutes,
                      hours: formatFocusMinutes(days[6]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DayBar extends StatelessWidget {
  final String day;
  final double value;
  final String hours;

  const DayBar({
    super.key,
    required this.day,
    required this.value,
    required this.hours,
  });

  @override
  Widget build(BuildContext context) {
    final isBestDay = value > 0.85;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            hours,
            style: TextStyle(
              color: ffSubtitleColor(),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 24,
            height: 120 * value,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              gradient: LinearGradient(
                colors: isBestDay
                    ? const [Color(0xFFFFB84D), Color(0xFFFF8A3D)]
                    : const [Color(0xFF4E7DFF), Color(0xFF8364FF)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: isBestDay
                      ? const Color(0xFFFFB84D).withOpacity(0.25)
                      : const Color(0xFF4E7DFF).withOpacity(0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            day,
            style: TextStyle(
              color: ffSubtitleColor(),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class FocusStreakCard extends StatelessWidget {
  const FocusStreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: focusFlowSessionHistory,
      builder: (context, sessionHistory, _) {
        final streak = focusFlowCurrentStreakDays();
        final todayMinutes = focusFlowMinutesForDay(DateTime.now());

        return Container(
          padding: const EdgeInsets.all(22),
          decoration: cardDecoration(),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A3D).withOpacity(0.14),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFFF8A3D),
                  size: 32,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$streak day streak',
                      style: TextStyle(
                        color: ffTitleColor(),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      todayMinutes == 0
                          ? 'Finish a focus session today to start building it.'
                          : '${formatFocusMinutes(todayMinutes)} focused today.',
                      style: TextStyle(
                        color: ffSubtitleColor(),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FocusCalendarCard extends StatelessWidget {
  const FocusCalendarCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: focusFlowSessionHistory,
      builder: (context, sessionHistory, _) {
        final dates = List.generate(
          14,
          (index) => DateTime.now().subtract(Duration(days: 13 - index)),
        );

        return Container(
          padding: const EdgeInsets.all(22),
          decoration: cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Focus Calendar',
                style: TextStyle(
                  color: ffTitleColor(),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dates.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) {
                  final date = dates[index];
                  final minutes = focusFlowMinutesForDay(date);
                  final hasFocus = minutes > 0;

                  return Container(
                    decoration: BoxDecoration(
                      color: hasFocus
                          ? const Color(0xFF35C99F).withOpacity(0.16)
                          : focusFlowDarkMode.value
                              ? const Color(0xFF1A2340)
                              : const Color(0xFFF3F6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: hasFocus
                            ? const Color(0xFF35C99F).withOpacity(0.45)
                            : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          focusFlowWeekdayLabel(date),
                          style: TextStyle(
                            color: ffSubtitleColor(),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            color: hasFocus
                                ? const Color(0xFF35C99F)
                                : ffTitleColor(),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class SessionHistoryCard extends StatelessWidget {
  const SessionHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: focusFlowSessionHistory,
      builder: (context, sessionHistory, _) {
        final sessions = focusFlowSessions().take(5).toList();

        return Container(
          padding: const EdgeInsets.all(22),
          decoration: cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Session History',
                style: TextStyle(
                  color: ffTitleColor(),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              if (sessions.isEmpty)
                Text(
                  'Complete a focus timer to see your sessions here.',
                  style: TextStyle(
                    color: ffSubtitleColor(),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                for (final session in sessions) ...[
                  SessionHistoryRow(session: session),
                  if (session != sessions.last) const SizedBox(height: 12),
                ],
            ],
          ),
        );
      },
    );
  }
}

class SessionHistoryRow extends StatelessWidget {
  final FocusFlowSessionEntry session;

  const SessionHistoryRow({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final note = session.note.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF4E7DFF).withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.timer_rounded,
            color: Color(0xFF4E7DFF),
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${session.mode} • ${formatFocusMinutes(session.minutes)}',
                style: TextStyle(
                  color: ffTitleColor(),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                note.isEmpty
                    ? focusFlowDayKey(session.startedAt)
                    : '$note • ${focusFlowDayKey(session.startedAt)}',
                style: TextStyle(
                  color: ffSubtitleColor(),
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class InsightSummaryGrid extends StatelessWidget {
  const InsightSummaryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: focusFlowTotalSessions,
      builder: (context, totalSessions, _) {
        return ValueListenableBuilder<int>(
          valueListenable: focusFlowTotalFocusMinutes,
          builder: (context, totalMinutes, _) {
            final blocks = totalSessions * 3;

            return Row(
              children: [
                Expanded(
                  child: InsightSmallStat(
                    icon: Icons.timer_rounded,
                    value: formatFocusMinutes(totalMinutes),
                    label: 'Focus Time',
                    color: const Color(0xFF4E7DFF),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: InsightSmallStat(
                    icon: Icons.check_circle_rounded,
                    value: '$totalSessions',
                    label: 'Sessions',
                    color: const Color(0xFF35C99F),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: InsightSmallStat(
                    icon: Icons.block_rounded,
                    value: '$blocks',
                    label: 'Blocks',
                    color: const Color(0xFFFF8A3D),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class InsightSmallStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const InsightSmallStat({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 10,
      ),
      decoration: cardDecoration(),
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.13),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: ffTitleColor(),
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ffSubtitleColor(),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class AppUsageCard extends StatelessWidget {
  const AppUsageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Column(
        children: [
          AppUsageRow(
            icon: Icons.camera_alt_rounded,
            appName: 'Instagram',
            time: '1h 24m',
            value: 0.72,
            color: Color(0xFFFF6B9A),
          ),
          SizedBox(height: 17),
          AppUsageRow(
            icon: Icons.music_note_rounded,
            appName: 'TikTok',
            time: '52m',
            value: 0.48,
            color: Color(0xFF111827),
          ),
          SizedBox(height: 17),
          AppUsageRow(
            icon: Icons.play_arrow_rounded,
            appName: 'YouTube',
            time: '41m',
            value: 0.36,
            color: Color(0xFFFF3B30),
          ),
          SizedBox(height: 17),
          AppUsageRow(
            icon: Icons.chat_bubble_rounded,
            appName: 'Messages',
            time: '25m',
            value: 0.22,
            color: Color(0xFF35C99F),
          ),
        ],
      ),
    );
  }
}

class AppUsageRow extends StatelessWidget {
  final IconData icon;
  final String appName;
  final String time;
  final double value;
  final Color color;

  const AppUsageRow({
    super.key,
    required this.icon,
    required this.appName,
    required this.time,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 23,
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      appName,
                      style: TextStyle(
                        color: ffTitleColor(),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      color: ffSubtitleColor(),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: focusFlowDarkMode.value
                      ? Colors.white.withOpacity(0.10)
                      : const Color(0xFFEFF3FF),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;

    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171A22) : const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.07) : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.35)
                : const Color(0xFFFFB84D).withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB84D).withOpacity(isDark ? 0.20 : 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Color(0xFFFFB84D),
              size: 29,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              'Your best focus window is between 9 AM and 12 PM. Schedule your hardest task there.',
              style: TextStyle(
                color: ffTitleColor(),
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileHeaderCard()
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.08),
          const SizedBox(height: 22),
          const ProfileStatGrid(),
          const SizedBox(height: 24),
          const LevelProgressCard(),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Achievements'),
          const SizedBox(height: 14),
          const ProfileAchievementPreview(),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Preferences'),
          const SizedBox(height: 14),
          const ProfileEditCard(),
          const SizedBox(height: 12),
          const NotificationsSettingTile(),
          const SizedBox(height: 12),
          const DarkModeSettingTile(),
          const SizedBox(height: 12),
          const FocusFlowDailyGoalSettingCard(),
          const SizedBox(height: 12),
          const AppBlockingSettingTile(),
          const SizedBox(height: 12),
          const SectionTitle(title: 'Account'),
          const SizedBox(height: 14),
          const ProfileAccountCard(),
          const SizedBox(height: 12),
          const FocusFlowDataSettingsCard(),
          const SizedBox(height: 22),
          const ProfilePremiumBanner(),
          const SizedBox(height: 14),
          const ProfileLogoutButton(),
        ],
      ),
    );
  }
}

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: focusFlowIsPro,
      builder: (context, isPro, _) {
        return ValueListenableBuilder<String>(
          valueListenable: focusFlowPremiumPlan,
          builder: (context, selectedPlan, _) {
            return ValueListenableBuilder<int>(
              valueListenable: focusFlowTotalSessions,
              builder: (context, totalSessions, _) {
                return ValueListenableBuilder<List<String>>(
                  valueListenable: focusFlowCompletedTasks,
                  builder: (context, completedTasks, _) {
                    final xp =
                        (totalSessions * 120) + (completedTasks.length * 80);
                    final level = max(1, (xp ~/ 500) + 1);
                    final currentLevelXp = xp % 500;
                    final xpRemaining = 500 - currentLevelXp;

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(36),
                        gradient: LinearGradient(
                          colors: isPro
                              ? const [
                                  Color(0xFF35C99F),
                                  Color(0xFF4E7DFF),
                                  Color(0xFF8364FF),
                                ]
                              : const [
                                  Color(0xFF4E7DFF),
                                  Color(0xFF735CFF),
                                  Color(0xFF9A6BFF),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4E7DFF).withOpacity(0.35),
                            blurRadius: 36,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -34,
                            top: -34,
                            child: Container(
                              width: 128,
                              height: 128,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.10),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            left: -42,
                            bottom: -52,
                            child: Container(
                              width: 118,
                              height: 118,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  ValueListenableBuilder<String>(
                                    valueListenable: focusFlowProfileIcon,
                                    builder: (context, profileIcon, _) {
                                      return Container(
                                        width: 86,
                                        height: 86,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.12),
                                              blurRadius: 24,
                                              offset: const Offset(0, 12),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          focusFlowProfileIconData(profileIcon),
                                          color: isPro
                                              ? const Color(0xFF35C99F)
                                              : const Color(0xFF4E7DFF),
                                          size: 54,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ValueListenableBuilder<String>(
                                          valueListenable: focusFlowUserName,
                                          builder: (context, userName, _) {
                                            return Text(
                                              userName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 28,
                                                height: 1,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: -0.8,
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        ValueListenableBuilder<int>(
                                          valueListenable:
                                              focusFlowDailyGoalMinutes,
                                          builder: (context, goalMinutes, _) {
                                            return Text(
                                              isPro
                                                  ? 'Pro • $selectedPlan • ${formatFocusMinutes(goalMinutes)} goal'
                                                  : 'Free Member • ${formatFocusMinutes(goalMinutes)} daily goal',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        showFocusFlowEditProfileSheet(context),
                                    child: Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.16),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        isPro
                                            ? Icons.workspace_premium_rounded
                                            : Icons.edit_rounded,
                                        color: Colors.white,
                                        size: 21,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.emoji_events_rounded,
                                      color: Color(0xFFFFD166),
                                      size: 30,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Level $level Focus Builder',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$xpRemaining XP until next level',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                      child: Text(
                                        '$xp XP',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class ProfileEditCard extends StatelessWidget {
  const ProfileEditCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: const Color(0xFF4E7DFF).withOpacity(
                  focusFlowDarkMode.value ? 0.20 : 0.11,
                ),
                child: const Icon(
                  Icons.account_circle_rounded,
                  color: Color(0xFF6F8DFF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: ffTitleColor(),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Edit your display name and icon',
                      style: TextStyle(
                        color: ffSubtitleColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FocusFlowSettingsMiniButton(
                  icon: Icons.edit_rounded,
                  label: 'Edit Name',
                  onTap: () => showFocusFlowEditNameDialog(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FocusFlowSettingsMiniButton(
                  icon: Icons.face_rounded,
                  label: 'Edit Icon',
                  onTap: () => showFocusFlowEditProfileSheet(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileAccountCard extends StatelessWidget {
  const ProfileAccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: focusFlowUserEmail,
      builder: (context, userEmail, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: focusFlowIsPro,
          builder: (context, isPro, _) {
            return Container(
              padding: const EdgeInsets.all(17),
              decoration: cardDecoration(),
              child: Column(
                children: [
                  ProfileAccountRow(
                    icon: Icons.email_rounded,
                    title: 'Email',
                    value: userEmail.isEmpty ? 'Local account' : userEmail,
                  ),
                  const SizedBox(height: 14),
                  ProfileAccountRow(
                    icon: Icons.workspace_premium_rounded,
                    title: 'Plan',
                    value: isPro ? 'FocusFlow Pro' : 'Free',
                  ),
                  const SizedBox(height: 14),
                  ProfileAccountRow(
                    icon: Icons.storage_rounded,
                    title: 'Storage',
                    value: 'Saved locally',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class ProfileAccountRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ProfileAccountRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF6F8DFF),
          size: 21,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: ffSubtitleColor(),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: ffTitleColor(),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileStatGrid extends StatelessWidget {
  const ProfileStatGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: focusFlowCompletedTasks,
      builder: (context, completedTasks, _) {
        return ValueListenableBuilder<int>(
          valueListenable: focusFlowTotalFocusMinutes,
          builder: (context, totalMinutes, _) {
            return Row(
              children: [
                Expanded(
                  child: ProfileBigStat(
                    icon: Icons.check_circle_rounded,
                    value: '${completedTasks.length}',
                    label: 'Tasks Done',
                    color: const Color(0xFF35C99F),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ProfileBigStat(
                    icon: Icons.timer_rounded,
                    value: formatFocusMinutes(totalMinutes),
                    label: 'Focus Time',
                    color: const Color(0xFF4E7DFF),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class ProfileBigStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const ProfileBigStat({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(isDark ? 0.20 : 0.13),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              color: ffTitleColor(),
              fontSize: 30,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: TextStyle(
              color: ffSubtitleColor(),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class LevelProgressCard extends StatelessWidget {
  const LevelProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: focusFlowTotalSessions,
      builder: (context, totalSessions, _) {
        return ValueListenableBuilder<List<String>>(
          valueListenable: focusFlowCompletedTasks,
          builder: (context, completedTasks, _) {
            final xp = (totalSessions * 120) + (completedTasks.length * 80);
            final level = max(1, (xp ~/ 500) + 1);
            final currentLevelXp = xp % 500;
            final progress = currentLevelXp / 500;
            final xpRemaining = 500 - currentLevelXp;

            return Container(
              padding: const EdgeInsets.all(19),
              decoration: cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 23,
                        backgroundColor: const Color(0xFFFFB84D).withOpacity(
                          focusFlowDarkMode.value ? 0.20 : 0.16,
                        ),
                        child: const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB84D),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Level $level Focus Builder',
                              style: TextStyle(
                                color: ffTitleColor(),
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$xpRemaining XP until next level',
                              style: TextStyle(
                                color: ffSubtitleColor(),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$xp XP',
                        style: const TextStyle(
                          color: Color(0xFF4E7DFF),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 11,
                      backgroundColor: focusFlowDarkMode.value
                          ? const Color(0xFF1A2340)
                          : const Color(0xFFEFF3FF),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFFB84D),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class ProfileAchievementPreview extends StatelessWidget {
  const ProfileAchievementPreview({super.key});

  int calculateBadges({
    required int sessions,
    required int completedTasks,
    required bool isPro,
    required bool appBlocking,
  }) {
    int badges = 0;

    if (completedTasks >= 1) badges++;
    if (completedTasks >= 3) badges++;
    if (sessions >= 1) badges++;
    if (sessions >= 5) badges++;
    if (sessions >= 10) badges++;
    if (appBlocking) badges++;
    if (isPro) badges++;

    return badges;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: focusFlowTotalSessions,
      builder: (context, totalSessions, _) {
        return ValueListenableBuilder<List<String>>(
          valueListenable: focusFlowCompletedTasks,
          builder: (context, completedTasks, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: focusFlowAppBlocking,
              builder: (context, appBlocking, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: focusFlowIsPro,
                  builder: (context, isPro, _) {
                    final badges = calculateBadges(
                      sessions: totalSessions,
                      completedTasks: completedTasks.length,
                      isPro: isPro,
                      appBlocking: appBlocking,
                    );

                    final blocks = appBlocking ? totalSessions * 3 : 0;

                    return Row(
                      children: [
                        Expanded(
                          child: AchievementBadge(
                            icon: Icons.local_fire_department_rounded,
                            title: '$totalSessions',
                            subtitle:
                                totalSessions == 1 ? 'Session' : 'Sessions',
                            color: const Color(0xFFFF8A3D),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: AchievementBadge(
                            icon: Icons.shield_rounded,
                            title: '$blocks',
                            subtitle: 'Blocks',
                            color: const Color(0xFF4E7DFF),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: AchievementBadge(
                            icon: Icons.emoji_events_rounded,
                            title: '$badges',
                            subtitle: 'Badges',
                            color: const Color(0xFFFFB84D),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const AchievementBadge({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 8,
      ),
      decoration: cardDecoration(),
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(isDark ? 0.20 : 0.13),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: ffTitleColor(),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(
              color: ffSubtitleColor(),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailingText;
  final VoidCallback? onTap;

  const ProfileSettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailingText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;

    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: cardDecoration(),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: const Color(0xFF4E7DFF).withOpacity(
                isDark ? 0.20 : 0.11,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF6F8DFF),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: ffTitleColor(),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: ffSubtitleColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingText != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: ffSoftPillColor(),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  trailingText!,
                  style: TextStyle(
                    color: Color(0xFF6F8DFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            else if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? Colors.white.withOpacity(0.45)
                    : const Color(0xFFADB5D1),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class DarkModeSettingTile extends StatelessWidget {
  const DarkModeSettingTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: focusFlowDarkMode,
      builder: (context, isDark, _) {
        return GestureDetector(
          onTap: () {
            saveFocusFlowDarkMode(!focusFlowDarkMode.value);
          },
          child: Container(
            padding: const EdgeInsets.all(17),
            decoration: cardDecoration(),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: const Color(0xFF4E7DFF).withOpacity(0.11),
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: const Color(0xFF4E7DFF),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dark Mode',
                        style: TextStyle(
                          color: ffTitleColor(),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Switch app appearance',
                        style: TextStyle(
                          color: ffSubtitleColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isDark,
                  activeColor: const Color(0xFF4E7DFF),
                  onChanged: (value) {
                    saveFocusFlowDarkMode(value);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NotificationsSettingTile extends StatelessWidget {
  const NotificationsSettingTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: focusFlowNotifications,
      builder: (context, notificationsOn, _) {
        return GestureDetector(
          onTap: () {
            saveFocusFlowNotifications(!notificationsOn);
          },
          child: Container(
            padding: const EdgeInsets.all(17),
            decoration: cardDecoration(),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: const Color(0xFF4E7DFF).withOpacity(
                    focusFlowDarkMode.value ? 0.20 : 0.11,
                  ),
                  child: Icon(
                    notificationsOn
                        ? Icons.notifications_rounded
                        : Icons.notifications_off_rounded,
                    color: const Color(0xFF6F8DFF),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifications',
                        style: TextStyle(
                          color: ffTitleColor(),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notificationsOn
                            ? 'Focus reminders and alerts are on'
                            : 'Focus reminders are muted',
                        style: TextStyle(
                          color: ffSubtitleColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: notificationsOn,
                  activeColor: const Color(0xFF4E7DFF),
                  onChanged: saveFocusFlowNotifications,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AppBlockingSettingTile extends StatelessWidget {
  const AppBlockingSettingTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: focusFlowAppBlocking,
      builder: (context, isBlocking, _) {
        return GestureDetector(
          onTap: () {
            saveFocusFlowAppBlocking(!isBlocking);
          },
          child: Container(
            padding: const EdgeInsets.all(17),
            decoration: cardDecoration(),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: const Color(0xFF4E7DFF).withOpacity(
                    focusFlowDarkMode.value ? 0.20 : 0.11,
                  ),
                  child: Icon(
                    isBlocking ? Icons.shield_rounded : Icons.shield_outlined,
                    color: const Color(0xFF6F8DFF),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Blocking',
                        style: TextStyle(
                          color: ffTitleColor(),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isBlocking
                            ? 'Distraction shield is active'
                            : 'Distraction shield is paused',
                        style: TextStyle(
                          color: ffSubtitleColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isBlocking,
                  activeColor: const Color(0xFF4E7DFF),
                  onChanged: saveFocusFlowAppBlocking,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;

    return GestureDetector(
      onTap: logoutFocusFlow,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2340) : const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.07)
                : const Color(0xFFFFD1D1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout_rounded,
              color: Color(0xFFFF6B6B),
              size: 21,
            ),
            const SizedBox(width: 8),
            Text(
              'Log Out',
              style: TextStyle(
                color:
                    isDark ? const Color(0xFFFF8A8A) : const Color(0xFFFF4D4D),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePremiumBanner extends StatelessWidget {
  const ProfilePremiumBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: focusFlowIsPro,
      builder: (context, isPro, _) {
        return ValueListenableBuilder<String>(
          valueListenable: focusFlowPremiumPlan,
          builder: (context, selectedPlan, _) {
            return GestureDetector(
              onTap: () => focusFlowCurrentTab.value = 4,
              child: Container(
                padding: const EdgeInsets.all(19),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: isPro
                        ? const [
                            Color(0xFF35C99F),
                            Color(0xFF4E7DFF),
                          ]
                        : const [
                            Color(0xFF17233D),
                            Color(0xFF4E7DFF),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4E7DFF).withOpacity(0.22),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        isPro
                            ? Icons.verified_rounded
                            : Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 29,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPro ? 'FocusFlow Pro Active' : 'FocusFlow Pro',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isPro
                                ? '$selectedPlan plan unlocked'
                                : 'Unlock premium benefits',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumHeader(),
          const SizedBox(height: 22),
          const PremiumHeroCard()
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.08),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Choose Your Plan'),
          const SizedBox(height: 14),
          const PremiumPlanSelector(),
          const SizedBox(height: 24),
          const SectionTitle(title: 'What You Unlock'),
          const SizedBox(height: 14),
          const PremiumBenefitsList(),
          const SizedBox(height: 24),
          const PremiumComparisonCard(),
          const SizedBox(height: 24),
          const PremiumReviewCard(),
          const SizedBox(height: 24),
          const PremiumCTA(),
          const SizedBox(height: 14),
          const PremiumSecureNote(),
        ],
      ),
    );
  }
}

class PremiumHeader extends StatelessWidget {
  const PremiumHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Go Premium',
                style: TextStyle(
                  color: ffTitleColor(),
                  fontSize: 34,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Unlock your full focus system',
                style: TextStyle(
                  color: ffSubtitleColor(),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFB84D), Color(0xFFFF8A3D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB84D).withOpacity(0.25),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ],
    );
  }
}

class PremiumHeroCard extends StatelessWidget {
  const PremiumHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(38),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF111827),
            Color(0xFF2F4FFF),
            Color(0xFF8A63FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4E7DFF).withOpacity(0.32),
            blurRadius: 38,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -42,
            top: -42,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.09),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -58,
            bottom: -70,
            child: Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FocusFlow Pro',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            height: 1,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Built for serious focus',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Block distractions.\nTrack progress.\nFocus deeper.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Upgrade to unlock advanced analytics, unlimited focus sessions, custom blocking, and premium themes.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.78),
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  PremiumHeroChip(
                    icon: Icons.shield_rounded,
                    label: 'App blocking',
                  ),
                  SizedBox(width: 10),
                  PremiumHeroChip(
                    icon: Icons.bar_chart_rounded,
                    label: 'Analytics',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PremiumHeroChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const PremiumHeroChip({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 17),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PremiumPlanSelector extends StatelessWidget {
  const PremiumPlanSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: focusFlowPremiumPlan,
      builder: (context, selectedPlan, _) {
        return Column(
          children: [
            PremiumPlanCard(
              title: 'Monthly',
              price: '\$4.99',
              subtitle: 'Flexible access',
              badge: 'Starter',
              selected: selectedPlan == 'Monthly',
              onTap: () => saveFocusFlowPremiumPlan('Monthly'),
            ),
            const SizedBox(height: 14),
            PremiumPlanCard(
              title: 'Yearly',
              price: '\$29.99',
              subtitle: 'Best value for focus builders',
              badge: 'Save 50%',
              selected: selectedPlan == 'Yearly',
              onTap: () => saveFocusFlowPremiumPlan('Yearly'),
            ),
          ],
        );
      },
    );
  }
}

class PremiumPlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final String badge;
  final bool selected;
  final VoidCallback onTap;

  const PremiumPlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.subtitle,
    required this.badge,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 230),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF4E7DFF)
              : isDark
                  ? const Color(0xFF11182D)
                  : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected
                ? const Color(0xFF8EA7FF)
                : isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.transparent,
            width: selected ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? const Color(0xFF4E7DFF).withOpacity(0.30)
                  : isDark
                      ? Colors.black.withOpacity(0.35)
                      : Colors.black.withOpacity(0.045),
              blurRadius: 26,
              offset: const Offset(0, 13),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 230),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? Colors.white
                      : isDark
                          ? Colors.white.withOpacity(0.18)
                          : const Color(0xFFD9DEF0),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF4E7DFF),
                      size: 19,
                    )
                  : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: selected ? Colors.white : ffTitleColor(),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: selected ? Colors.white70 : ffSubtitleColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withOpacity(0.16)
                        : const Color(0xFF4E7DFF).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF6F8DFF),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: TextStyle(
                    color: selected ? Colors.white : ffTitleColor(),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PremiumBenefitsList extends StatelessWidget {
  const PremiumBenefitsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      child: Column(
        children: [
          PremiumBenefitTile(
            icon: Icons.all_inclusive_rounded,
            title: 'Unlimited Focus Sessions',
            subtitle: 'Create as many timers and routines as you want',
            color: Color(0xFF4E7DFF),
          ),
          PremiumDividerLine(),
          PremiumBenefitTile(
            icon: Icons.block_rounded,
            title: 'Advanced App Blocking',
            subtitle: 'Custom block lists for work, school, and sleep',
            color: Color(0xFFFF8A3D),
          ),
          PremiumDividerLine(),
          PremiumBenefitTile(
            icon: Icons.insights_rounded,
            title: 'Deep Analytics',
            subtitle: 'Weekly trends, focus score, and productivity insights',
            color: Color(0xFF35C99F),
          ),
          PremiumDividerLine(),
          PremiumBenefitTile(
            icon: Icons.palette_rounded,
            title: 'Premium Themes',
            subtitle: 'Unlock custom colors, icons, and app styles',
            color: Color(0xFF9A6BFF),
          ),
          PremiumDividerLine(),
          PremiumBenefitTile(
            icon: Icons.cloud_sync_rounded,
            title: 'Cloud Sync',
            subtitle: 'Keep your progress synced across devices',
            color: Color(0xFF00A9FF),
          ),
        ],
      ),
    );
  }
}

class PremiumBenefitTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const PremiumBenefitTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(17),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.13),
            child: Icon(
              icon,
              color: color,
              size: 23,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: ffTitleColor(),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: ffSubtitleColor(),
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF35C99F),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumDividerLine extends StatelessWidget {
  const PremiumDividerLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      color: focusFlowDarkMode.value
          ? Colors.white.withOpacity(0.08)
          : const Color(0xFFEFF3FF),
    );
  }
}

class PremiumComparisonCard extends StatelessWidget {
  const PremiumComparisonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Free vs Pro',
            style: TextStyle(
              color: ffTitleColor(),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          const PremiumCompareRow(
            label: 'Focus sessions',
            free: '5/day',
            pro: 'Unlimited',
          ),
          const PremiumCompareRow(
            label: 'App block lists',
            free: '1',
            pro: 'Unlimited',
          ),
          const PremiumCompareRow(
            label: 'Analytics history',
            free: '7 days',
            pro: 'Lifetime',
          ),
          const PremiumCompareRow(
            label: 'Themes',
            free: 'Basic',
            pro: 'Premium',
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class PremiumCompareRow extends StatelessWidget {
  final String label;
  final String free;
  final String pro;
  final bool showDivider;

  const PremiumCompareRow({
    super.key,
    required this.label,
    required this.free,
    required this.pro,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: ffTitleColor(),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(
              width: 74,
              child: Text(
                free,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ffSubtitleColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(
              width: 88,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4E7DFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  pro,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4E7DFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 13),
          Container(
            height: 1,
            color: focusFlowDarkMode.value
                ? Colors.white.withOpacity(0.08)
                : const Color(0xFFEFF3FF),
          ),
          const SizedBox(height: 13),
        ],
      ],
    );
  }
}

class PremiumReviewCard extends StatelessWidget {
  const PremiumReviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;

    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171A22) : const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? const Color(0xFFFFB84D).withOpacity(0.18)
              : const Color(0xFFFFB84D).withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB84D).withOpacity(isDark ? 0.08 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB84D).withOpacity(0.22),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Color(0xFFFFA000),
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loved by focused people',
                  style: TextStyle(
                    color: ffTitleColor(),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '“This helped me stop wasting time and actually finish my work.”',
                  style: TextStyle(
                    color: ffSubtitleColor(),
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumCTA extends StatelessWidget {
  const PremiumCTA({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: focusFlowIsPro,
      builder: (context, isPro, _) {
        return ValueListenableBuilder<String>(
          valueListenable: focusFlowPremiumPlan,
          builder: (context, selectedPlan, _) {
            final isYearly = selectedPlan == 'Yearly';
            final price = isYearly ? '\$29.99/year' : '\$4.99/month';

            return PressableScale(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return PremiumConfirmationSheet(
                      selectedPlan: selectedPlan,
                      price: price,
                    );
                  },
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    colors: isPro
                        ? const [
                            Color(0xFF35C99F),
                            Color(0xFF4E7DFF),
                          ]
                        : ffBrandGradientColors(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4E7DFF).withOpacity(0.35),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isPro
                          ? Icons.verified_rounded
                          : Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 9),
                    Text(
                      isPro
                          ? 'Pro Active: $selectedPlan'
                          : 'Donate with Stripe',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class PremiumConfirmationSheet extends StatelessWidget {
  final String selectedPlan;
  final String price;

  const PremiumConfirmationSheet({
    super.key,
    required this.selectedPlan,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.45 : 0.14),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 5,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.18)
                    : const Color(0xFFD9DEF0),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4E7DFF),
                    Color(0xFF8364FF),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '$selectedPlan Plan Selected',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ffTitleColor(),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You selected FocusFlow Pro for $price. Checkout opens securely through Stripe.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ffSubtitleColor(),
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 22),
            PressableScale(
              onTap: () async {
                Navigator.pop(context);
                await openFocusFlowStripeDonation();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: ffBrandGradientColors(),
                  ),
                ),
                child: const Text(
                  'Continue to Stripe',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showFocusFlowProLockedSheet(BuildContext context) {
  final isDark = focusFlowDarkMode.value;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.45 : 0.14),
              blurRadius: 34,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.18)
                      : const Color(0xFFD9DEF0),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4E7DFF),
                      Color(0xFF8364FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Pro Feature Locked',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ffTitleColor(),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upgrade to FocusFlow Pro to unlock Deep Work, extra tasks, advanced insights, and more.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ffSubtitleColor(),
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  focusFlowCurrentTab.value = 4;
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4E7DFF),
                        Color(0xFF8364FF),
                      ],
                    ),
                  ),
                  child: const Text(
                    'Go to Pro Tab',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class PremiumSecureNote extends StatelessWidget {
  const PremiumSecureNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_rounded,
            color: ffSubtitleColor(),
            size: 16,
          ),
          SizedBox(width: 6),
          Text(
            'Cancel anytime. Secure payment.',
            style: TextStyle(
              color: ffSubtitleColor(),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class AppPage extends StatelessWidget {
  final Widget child;

  const AppPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;

    return Container(
      key: key,
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: ffPageGradientColors(isDark),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _FocusFlowAtmosphere()),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 112),
              child: child
                  .animate()
                  .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic)
                  .slideY(
                    begin: 0.035,
                    end: 0,
                    duration: 320.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusFlowAtmosphere extends StatelessWidget {
  const _FocusFlowAtmosphere();

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;

    return IgnorePointer(
      child: CustomPaint(
        painter: _FocusFlowAtmospherePainter(isDark: isDark),
      ),
    );
  }
}

class _FocusFlowAtmospherePainter extends CustomPainter {
  final bool isDark;

  const _FocusFlowAtmospherePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFF0F172A))
          .withOpacity(isDark ? 0.035 : 0.028)
      ..strokeWidth = 1;

    for (var x = -size.height; x < size.width; x += 34) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        linePaint,
      );
    }

    final topBand = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF17BEBB).withOpacity(isDark ? 0.18 : 0.14),
          const Color(0xFF2563EB).withOpacity(isDark ? 0.10 : 0.08),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(-size.width * 0.15, 0, size.width * 1.25, 220),
      );

    final bottomBand = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFFFF8A3D).withOpacity(isDark ? 0.11 : 0.09),
          const Color(0xFF17BEBB).withOpacity(isDark ? 0.10 : 0.07),
        ],
      ).createShader(
        Rect.fromLTWH(0, size.height * 0.58, size.width, size.height * 0.42),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, 220),
      topBand,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.58, size.width, size.height * 0.42),
      bottomBand,
    );
  }

  @override
  bool shouldRepaint(covariant _FocusFlowAtmospherePainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

class TopHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const TopHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 31,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: ffTitleColor(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  color: ffSubtitleColor(),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        PressableScale(
          onTap: () => showFocusFlowGlobalMessage('Notifications are ready.'),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ffCardColor(),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: focusFlowDarkMode.value
                    ? Colors.white.withOpacity(0.08)
                    : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    focusFlowDarkMode.value ? 0.22 : 0.05,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF17A99E),
            ),
          ),
        ),
      ],
    );
  }
}

class MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const MiniStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: ffTitleColor(),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: ffSubtitleColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.08);
  }
}

Future<void> showFocusFlowTaskDialog(
  BuildContext context, {
  FocusFlowTaskItem? task,
}) async {
  final titleController = TextEditingController(text: task?.title ?? '');
  final subtitleController = TextEditingController(text: task?.subtitle ?? '');
  final selectedPriority = ValueNotifier<String>(task?.priority ?? 'Medium');
  final selectedEstimate = ValueNotifier<int>(task?.estimateMinutes ?? 25);
  final isEditing = task != null;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          bottom: MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: ffCardColor(),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: focusFlowDarkMode.value
                  ? Colors.white.withOpacity(0.08)
                  : Colors.transparent,
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Task' : 'Add Task',
                  style: TextStyle(
                    color: ffTitleColor(),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                OnboardingTextField(
                  controller: titleController,
                  icon: Icons.task_alt_rounded,
                  hint: 'Task name',
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                OnboardingTextField(
                  controller: subtitleController,
                  icon: Icons.notes_rounded,
                  hint: 'Short note',
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),
                Text(
                  'Priority',
                  style: TextStyle(
                    color: ffTitleColor(),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder<String>(
                  valueListenable: selectedPriority,
                  builder: (context, priorityValue, _) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final priority in const ['High', 'Medium', 'Low'])
                          FocusFlowSettingsChoiceChip(
                            label: priority,
                            selected: priorityValue == priority,
                            onTap: () {
                              selectedPriority.value = priority;
                            },
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Estimated Time',
                  style: TextStyle(
                    color: ffTitleColor(),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder<int>(
                  valueListenable: selectedEstimate,
                  builder: (context, estimateValue, _) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final minutes in const [15, 25, 50, 90])
                          FocusFlowSettingsChoiceChip(
                            label: formatFocusMinutes(minutes),
                            selected: estimateValue == minutes,
                            onTap: () {
                              selectedEstimate.value = minutes;
                            },
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                OnboardingButton(
                  text: isEditing ? 'Save Task' : 'Add Task',
                  onPressed: () async {
                    if (isEditing) {
                      await updateFocusFlowTask(
                        task.id,
                        titleController.text,
                        subtitleController.text,
                        priority: selectedPriority.value,
                        estimateMinutes: selectedEstimate.value,
                      );
                    } else {
                      await addFocusFlowTask(
                        titleController.text,
                        subtitleController.text,
                        priority: selectedPriority.value,
                        estimateMinutes: selectedEstimate.value,
                      );
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  titleController.dispose();
  subtitleController.dispose();
}

class FocusFlowProductivityOverviewCard extends StatelessWidget {
  const FocusFlowProductivityOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: focusFlowSessionHistory,
      builder: (context, sessionHistory, _) {
        return ValueListenableBuilder<List<String>>(
          valueListenable: focusFlowTodayTasks,
          builder: (context, todayTasks, _) {
            return ValueListenableBuilder<List<String>>(
              valueListenable: focusFlowCompletedTasks,
              builder: (context, completedTasks, _) {
                return ValueListenableBuilder<int>(
                  valueListenable: focusFlowDailyGoalMinutes,
                  builder: (context, dailyGoalMinutes, _) {
                    final todayMinutes = focusFlowMinutesForDay(DateTime.now());
                    final focusProgress = dailyGoalMinutes <= 0
                        ? 0.0
                        : (todayMinutes / dailyGoalMinutes).clamp(0.0, 1.0);
                    final plannedMinutes = focusFlowTotalPlannedMinutes();
                    final completedPlannedMinutes =
                        focusFlowCompletedPlannedMinutes();
                    final planProgress = plannedMinutes <= 0
                        ? 0.0
                        : (completedPlannedMinutes / plannedMinutes)
                            .clamp(0.0, 1.0);

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 23,
                                backgroundColor:
                                    const Color(0xFF35C99F).withOpacity(
                                  focusFlowDarkMode.value ? 0.20 : 0.12,
                                ),
                                child: const Icon(
                                  Icons.insights_rounded,
                                  color: Color(0xFF35C99F),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Today’s Productivity',
                                      style: TextStyle(
                                        color: ffTitleColor(),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${formatFocusMinutes(todayMinutes)} focused • ${formatFocusMinutes(completedPlannedMinutes)} planned done',
                                      style: TextStyle(
                                        color: ffSubtitleColor(),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          FocusFlowProgressLine(
                            label: 'Daily focus goal',
                            value:
                                '${formatFocusMinutes(todayMinutes)} / ${formatFocusMinutes(dailyGoalMinutes)}',
                            progress: focusProgress,
                            color: const Color(0xFF35C99F),
                          ),
                          const SizedBox(height: 14),
                          FocusFlowProgressLine(
                            label: 'Planned workload',
                            value:
                                '${formatFocusMinutes(completedPlannedMinutes)} / ${formatFocusMinutes(plannedMinutes)}',
                            progress: planProgress,
                            color: const Color(0xFF4E7DFF),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class FocusFlowProgressLine extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final Color color;

  const FocusFlowProgressLine({
    super.key,
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: ffTitleColor(),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: ffSubtitleColor(),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            backgroundColor: focusFlowDarkMode.value
                ? const Color(0xFF1A2340)
                : const Color(0xFFEFF3FF),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class InteractiveTodayPlan extends StatelessWidget {
  const InteractiveTodayPlan({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: focusFlowTodayTasks,
      builder: (context, todayTasks, _) {
        return ValueListenableBuilder<List<String>>(
          valueListenable: focusFlowCompletedTasks,
          builder: (context, completedTasks, _) {
            final tasks = focusFlowTasks();
            final completedCount = tasks
                .where((task) => completedTasks.contains(task.id))
                .length
                .clamp(0, tasks.length);

            return Column(
              children: [
                for (final task in tasks) ...[
                  InteractiveTaskTile(
                    id: task.id,
                    title: task.title,
                    subtitle: task.subtitle,
                    priority: task.priority,
                    estimateMinutes: task.estimateMinutes,
                    icon: Icons.checklist_rounded,
                    completed: completedTasks.contains(task.id),
                    locked: false,
                    onEdit: () => showFocusFlowTaskDialog(context, task: task),
                    onDelete: () => deleteFocusFlowTask(task.id),
                  ),
                  const SizedBox(height: 14),
                ],
                GestureDetector(
                  onTap: () => showFocusFlowTaskDialog(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4E7DFF).withOpacity(0.11),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFF4E7DFF).withOpacity(0.20),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          color: Color(0xFF4E7DFF),
                          size: 21,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Add Task',
                          style: TextStyle(
                            color: Color(0xFF4E7DFF),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (completedCount > 0 || tasks.length != 3) ...[
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: resetFocusFlowTodayPlan,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: focusFlowDarkMode.value
                            ? const Color(0xFF1A2340)
                            : const Color(0xFFF3F6FF),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: focusFlowDarkMode.value
                              ? Colors.white.withOpacity(0.07)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.refresh_rounded,
                            color: Color(0xFF6F8DFF),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Reset Today’s Plan',
                            style: TextStyle(
                              color: ffTitleColor(),
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class InteractiveTaskTile extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final String priority;
  final int estimateMinutes;
  final IconData icon;
  final bool completed;
  final bool locked;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const InteractiveTaskTile({
    super.key,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.priority,
    required this.estimateMinutes,
    required this.icon,
    required this.completed,
    required this.locked,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;

    return GestureDetector(
      onTap: () {
        if (locked) {
          showFocusFlowProLockedSheet(context);
        } else {
          toggleFocusFlowTask(id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: locked
              ? isDark
                  ? const Color(0xFF161E34)
                  : const Color(0xFFFFFBF0)
              : ffCardColor(),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: locked
                ? const Color(0xFFFFB84D).withOpacity(0.35)
                : isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.35)
                  : Colors.black.withOpacity(0.045),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Opacity(
          opacity: locked ? 0.75 : 1,
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: locked
                      ? const Color(0xFFFFB84D).withOpacity(0.16)
                      : completed
                          ? const Color(0xFF35C99F).withOpacity(0.16)
                          : const Color(0xFF4E7DFF).withOpacity(
                              isDark ? 0.20 : 0.11,
                            ),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Icon(
                  locked
                      ? Icons.lock_rounded
                      : completed
                          ? Icons.check_rounded
                          : icon,
                  color: locked
                      ? const Color(0xFFFFB84D)
                      : completed
                          ? const Color(0xFF35C99F)
                          : const Color(0xFF6F8DFF),
                  size: 27,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: completed ? ffSubtitleColor() : ffTitleColor(),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        decoration: completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      locked
                          ? 'Pro feature'
                          : completed
                              ? 'Completed'
                              : subtitle,
                      style: TextStyle(
                        color: locked
                            ? const Color(0xFFFFB84D)
                            : ffSubtitleColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!locked) ...[
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          FocusFlowTaskMetaChip(
                            label: priority,
                            icon: Icons.flag_rounded,
                            color: focusFlowPriorityColor(priority),
                          ),
                          FocusFlowTaskMetaChip(
                            label: formatFocusMinutes(estimateMinutes),
                            icon: Icons.schedule_rounded,
                            color: const Color(0xFF6F8DFF),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: completed
                      ? const Color(0xFF35C99F)
                      : locked
                          ? const Color(0xFFFFB84D).withOpacity(0.15)
                          : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: completed
                        ? const Color(0xFF35C99F)
                        : locked
                            ? const Color(0xFFFFB84D)
                            : isDark
                                ? Colors.white.withOpacity(0.18)
                                : const Color(0xFFD9DEF0),
                    width: 2,
                  ),
                ),
                child: completed
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 19,
                      )
                    : locked
                        ? const Icon(
                            Icons.lock_rounded,
                            color: Color(0xFFFFB84D),
                            size: 16,
                          )
                        : null,
              ),
              if (!locked) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onEdit,
                  child: Icon(
                    Icons.edit_rounded,
                    color: ffSubtitleColor(),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: const Color(0xFFFF6B6B).withOpacity(0.9),
                    size: 21,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FocusFlowTaskMetaChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const FocusFlowTaskMetaChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(focusFlowDarkMode.value ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final IconData icon;

  const TaskTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFF4E7DFF).withOpacity(0.11),
            child: Icon(icon, color: const Color(0xFF4E7DFF)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: ffTitleColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: ffSubtitleColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFE9EDFF),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4E7DFF),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFADB5D1)),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            gradient: LinearGradient(
              colors: ffBrandGradientColors(),
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: ffTitleColor(),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class TimerRingPainter extends CustomPainter {
  final double progress;

  TimerRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 16.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - stroke;

    final basePaint = Paint()
      ..color = const Color(0xFFE7ECFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4E7DFF), Color(0xFF8364FF)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, basePaint);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class CircleButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color color;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const CircleButton({
    super.key,
    required this.icon,
    required this.background,
    required this.color,
    required this.onTap,
    this.size = 58,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;
    final isWhiteButton = background == Colors.white;

    final buttonColor =
        isWhiteButton && isDark ? const Color(0xFF11182D) : background;

    final iconColor = isWhiteButton && isDark ? const Color(0xFFB7C0E0) : color;

    return PressableScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: buttonColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.07) : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.35)
                  : buttonColor.withOpacity(0.28),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
    );
  }
}

class SessionCard extends StatelessWidget {
  final String title;
  final String time;
  final bool selected;
  final IconData icon;

  const SessionCard({
    super.key,
    required this.title,
    required this.time,
    required this.selected,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF2563EB) : ffCardColor(),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selected
              ? Colors.white.withOpacity(0.16)
              : isDark
                  ? Colors.white.withOpacity(0.08)
                  : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: selected
                ? const Color(0xFF2563EB).withOpacity(0.28)
                : isDark
                    ? Colors.black.withOpacity(0.35)
                    : Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: selected ? Colors.white : const Color(0xFF17A99E),
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : ffTitleColor(),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              color: selected ? Colors.white70 : ffSubtitleColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ChartBar extends StatelessWidget {
  final String label;
  final double value;

  const ChartBar({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 22,
            height: 130 * value,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              gradient: const LinearGradient(
                colors: [Color(0xFF4E7DFF), Color(0xFF8364FF)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: ffSubtitleColor(),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class RecentAchievementsList extends StatelessWidget {
  const RecentAchievementsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: focusFlowTotalSessions,
      builder: (context, totalSessions, _) {
        return ValueListenableBuilder<List<String>>(
          valueListenable: focusFlowCompletedTasks,
          builder: (context, completedTasks, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: focusFlowAppBlocking,
              builder: (context, appBlocking, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: focusFlowIsPro,
                  builder: (context, isPro, _) {
                    final achievements = <Widget>[];

                    if (completedTasks.isNotEmpty) {
                      achievements.add(
                        const AchievementTile(
                          icon: Icons.check_circle_rounded,
                          title: 'Task Finisher',
                          subtitle: 'Completed a task from today’s plan',
                        ),
                      );
                    }

                    if (completedTasks.length >= 3) {
                      achievements.add(
                        const AchievementTile(
                          icon: Icons.done_all_rounded,
                          title: 'Plan Crusher',
                          subtitle: 'Completed all tasks for today',
                        ),
                      );
                    }

                    if (totalSessions >= 1) {
                      achievements.add(
                        AchievementTile(
                          icon: Icons.timer_rounded,
                          title: 'Focus Starter',
                          subtitle:
                              'Completed $totalSessions focus session${totalSessions == 1 ? '' : 's'}',
                        ),
                      );
                    }

                    if (totalSessions >= 5) {
                      achievements.add(
                        const AchievementTile(
                          icon: Icons.local_fire_department_rounded,
                          title: 'Focus Streak',
                          subtitle: 'Built momentum with multiple sessions',
                        ),
                      );
                    }

                    if (appBlocking) {
                      achievements.add(
                        const AchievementTile(
                          icon: Icons.shield_rounded,
                          title: 'Shield Active',
                          subtitle: 'Distraction blocking is turned on',
                        ),
                      );
                    }

                    if (isPro) {
                      achievements.add(
                        const AchievementTile(
                          icon: Icons.verified_rounded,
                          title: 'Pro Member',
                          subtitle: 'Unlocked FocusFlow Pro features',
                        ),
                      );
                    }

                    if (achievements.isEmpty) {
                      achievements.add(
                        const AchievementTile(
                          icon: Icons.emoji_events_rounded,
                          title: 'Ready to Begin',
                          subtitle:
                              'Complete a task or focus session to earn badges',
                        ),
                      );
                    }

                    return Column(
                      children: [
                        for (int i = 0;
                            i < achievements.length.clamp(0, 3);
                            i++) ...[
                          achievements[i],
                          if (i != achievements.length.clamp(0, 3) - 1)
                            const SizedBox(height: 14),
                        ],
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class AchievementTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const AchievementTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = focusFlowDarkMode.value;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFFFB84D).withOpacity(
              isDark ? 0.22 : 0.14,
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFFB84D),
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: ffTitleColor(),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: ffSubtitleColor(),
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4E7DFF)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: ffTitleColor(),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFADB5D1)),
        ],
      ),
    );
  }
}

class PremiumFeature extends StatelessWidget {
  final String title;

  const PremiumFeature({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 29,
            height: 29,
            decoration: const BoxDecoration(
              color: Color(0xFF35C99F),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: ffTitleColor(),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color ffTitleColor() {
  return focusFlowDarkMode.value
      ? const Color(0xFFF8FAFC)
      : const Color(0xFF111827);
}

Color ffCardColor() {
  return focusFlowDarkMode.value ? const Color(0xFF111827) : Colors.white;
}

Color ffSubtitleColor() {
  return focusFlowDarkMode.value
      ? const Color(0xFFA7B0C0)
      : const Color(0xFF64748B);
}

Color ffSoftPillColor() {
  return focusFlowDarkMode.value
      ? const Color(0xFF172033)
      : const Color(0xFFEFF6F8);
}

List<Color> ffBrandGradientColors() {
  return const [
    Color(0xFF17BEBB),
    Color(0xFF2563EB),
    Color(0xFFFF8A3D),
  ];
}

List<Color> ffPageGradientColors(bool isDark) {
  return isDark
      ? const [
          Color(0xFF080B10),
          Color(0xFF101827),
          Color(0xFF0B1218),
        ]
      : const [
          Color(0xFFF4F7FA),
          Color(0xFFEFF8F7),
          Color(0xFFFFF7F0),
        ];
}

BoxDecoration cardDecoration() {
  final isDark = focusFlowDarkMode.value;

  return BoxDecoration(
    color: ffCardColor().withOpacity(isDark ? 0.90 : 0.92),
    gradient: LinearGradient(
      colors: isDark
          ? const [
              Color(0xFF141D2B),
              Color(0xFF101820),
            ]
          : const [
              Color(0xFFFFFFFF),
              Color(0xFFF8FCFB),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(22),
    border: Border.all(
      color: isDark
          ? Colors.white.withOpacity(0.10)
          : const Color(0xFFE2E8F0).withOpacity(0.92),
      width: 1.1,
    ),
    boxShadow: [
      BoxShadow(
        color: isDark
            ? Colors.black.withOpacity(0.38)
            : const Color(0xFF0F172A).withOpacity(0.07),
        blurRadius: 22,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: isDark
            ? Colors.white.withOpacity(0.025)
            : Colors.white.withOpacity(0.80),
        blurRadius: 1,
        offset: const Offset(0, 1),
      ),
    ],
  );
}

class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final BorderRadius? borderRadius;
  final Color? hoverColor;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.965,
    this.borderRadius,
    this.hoverColor,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool isPressed = false;
  bool isHovered = false;

  void setPressed(bool value) {
    if (isPressed == value) {
      return;
    }

    setState(() {
      isPressed = value;
    });
  }

  void setHovered(bool value) {
    if (isHovered == value) {
      return;
    }

    setState(() {
      isHovered = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(20);
    final hoverColor = widget.hoverColor ??
        (focusFlowDarkMode.value
            ? Colors.white.withOpacity(0.08)
            : const Color(0xFF17BEBB).withOpacity(0.08));

    return MouseRegion(
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: widget.onTap == null ? null : (_) => setHovered(true),
      onExit: widget.onTap == null ? null : (_) => setHovered(false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: widget.onTap == null ? null : (_) => setPressed(true),
        onTapCancel: widget.onTap == null ? null : () => setPressed(false),
        onTapUp: widget.onTap == null ? null : (_) => setPressed(false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: isPressed
              ? widget.pressedScale
              : isHovered
                  ? 1.018
                  : 1,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: widget.onTap == null ? 0.64 : 1,
            duration: const Duration(milliseconds: 120),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 170),
              curve: Curves.easeOutCubic,
              foregroundDecoration: BoxDecoration(
                color: isHovered ? hoverColor : Colors.transparent,
                borderRadius: radius,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
