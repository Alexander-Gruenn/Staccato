import 'dart:math';

class ComplexNumber {
  double _real;
  double _imaginary;

  double get real {
    return _real;
  }

  double get imaginary {
    return _imaginary;
  }

  double get magnitude {
    return sqrt(_real * _real + _imaginary * _imaginary);
  }

  double get phase {
    if (_real != 0) {
      return atan(_imaginary / _real);
    } else if (_imaginary < 0) {
      return 90;
    } else {
      return -90;
    }
  }

  static ComplexNumber add(ComplexNumber a, ComplexNumber b) {
    return ComplexNumber(a._real + b.real, a._imaginary + b.imaginary);
  }

  static ComplexNumber subtract(ComplexNumber a, ComplexNumber b) {
    return ComplexNumber(a._real - b.real, a._imaginary - b.imaginary);
  }

  static ComplexNumber multiply(ComplexNumber a, ComplexNumber b) {
    return ComplexNumber((a._real * b._real) - (a._imaginary * b._imaginary), (a._real * b._imaginary) + (a._imaginary * b._real));
  }

  ComplexNumber(this._real, this._imaginary);

  // Creates a complex number from polar into cartesian form
  // Theta in RADIANTS
  static ComplexNumber fromPolar(double magnitude, double theta)
  => ComplexNumber(magnitude * cos(theta), magnitude * sin(theta));
}