#include <malloc.h>

extern void bench_main(float *a, float *b, float *c, int N);

int main(int argc, char **argv) {
  int N = 1000000;
  float *a = (float*)malloc(N * sizeof(float));
  float *b = (float*)malloc(N * sizeof(float));
  float *c = (float*)malloc(N * sizeof(float));
  int i = 0;
  for (; i < N; ++i) {
    a[i] = i + 1.0f;
    b[i] = i + 1.0f;
    c[i] = i + 1.0f;
  }
  bench_main(a, b, c, N);
  free(a);
  free(b);
  free(c);
  return 0;
}