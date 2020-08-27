import 'package:equalto/src/calculator.dart';

class CalculatorService {
  final Calculator calculator;

  CalculatorService(this.calculator);

  void inputNumber(String number) {
    String displayValue = calculator.displayValue;
    bool waitingForSecondOperand = calculator.waitingForSecondOperand;

    if (waitingForSecondOperand == true) {
      calculator.displayValue = number;
      calculator.waitingForSecondOperand = false;
    } else {
      calculator.displayValue =
          displayValue == '0' ? number : displayValue + number;
    }
  }

  void inputDecimal(String decimal) {
    if (calculator.waitingForSecondOperand == true) {
      calculator.displayValue = '0.';
      calculator.waitingForSecondOperand = false;
      return;
    }

    if (!calculator.displayValue.contains('.')) {
      calculator.displayValue += '.';
    }
  }

  void handleOperator(String nextOperator) {
    String displayValue = calculator.displayValue;
    num firstOperand = calculator.firstOperand;
    String operators = calculator.operators;

    num inputValue = num.parse(displayValue);

    if (operators != null && calculator.waitingForSecondOperand) {
      calculator.operators = nextOperator;
      return;
    }

    if (firstOperand == null && !inputValue.isNaN) {
      calculator.firstOperand = inputValue;
    } else if (operators != null) {
      num result = calculate(firstOperand, inputValue, operators);

      calculator.displayValue = '${num.parse(result.toStringAsFixed(7))}';
      calculator.displayValue = calculator.displayValue.endsWith('.0')
          ? calculator.displayValue.replaceAll('.0', '')
          : calculator.displayValue;
      calculator.firstOperand = result;
    }

    calculator.waitingForSecondOperand = true;
    calculator.operators = nextOperator;
  }

  num calculate(firstOperand, secondOperand, operators) {
    if (operators == '+') {
      return firstOperand + secondOperand;
    } else if (operators == '-') {
      return firstOperand - secondOperand;
    } else if (operators == '×') {
      return firstOperand * secondOperand;
    } else if (operators == '÷') {
      return firstOperand / secondOperand;
    } else if (operators == '%') {
      return firstOperand / 100;
    }
    return secondOperand;
  }

  void resetCalculator() {
    calculator.displayValue = '0';
    calculator.firstOperand = null;
    calculator.waitingForSecondOperand = false;
    calculator.operators = null;
  }
}
