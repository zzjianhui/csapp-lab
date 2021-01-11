#include <stdio.h>

int main() {
	char a[4];
	char *s = a + 2;
	printf("%.8x\n",s);
	return 0;
}
