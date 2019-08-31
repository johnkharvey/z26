// phase generator

#include <stdio.h>
#include <math.h>

double color[16][2];

int main(void)
{
	int i;
	double angle;
	double pi = 4*atan(1);
	double scale1 = 0.240;	// .246
	double scale2 = 0.240;	// .2

	double phase1 = 0.15 * pi;	// 0.16
	double phase2 = 0.15 * pi;

	double delta1 = -0.04 * pi;	// -0.04
	double delta2 =  0.48 * pi;

	double tweak = 0.00 * pi;

	printf("pi = %lf\n\n", pi);

	printf("static constexpr double color[16][2] =\n");
	printf("{\n");

	printf("    { %lf, %lf },\n", 0.0, 0.0);

	color[0][0] = 0.0;
	color[0][1] = 0.0;

	for (i=1; i<16; i++)
	{
		printf("    { %lf, %lf },\n", 
			   scale1*sin(i*phase1-delta1 + tweak), 
			   scale2*sin(i*phase2-delta2 - tweak));
		color[i][0] = scale1*sin(i*phase1-delta1 + tweak);
		color[i][1] = scale1*sin(i*phase1-delta1 - tweak);
	}

	printf("};\n");

		for (int i = 0; i < 16; i++)
	{
		double const I = color[i][0];
		double const Q = color[i][1];

		for (int j = 0; j < 8; j++)
		{
			double const Y = j / 7.0;

			double R = Y + 0.956 * I + 0.621 * Q;
			double G = Y - 0.272 * I - 0.647 * Q;
			double B = Y - 1.106 * I + 1.703 * Q;

			if (R < 0) R = 0;
			if (G < 0) G = 0;
			if (B < 0) B = 0;

			R = pow(R, 0.80);   // .9
			G = pow(G, 0.80);   // .9
			B = pow(B, 0.80);   // .9

            printf("R: %lf, G: %lf, B: %lf\n", R, G, B);

			if (R > 1) R = 1;
			if (G > 1) G = 1;
			if (B > 1) B = 1;
/*
			palette.set_pen_color(
					8 * i + j,
					uint8_t(255 * R + 0.5),
					uint8_t(255 * G + 0.5),
					uint8_t(255 * B + 0.5));
*/
		}
	}

}