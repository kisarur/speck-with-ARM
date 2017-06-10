#include <stdint.h>
#include <stdio.h>

#define ROR(x, r) ((x >> r) | (x << (64 - r)))
#define ROL(x, r) ((x << r) | (x >> (64 - r)))
#define R(x, y, k) (x = ROR(x, 8), x += y, x ^= k, y = ROL(y, 3), y ^= x)
#define ROUNDS 32

void encrypt(uint64_t const pt[2], uint64_t const K[2]) {
	uint64_t y = pt[0], x = pt[1], b = K[0], a = K[1];

	R(x, y, b);
	for (int i = 0; i < ROUNDS - 1; i++) {
		R(a, b, i);
		R(x, y, b);
	}

	printf("Cipher text is:\n%lx %lx\n", x, y); 
}

int main() {
	uint64_t text[2];
	uint64_t key[2];

	printf("Enter the key:\n");

	int i; 
	for(i = 1; i >= 0; i--) {
		scanf("%lx", &key[i]);
	}

	printf("Enter the plain text:\n");

	for(i = 1; i >= 0; i--) {
		scanf("%lx", &text[i]);
	}

	encrypt(text, key);
	
}
