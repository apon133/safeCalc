import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:intl/intl.dart';

// --- Hive Box Provider ---
final settingsBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError();
});

// --- Calculator State ---
class CalculatorState {
  final String input;
  final String result;

  CalculatorState({this.input = '', this.result = ''});

  CalculatorState copyWith({String? input, String? result}) {
    return CalculatorState(
      input: input ?? this.input,
      result: result ?? this.result,
    );
  }
}

class CalculatorNotifier extends Notifier<CalculatorState> {
  @override
  CalculatorState build() => CalculatorState();

  void addNumber(String value) {
    if (value == 'C') {
      state = CalculatorState();
    } else if (value == 'Del') {
      if (state.input.isNotEmpty) {
        state = state.copyWith(
          input: state.input.substring(0, state.input.length - 1),
        );
      }
    } else if (value == '%') {
      state = state.copyWith(input: '${state.input}/100');
    } else if (value == '()') {
      state = state.copyWith(input: _handleParentheses(state.input));
    } else {
      state = state.copyWith(input: state.input + value);
    }
  }

  String _handleParentheses(String input) {
    if (input.isEmpty ||
        input.endsWith('(') ||
        input.endsWith('+') ||
        input.endsWith('-') ||
        input.endsWith('×') ||
        input.endsWith('÷')) {
      return '$input(';
    } else if (input.endsWith(')')) {
      return '$input*(';
    } else {
      int openCount = 0;
      int closeCount = 0;
      for (var char in input.split('')) {
        if (char == '(') openCount++;
        if (char == ')') closeCount++;
      }
      return openCount > closeCount ? '$input)' : '$input(';
    }
  }

  void evaluate() {
    try {
      String expression = state.input.replaceAll('×', '*').replaceAll('÷', '/');
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      NumberFormat formatter = NumberFormat('#,##0.################');
      state = state.copyWith(result: formatter.format(eval));
    } catch (e) {
      state = state.copyWith(result: 'Error');
    }
  }

  void clearInput() {
    state = state.copyWith(input: '', result: '');
  }
}

final calculatorProvider =
    NotifierProvider<CalculatorNotifier, CalculatorState>(
        () => CalculatorNotifier());

// --- Password State ---
class PasswordNotifier extends Notifier<String?> {
  @override
  String? build() {
    final box = ref.watch(settingsBoxProvider);
    return box.get('savedPassword');
  }

  Future<void> setPassword(String newPassword) async {
    final box = ref.read(settingsBoxProvider);
    await box.put('savedPassword', newPassword);
    state = newPassword;
  }
}

final passwordProvider =
    NotifierProvider<PasswordNotifier, String?>(() => PasswordNotifier());

// --- Navigation State ---
class NavigationNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final navigationProvider =
    NotifierProvider<NavigationNotifier, int>(() => NavigationNotifier());

// --- Image Gallery State ---
class ImageGalleryNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    final box = ref.watch(settingsBoxProvider);
    return List<String>.from(
        box.get('mediaImagePageFilePaths', defaultValue: <String>[]));
  }

  Future<void> addImages(List<String> paths) async {
    final box = ref.read(settingsBoxProvider);
    final newList = [...state, ...paths];
    await box.put('mediaImagePageFilePaths', newList);
    state = newList;
  }

  Future<void> removeImages(Set<int> indices) async {
    final box = ref.read(settingsBoxProvider);
    List<String> newList = [...state];

    List<int> sortedIndices = indices.toList()..sort((a, b) => b.compareTo(a));
    for (int index in sortedIndices) {
      if (index >= 0 && index < newList.length) {
        newList.removeAt(index);
      }
    }

    await box.put('mediaImagePageFilePaths', newList);
    state = newList;
  }
}

final imageGalleryProvider =
    NotifierProvider<ImageGalleryNotifier, List<String>>(
        () => ImageGalleryNotifier());

// --- Video Gallery State ---
class VideoGalleryNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    final box = ref.watch(settingsBoxProvider);
    return List<String>.from(
        box.get('mediaFilePaths', defaultValue: <String>[]));
  }

  Future<void> addVideos(List<String> paths) async {
    final box = ref.read(settingsBoxProvider);
    final newList = [...state, ...paths];
    await box.put('mediaFilePaths', newList);
    state = newList;
  }

  Future<void> removeVideos(Set<int> indices) async {
    final box = ref.read(settingsBoxProvider);
    List<String> newList = [...state];

    List<int> sortedIndices = indices.toList()..sort((a, b) => b.compareTo(a));
    for (int index in sortedIndices) {
      if (index >= 0 && index < newList.length) {
        newList.removeAt(index);
      }
    }

    await box.put('mediaFilePaths', newList);
    state = newList;
  }
}

final videoGalleryProvider =
    NotifierProvider<VideoGalleryNotifier, List<String>>(
        () => VideoGalleryNotifier());

// --- Network Gallery State ---
class NetworkGalleryNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    final box = ref.watch(settingsBoxProvider);
    return List<String>.from(
        box.get('mediaNetworkImagePageFilePaths', defaultValue: <String>[]));
  }

  Future<void> addUrl(String url) async {
    final box = ref.read(settingsBoxProvider);
    final newList = [...state, url];
    await box.put('mediaNetworkImagePageFilePaths', newList);
    state = newList;
  }

  Future<void> removeAt(int index) async {
    final box = ref.read(settingsBoxProvider);
    List<String> newList = [...state];
    if (index >= 0 && index < newList.length) {
      newList.removeAt(index);
    }
    await box.put('mediaNetworkImagePageFilePaths', newList);
    state = newList;
  }
}

final networkGalleryProvider =
    NotifierProvider<NetworkGalleryNotifier, List<String>>(
        () => NetworkGalleryNotifier());
