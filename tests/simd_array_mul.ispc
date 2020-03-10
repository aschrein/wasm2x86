export void bench_main(
  uniform float a[],
  uniform int N) {
  uniform float *b = a + N;
  uniform float *c = a + 2 * N;
  foreach(i = 0...N) {
    a[i] = b[i] * c[i];
  }
}