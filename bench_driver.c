#include <malloc.h>
#include <stdint.h>
#include <sys/time.h>

long long current_timestamp() {
    struct timeval te; 
    gettimeofday(&te, NULL); // get current time
    long long milliseconds = te.tv_sec*1000LL + te.tv_usec/1000; // calculate milliseconds
    // printf("milliseconds: %lld\n", milliseconds);
    return milliseconds;
}

extern void bench_main(float *a, int N);

int main(int argc, char **argv) {
  int N = 16 * (1 << 20);
  void *_a = (void*)malloc(3 * N * sizeof(float) + 16);
  // Align to 16 bytes
  float *a = (float*)(void*)(
                    ((uint64_t)_a + 0xff) & (~0xffull)
                  );
  float *b = a + N;
  float *c = b + N;
  int i = 0;
  for (; i < N; ++i) {
    a[i] = i + 1.0f;
    b[i] = i + 1.0f;
    c[i] = i + 1.0f;
  }
  long long t0 = current_timestamp();
  bench_main(a, N);
  long long t1 = current_timestamp();
  printf("ms:%u\n", (t1 - t0));
  free(_a);
  return 0;
}