import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/test_models.dart';
import '../services/api_service.dart';

enum QuestionStatus {
  notVisited,
  notAnswered,
  answered,
  markedForReview,
  answeredAndMarkedForReview,
}

class TestState {
  final bool isLoading;
  final Test? test;
  final String? sessionId;
  final String? error;
  final Map<String, List<String>> responses; // questionId -> list of selectedOptionIds
  final Map<String, QuestionStatus> statuses; // questionId -> status
  final int timeRemainingInSeconds;

  TestState({
    this.isLoading = true,
    this.test,
    this.sessionId,
    this.error,
    this.responses = const {},
    this.statuses = const {},
    this.timeRemainingInSeconds = 0,
  });

  // A helper method to create a copy of the state with some values changed.
  TestState copyWith({
    bool? isLoading,
    Test? test,
    String? sessionId,
    String? error,
    Map<String, List<String>>? responses,
    Map<String, QuestionStatus>? statuses,
    int? timeRemainingInSeconds,
  }) {
    return TestState(
      isLoading: isLoading ?? this.isLoading,
      test: test ?? this.test,
      sessionId: sessionId ?? this.sessionId,
      error: error ?? this.error,
      responses: responses ?? this.responses,
      statuses: statuses ?? this.statuses,
      timeRemainingInSeconds: timeRemainingInSeconds ?? this.timeRemainingInSeconds,
    );
  }
}


class TestNotifier extends StateNotifier<TestState> {
  final ApiService _apiService;
  Timer? _timer;

  TestNotifier(this._apiService) : super(TestState());

  Future<void> loadTest() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final testData = await _apiService.getTest();

      // Initialize statuses for all questions
      final initialStatuses = <String, QuestionStatus>{};
      for (var section in testData.sections) {
        for (var question in section.questions) {
          initialStatuses[question.questionId] = QuestionStatus.notVisited;
        }
      }

      state = state.copyWith(
        isLoading: false,
        test: testData,
        sessionId: testData.sessionId,
        timeRemainingInSeconds: testData.durationInSeconds,
        statuses: initialStatuses,
        responses: {},
      );
      _startTimer();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemainingInSeconds > 0) {
        state = state.copyWith(timeRemainingInSeconds: state.timeRemainingInSeconds - 1);
      } else {
        timer.cancel();
        // TODO: Implement auto-submit logic
      }
    });
  }
  
  void answerQuestion(String questionId, List<String> selectedOptionIds) {
    final newResponses = Map<String, List<String>>.from(state.responses);
    newResponses[questionId] = selectedOptionIds;
    
    final newStatuses = Map<String, QuestionStatus>.from(state.statuses);
    newStatuses[questionId] = QuestionStatus.answered;

    state = state.copyWith(responses: newResponses, statuses: newStatuses);
  }

  // TODO: Implement other methods like clearResponse, markForReview, etc.
  void markForReview(String questionId) {
     final newStatuses = Map<String, QuestionStatus>.from(state.statuses);
     // Logic to check if it's already answered or not
     newStatuses[questionId] = QuestionStatus.markedForReview;
     state = state.copyWith(statuses: newStatuses);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final testProvider = StateNotifierProvider<TestNotifier, TestState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return TestNotifier(apiService);
});