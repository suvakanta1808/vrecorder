import 'dart:math' as MATH;

import 'package:vrecorder/dataset-2.dart' as dt;

List<double> hammingWindow(List<double> amp) {
  int N = amp.length;
  List<double> window = List.filled(N, 0);
  for (int n = 0; n < N; n++) {
    window[n] = 0.54 - 0.46 * MATH.cos((2 * MATH.pi * n) / (N - 1));
  }
  return window;
}

List<double> durbinAlgo(List<double> amp) {
  List<double> r = List.filled(13, 0);

  for (int l = 0; l < 13; l++) {
    for (int p = 0; p < 320 - l; p++) {
      r[l] = r[l] + ((amp[p]) * amp[p + l]);
    }
  }

  double sum = 0;

  List<double> e = List.filled(13, 0);
  List<double> k = List.filled(13, 0);
  List<List<double>> alpha = List.filled(13, List.filled(13, 0));
  e[0] = r[0];

  for (int i = 1; i < 13; i++) {
    for (int j = 1; j <= i - 1; j++) {
      sum = sum + alpha[i - 1][j] * r[i - j];
    }

    k[i] = (r[i] - sum) / e[i - 1];

    alpha[i][i] = k[i];

    for (int j = 1; j <= i - 1; j++) {
      alpha[i][j] = alpha[i - 1][j] - (k[i] * alpha[i - 1][i - j]);
    }

    e[i] = (1.0 - (k[i] * k[i])) * e[i - 1];

    sum = 0;
  }

  List<double> res = List.filled(13, 0);

  for (int x = 1; x < 13; x++) {
    res[x] = alpha[12][x];
  }

  return res;
}

List<double> calculateCepstal(List<double> a) {
  double t, sw = 0;
  List<double> c = List.filled(13, 0);

  for (int m = 1; m < 13; m++) {
    c[m] = a[m];
    for (int j = 1; j <= m - 1; j++) {
      t = j / m;

      c[m] = c[m] + t * c[j] * a[m - j];
    }
  }

  // apply sine window
  for (int m = 1; m < 13; m++) {
    sw = 1 + (6.0 * MATH.sin((MATH.pi * m) / 12.0));
    c[m] = c[m] * sw;
  }

  return c;
}

//@brief - calculate tokura distance with codebook
//@parma - a - vector under consideration
List<double> tokuraDist(List<double> c) {
  double t;

  List<double> tokuraWt = [
    1.0,
    3.0,
    7.0,
    13.0,
    19.0,
    22.0,
    25.0,
    33.0,
    42.0,
    50.0,
    56.0,
    61.0
  ];

  List<double> distance = List.filled(32, 0);

  for (int i = 0; i < 32; i++) {
    for (int j = 0; j < 12; j++) {
      t = (c[j] - dt.centroid[i][j]) * (c[j] - dt.centroid[i][j]);
      distance[i] = distance[i] + tokuraWt[j] * t;
    }
  }

  return distance;
}

List<int> findObsSeq(List<double> amp) {
  List<int> obs = List.of([], growable: true);
  final double max = amp.reduce(MATH.max);
  final double nFactor = 5000 / max;
  for (int i = 0; i < amp.length; i += 80) {
    if (i + 320 > amp.length) return obs;

    List<double> subList = amp.sublist(i, i + 320);
    subList = subList.map((double x) => (x * nFactor)).toList();

    // hamming window
    subList = hammingWindow(subList);

    // find durbinAlgo res

    List<double> a = durbinAlgo(subList);

    // find cepstal

    List<double> cepstal = calculateCepstal(a);

    // find takura distance

    List<double> distance = tokuraDist(cepstal);

    // find min distance
    obs.add(distance.indexOf(distance.reduce(MATH.min)));
  }

  return obs;
}

double forwardProcedure(List<double> pi, List<List<double>> a,
    List<List<double>> b, List<int> obs, int T) {
  double sum = 0;

  List<List<double>> alpha = List.filled(T + 1, List.filled(6, 0));
  for (int i = 1; i <= 5; i++) {
    alpha[1][i] = pi[i] * b[i][obs[1]];
  }

  for (int t = 1; t <= T - 1; t++) {
    for (int j = 1; j <= 5; j++) {
      for (int i = 1; i <= 5; i++) {
        sum += (alpha[t][i] * a[i][j]);
      }
      alpha[t + 1][j] = sum * b[j][obs[t + 1]];
      sum = 0;
    }
  }

  sum = 0;

  for (int m = 1; m <= 5; m++) {
    sum += alpha[T][m];
  }

  return sum;
}

List<double> test(List<int> obs) {
  List<double> res = List.filled(10, 0);

  for (int i = 0; i < 10; i++) {
    res[i] =
        forwardProcedure(dt.pi, dt.matrixA[i], dt.matrixB[i], obs, obs.length);
  }

  return res;
}

int itemTest(List<double> p) {
  int min = 0;
  double minVal = 100;

  for (int i = 0; i < 3; i++) {
    if (p[i] < minVal) {
      minVal = p[i];
      min = i;
    }
  }
  return min;
}

int quantityTest(List<double> p) {
  int min = 0;
  double minVal = 100;

  for (int i = 5; i < p.length; i++) {
    if (p[i] < minVal) {
      minVal = p[i];
      min = i;
    }
  }
  return min;
}

int yesnoTest(List<double> p) {
  int min = 0;
  double minVal = 100;

  for (int i = 3; i < 5; i++) {
    if (p[i] < minVal) {
      minVal = p[i];
      min = i;
    }
  }
  return min;
}

List<double> split(List<double> amp) {
  List<double> newAmp = List.of([], growable: true);
  int count = 0;

  for (int i = 0; i < amp.length; i++) {
    if (amp[i] > 200) {
      count = 0;
      newAmp.add(amp[i]);
    } else {
      newAmp.add(amp[i]);
      count++;
      if (count > 50) break;
    }
  }
  return newAmp;
}
