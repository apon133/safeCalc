// ignore_for_file: use_build_context_synchronously
//! old code use only 23 line not change
import 'dart:io';
import 'package:calculetor/package/double_back_to_close_app.dart';
import 'package:calculetor/pages/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'Home/widget/button_widget.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage>
    with WidgetsBindingObserver {
  var input = '';
  String? savedPassword;
  String? calculationResult = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPassword();
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

  Future<void> _loadPassword() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedPassword = prefs.getString('savedPassword');
    });
  }

  void addNumber(String value) {
    setState(() {
      if (value == 'C') {
        input = '';
        calculationResult = null;
      } else if (value == 'Del') {
        if (input.isNotEmpty) {
          input = input.substring(0, input.length - 1);
        }
      } else if (value == '%') {
        input += '/100';
      } else if (value == '()') {
        if (input.isEmpty ||
            input.endsWith('(') ||
            input.endsWith('+') ||
            input.endsWith('-') ||
            input.endsWith('×') ||
            input.endsWith('÷')) {
          input += '(';
        } else if (input.endsWith(')')) {
          input += '*(';
        } else {
          int openCount = 0;
          int closeCount = 0;
          for (var char in input.split('')) {
            if (char == '(') openCount++;
            if (char == ')') closeCount++;
          }
          if (openCount > closeCount) {
            input += ')';
          } else {
            input += '(';
          }
        }
      } else {
        input += value;
      }
    });
  }

  String evaluateExpression(String expression) {
    try {
      expression = expression.replaceAll('×', '*').replaceAll('÷', '/');
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      NumberFormat formatter = NumberFormat('#,##0.################');
      return formatter.format(eval);
    } catch (e) {
      return 'Error';
    }
  }

  void handlePasswordSubmission() {
    if (input == savedPassword) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (builder) => StartPage(),
        ),
      );
      input = '';
      calculationResult = '';
    } else {}
  }

  void setPassword() {
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
                  setState(() {
                    savedPassword = newPassword;
                  });
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('savedPassword', newPassword);
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
                          padding: EdgeInsets.all(20),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: SelectableText(
                              input,
                              style: TextStyle(
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (calculationResult != null &&
                          calculationResult!.isNotEmpty)
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            reverse: true,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: SelectableText(
                                calculationResult!,
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
                        onTap: () => addNumber("C")),
                    ButtonWidget(
                        text: '()',
                        textColor: const Color(0xFF63FFDA),
                        onTap: () => addNumber("()")),
                    ButtonWidget(
                        text: '%',
                        textColor: const Color(0xFF63FFDA),
                        onTap: () => addNumber("%")),
                    ButtonWidget(
                        text: '÷',
                        textColor: const Color(0xFF63FFDA),
                        onTap: () => addNumber("÷")),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ButtonWidget(text: '7', onTap: () => addNumber("7")),
                    ButtonWidget(text: '8', onTap: () => addNumber("8")),
                    ButtonWidget(text: '9', onTap: () => addNumber("9")),
                    ButtonWidget(
                        text: '×',
                        textColor: const Color(0xFF63FFDA),
                        onTap: () => addNumber("×")),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ButtonWidget(text: '4', onTap: () => addNumber("4")),
                    ButtonWidget(text: '5', onTap: () => addNumber("5")),
                    ButtonWidget(text: '6', onTap: () => addNumber("6")),
                    ButtonWidget(
                        text: '-',
                        textColor: const Color(0xFF63FFDA),
                        onTap: () => addNumber("-")),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ButtonWidget(text: '1', onTap: () => addNumber("1")),
                    ButtonWidget(text: '2', onTap: () => addNumber("2")),
                    ButtonWidget(text: '3', onTap: () => addNumber("3")),
                    ButtonWidget(
                        text: '+',
                        textColor: const Color(0xFF63FFDA),
                        onTap: () => addNumber("+")),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ButtonWidget(text: '0', onTap: () => addNumber("0")),
                    ButtonWidget(text: '.', onTap: () => addNumber(".")),
                    ButtonWidget(
                      text: 'Del',
                      boxColor: Colors.redAccent.withOpacity(0.8),
                      onTap: () {
                        if (input.isNotEmpty) {
                          input = input.substring(0, input.length - 1);
                          setState(() {});
                        }
                      },
                    ),
                    GestureDetector(
                      onLongPress: setPassword,
                      child: ButtonWidget(
                        text: '=',
                        boxColor: const Color(0xFF00C853),
                        onTap: () {
                          if (savedPassword == null) {
                            _promptNewPassword();
                          } else {
                            String result = evaluateExpression(input);
                            setState(() {
                              calculationResult = result;
                            });
                            handlePasswordSubmission();
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
