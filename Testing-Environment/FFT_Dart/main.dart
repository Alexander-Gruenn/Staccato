import 'fourier_transforms.dart';

void main() {
  var result = Transforms.FFT([0, 1, 0, -1]);

  for (int i = 0; i < result.length; i++) {
    print(result[i]);
  }
}