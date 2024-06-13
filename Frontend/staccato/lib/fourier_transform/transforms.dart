import 'dart:math';
import 'package:staccato/fourier_transform/complex_number.dart';

class Transforms {
  static List<double> FFT(List<double> samples) {
    int length = samples.length;
    if (!isPowerOf2(length)) {
      // Source: http://graphics.stanford.edu/~seander/bithacks.html#RoundUpPowerOf2Float
      int v = length;
      v--;
      v |= v >> 1;
      v |= v >> 2;
      v |= v >> 4;
      v |= v >> 8;
      v |= v >> 16;
      v++;

      length = v;
    }

    List<ComplexNumber> data = List<ComplexNumber>.filled(length, ComplexNumber(0, 0));
    for (int i = 0; i < samples.length; i++) {
      data[i] = ComplexNumber(samples[i], 0);
    }

    var fftResult = _fastFourierTransform(data);

    List<double> result = List<double>.filled(fftResult.length ~/ 2, 0);
    for (int i = 0; i < result.length ~/ 2; i++) {
      result[i] = fftResult[i].magnitude * 2;
    }

    return result;
  }

  static List<ComplexNumber> _fastFourierTransform(List<ComplexNumber> samples) {
    // n MUST BE A POWER OF 2
    int n = samples.length;
    if (n == 1) {
      return samples;
    }

    int m = n ~/ 2;
    List<ComplexNumber> xEven = List<ComplexNumber>.filled(m, ComplexNumber(0, 0));
    List<ComplexNumber> xOdd = List<ComplexNumber>.filled(m, ComplexNumber(0, 0));

    for (int i = 0; i < m; i++) {
      xEven[i] = samples[2 * i];
      xOdd[i] = samples[2 * i + 1];
    }

    List<ComplexNumber> fEven = List<ComplexNumber>.filled(m, ComplexNumber(0, 0));
    fEven = _fastFourierTransform(xEven);

    List<ComplexNumber> fOdd = List<ComplexNumber>.filled(m, ComplexNumber(0, 0));
    fOdd = _fastFourierTransform(xOdd);

    List<ComplexNumber> freqbins = List<ComplexNumber>.filled(n, ComplexNumber(0, 0));

    for (int k = 0; k < m; k++) {
      var complexExponential = ComplexNumber.multiply(fOdd[k], ComplexNumber.fromPolar(1, -2 * pi * k / n));
      freqbins[k] = ComplexNumber.add(fEven[k], complexExponential);
      freqbins[k + m] = ComplexNumber.subtract(fEven[k], complexExponential);
    }

    return freqbins;
  }

  static bool isPowerOf2(int number)
  {
    return number > 0 && (number & (number - 1)) == 0;
  }
}