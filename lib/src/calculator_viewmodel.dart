import 'dart:math';
//import 'dart:math';
import 'package:petitparser/petitparser.dart';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'calculator.dart';
import 'calculator_service.dart';

class CalculatorViewModel extends ChangeNotifier {
  CalculatorService _calculatorService = CalculatorService(calculator);

  Calculator get calculatorModel => calculator;
  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  String voiceResult = "";
  String _currentLocaleId = "";
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();

  CalculatorViewModel() {
    if (!_hasSpeech) {
      initSpeechState();
    }
  }

  void start() {
    if (!_hasSpeech || speech.isListening) {
      return null;
    }
    startListening();
  }

  void stop() {
    if (speech.isListening) {
      stopListening();
    }
    return null;
  }

  void cancel() {
    if (speech.isListening) {
      cancelListening();
    }
    return null;
  }

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    if (hasSpeech) {
      _localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale.localeId;
    }

    _hasSpeech = hasSpeech;
    notifyListeners();
  }

  void startListening() {
    lastWords = "";
    lastError = "";
    speech.listen(
      onResult: resultListener,
      listenFor: Duration(seconds: 60),
      localeId: _currentLocaleId,
      cancelOnError: true,
      partialResults: true,
    );
    notifyListeners();
  }

  void stopListening() {
    speech.stop();
    level = 0.0;
    notifyListeners();
  }

  void cancelListening() {
    speech.cancel();
    level = 0.0;
    notifyListeners();
  }

  void resultListener(SpeechRecognitionResult result) {
    lastWords = "${result.recognizedWords}";
    double wordResult = calcString(lastWords);
    calculatorModel.displayValue = wordResult.toStringAsFixed(0);
    notifyListeners();
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    this.level = level;
    notifyListeners();
  }

  void errorListener(SpeechRecognitionError error) {
    lastError = "Try saying something (2 + 2)";
    notifyListeners();
  }

  void statusListener(String status) {
    lastStatus = "$status";
    notifyListeners();
  }

  /// I used a grid view for the button controls.
  /// However, the index property represents a button.
  void operation(int index) {
    switch (index) {
      case 0:
        _calculatorService.resetCalculator();
        break;
      case 1:
        _calculatorService.handleOperator('%');
        break;
      case 2:
        _calculatorService.handleOperator('÷');
        break;
      case 3:
        _calculatorService.inputNumber('7');
        break;
      case 4:
        _calculatorService.inputNumber('8');
        break;
      case 5:
        _calculatorService.inputNumber('9');
        break;
      case 6:
        _calculatorService.handleOperator('×');
        break;
      case 7:
        _calculatorService.inputNumber('4');
        break;
      case 8:
        _calculatorService.inputNumber('5');
        break;
      case 9:
        _calculatorService.inputNumber('6');
        break;
      case 10:
        _calculatorService.handleOperator('-');
        break;
      case 11:
        _calculatorService.inputNumber('1');
        break;
      case 12:
        _calculatorService.inputNumber('2');
        break;
      case 13:
        _calculatorService.inputNumber('3');
        break;
      case 14:
        _calculatorService.handleOperator('+');
        break;
      case 15:
        _calculatorService.inputNumber('0');
        break;
      case 16:
        _calculatorService.inputDecimal('.');
        break;
      default:
        _calculatorService.handleOperator('=');
    }
    notifyListeners();
  }

  String buttonText(int index) {
    String text;
    switch (index) {
      case 0:
        text = 'A/C';
        break;
      case 1:
        text = '%';
        break;
      case 2:
        text = '÷';
        break;
      case 3:
        text = '7';
        break;
      case 4:
        text = '8';
        break;
      case 5:
        text = '9';
        break;
      case 6:
        text = '×';
        break;
      case 7:
        text = '4';
        break;
      case 8:
        text = '5';
        break;
      case 9:
        text = '6';
        break;
      case 10:
        text = '-';
        break;
      case 11:
        text = '1';
        break;
      case 12:
        text = '2';
        break;
      case 13:
        text = '3';
        break;
      case 14:
        text = '+';
        break;
      case 15:
        text = '0';
        break;
      case 16:
        text = '.';
        break;
      default:
        text = '=';
    }
    return text;
  }

  Parser buildParser() {
    final builder = ExpressionBuilder();
    builder.group()
      ..primitive((pattern('+-').optional() &
              digit().plus() &
              (char('.') & digit().plus()).optional() &
              (pattern('eE') & pattern('+-').optional() & digit().plus())
                  .optional())
          .flatten('number expected')
          .trim()
          .map(num.tryParse))
      ..wrapper(
          char('(').trim(), char(')').trim(), (left, value, right) => value);
    builder.group()..prefix(char('-').trim(), (op, a) => -a);
    builder.group()..right(char('^').trim(), (a, op, b) => pow(a, b));
    builder.group()
      ..left(char('*').trim(), (a, op, b) => a * b)
      ..left(char('/').trim(), (a, op, b) => a / b);
    builder.group()
      ..left(char('+').trim(), (a, op, b) => a + b)
      ..left(char('-').trim(), (a, op, b) => a - b);
    return builder.build().end();
  }

  double calcString(String text) {
    final parser = buildParser();
    final input = text;
    final result = parser.parse(input);
    if (result.isSuccess)
      return result.value.toDouble();
    else
      return double.parse(text);
  }
}
