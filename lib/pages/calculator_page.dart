// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:calculetor/core/providers.dart';
import 'package:calculetor/package/double_back_to_close_app.dart';
import 'package:calculetor/pages/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Home/widget/button_widget.dart';

class CalculatorPage extends ConsumerStatefulWidget {
  const CalculatorPage({super.key});

  @override
  ConsumerState<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends ConsumerState<CalculatorPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      exit(0);
    }
  }

  void handlePasswordSubmission(String input, String? savedPassword) {
    if (input == savedPassword) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (builder) => const StartPage(),
        ),
      );
      ref.read(calculatorProvider.notifier).clearInput();
    }
  }

  void setPassword(String? savedPassword) {
    showDialog(
      context: context,
      builder: (context) {
        String oldPasswordInput = '';
        return AlertDialog(
          title: const Text('Enter Old Password'),
          content: TextField(
            onChanged: (value) {
              oldPasswordInput = value;
            },
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Old Password'),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (savedPassword == null ||
                    oldPasswordInput == savedPassword) {
                  Navigator.of(context).pop();
                  _promptNewPassword();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Old password is incorrect')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _promptNewPassword() {
    showDialog(
      context: context,
      builder: (context) {
        String newPassword = '';
        return AlertDialog(
          title: const Text('Set New Password'),
          content: TextField(
            onChanged: (value) {
              newPassword = value;
            },
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Enter New Password'),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (newPassword.isNotEmpty) {
                  await ref
                      .read(passwordProvider.notifier)
                      .setPassword(newPassword);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Password changed successfully')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final calcState = ref.watch(calculatorProvider);
    final savedPassword = ref.watch(passwordProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: DoubleBackToCloseApp(
          snackBar: const SnackBar(content: Text('Tap back again to leave')),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: size.height * 0.4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          padding: const EdgeInsets.all(20),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: SelectableText(
                              calcState.input,
                              style: const TextStyle(
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (calcState.result.isNotEmpty)
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            reverse: true,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: SelectableText(
                                calcState.result,
                                style: TextStyle(
                                  fontSize: 32,
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    color: Colors.white.withOpacity(0.1),
                    thickness: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ButtonWidget(
                        text: 'C',
                        textColor: Colors.redAccent,
                        onTap: () => ref
                            .read(calculatorProvider.notifier)
                            .addNumber("C")),
                    ButtonWidget(
                        text: '()',
                        textColor: const Color(0xFF63FFDA),
                        onTap: () => ref
                            .read(calculatorProvider.notifier)
                            .addNumber("()")),
                    ButtonWidget(
                        text: '%',
                        textColor: const Color(0xFF63FFDA),
                        onTap: () => ref
                            .read(calculatorProvider.notifier)
                            .addNumber("%")),
                    ButtonWidget(
                        text: '÷',
                        textColor: const Color(0xFF63FFDA),
                        onTap: () => ref
                            .read(calculatorProvider.notifier)
                            .addNumber("÷")),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ButtonWidget(
                        text: '7',
                        onTap: () => ref
                            .read(calculatorProvider.notifier)
                            .addNumber("7")),
                    ButtonWidget(
                        text: '8',
                        onTap: () => ref
                            .read(calculatorProvider.notifier)
                            .addNumber("8")),
                    ButtonWidget(
                        text: '9',
                        onTap: () => ref
                            .read(calculatorProvider.notifier)
                            .addNumber("9")),
                    ButtonWidget(
                        text: '×',
                        textColor: const Color(0xFF63FFDA),
                        onTap: () => ref
                            .read(calculatorProvider.notifier)
                            .addNumber("×")),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ButtonWidget(
                        text: '4',
                        onTap: () => ref
                            .read(calculatorProvider.notifier)
                            .addNumber("4")),
                    ButtonWidget(
                        text: '5',
                        onTap: () => ref
                            .read(calculatorProvider.notifier)
                            .addNumber("5")),
                    ButtonWidget(
                        text: '6',
                        onTap: () => ref
                            .read(calculatorProvider.notifier)
                            .addNumber("6")),
                    ButtonWidget(
                        text: '-',
                        textColor: const Color(0xFF63FFDA),
                        onTap: () => ref
                            .read(calculatorProvider.notifier)
                            .addNumber("-")),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ButtonWidget(
                        text: '1',
                        onTap: () => ref
                            .read(calculatorProvider.notifier)
                            .addNumber("1")),
                    ButtonWidget(
                        text: '2',
                        onTap: () => ref
                            .read(calculatorProvider.notifier)
                            .addNumber("2")),
                    ButtonWidget(
                        text: '3',
                        onTap: () => ref
                            .read(calculatorProvider.notifier)
                            .addNumber("3")),
                    ButtonWidget(
                        text: '+',
                        textColor: const Color(0xFF63FFDA),
                        onTap: () => ref
                            .read(calculatorProvider.notifier)
                            .addNumber("+")),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ButtonWidget(
                        text: '0',
                        onTap: () => ref
                            .read(calculatorProvider.notifier)
                            .addNumber("0")),
                    ButtonWidget(
                        text: '.',
                        onTap: () => ref
                            .read(calculatorProvider.notifier)
                            .addNumber(".")),
                    ButtonWidget(
                      text: 'Del',
                      boxColor: Colors.redAccent.withOpacity(0.8),
                      onTap: () => ref
                          .read(calculatorProvider.notifier)
                          .addNumber("Del"),
                    ),
                    GestureDetector(
                      onLongPress: () => setPassword(savedPassword),
                      child: ButtonWidget(
                        text: '=',
                        boxColor: const Color(0xFF00C853),
                        onTap: () {
                          if (savedPassword == null) {
                            _promptNewPassword();
                          } else {
                            ref.read(calculatorProvider.notifier).evaluate();
                            handlePasswordSubmission(
                                calcState.input, savedPassword);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
