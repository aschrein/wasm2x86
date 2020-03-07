export void bench_main(uniform float a[], uniform float b[], uniform float c[], uniform float N) {
   foreach(i = 0...N) {
     a[i] = b[i] * c[i];
   }
}