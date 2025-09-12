import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/test_provider.dart';
import 'widgets/test_header.dart';

// Using a ConsumerStatefulWidget to have access to both `ref` (from Riverpod)
// and `initState` (a standard widget lifecycle method).
class TestScreen extends ConsumerStatefulWidget {
  const TestScreen({super.key});

  @override
  ConsumerState<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends ConsumerState<TestScreen> {

  @override
  void initState() {
    super.initState();
    //waits until the first frame is built before making the API call.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ref.read here because we want to call the function only once
      ref.read(testProvider.notifier).loadTest('jee_main_mock_01'); //placeholder test ID
    });
  }

  @override
  Widget build(BuildContext context) {
    // Widget will automatically rebuild whenever the TestState changes.
    final testState = ref.watch(testProvider);

    // Error
    if (testState.error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('An error occurred: ${testState.error}'),
          ),
        ),
      );
    }

    // Loading
    if (testState.isLoading || testState.test == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Loading successful
    return Scaffold(
      appBar: const TestHeader(),
      body: const Row(
        children: [
          Expanded(
            flex: 3, // Give more space to the question area
            child: Center(child: Text('Question Area Placeholder')),
          ),
          Expanded(
            flex: 1, // Give less space to the nav panel
            child: Center(child: Text('Navigation Panel Placeholder')),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        padding: const EdgeInsets.all(8.0),
        color: Colors.black12,
        child: const Center(child: Text('Action Buttons Placeholder')),
      ),
    );
  }
}