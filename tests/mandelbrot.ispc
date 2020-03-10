static inline int mandel(float c_re, float c_im, int count) {
    float z_re = c_re, z_im = c_im;
    int i;
    for (i = 0; i < count; ++i) {
        if (z_re * z_re + z_im * z_im > 4.)
            break;

        float new_re = z_re*z_re - z_im*z_im;
        float new_im = 2.f * z_re * z_im;
        unmasked {
            z_re = c_re + new_re;
            z_im = c_im + new_im;
        }
    }

    return i;
}

void mandelbrot(uniform float x0, uniform float y0,
                            uniform float x1, uniform float y1,
                            uniform int width, uniform int height,
                            uniform int maxIterations,
                            uniform int output[])
{
    float dx = (x1 - x0) / width;
    float dy = (y1 - y0) / height;

    for (uniform int j = 0; j < height; j++) {
        // Note that we'll be doing programCount computations in parallel,
        // so increment i by that much.  This assumes that width evenly
        // divides programCount.
        foreach (i = 0 ... width) {
            // Figure out the position on the complex plane to compute the
            // number of iterations at.  Note that the x values are
            // different across different program instances, since its
            // initializer incorporates the value of the programIndex
            // variable.
            float x = x0 + i * dx;
            float y = y0 + j * dy;

            int index = j * width + i;
            output[index] = mandel(x, y, maxIterations);
        }
    }
}

static inline uniform float Q_rsqrt(uniform float number)
{
	uniform int64 i;
	uniform float x2, y;
	uniform const float threehalfs = 1.5F;

	x2 = number * 0.5F;
	y  = number;
	i  = (int64)__intbits_uniform_float(y);
	i  = 0x5f3759df - ( i >> 1 );
	y  = (float)__floatbits_uniform_int32((int32)i);
	y  = y * ( threehalfs - ( x2 * y * y ) );
	return y;
}

export void bench_main(uniform int a[], uniform int N) {
  uniform int width = (int)(Q_rsqrt((float)N) * (float)N);
  if (width < 0 || width * width > N) {
    return;
  }
  // Align to 4. So that memory is 16 byte aligned
  width = width & (~0xf);
  mandelbrot(
    0.0f, 0.0f,
    1.0f, 1.0f,
    width, width,
    255, a
    );
}