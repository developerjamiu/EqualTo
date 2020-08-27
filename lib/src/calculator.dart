class Calculator {
  String displayValue;
  num firstOperand;
  bool waitingForSecondOperand;
  String operators;

  Calculator() {
    displayValue = '0';
    waitingForSecondOperand = false;
  }
}

Calculator calculator = Calculator();
