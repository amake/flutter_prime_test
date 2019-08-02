//
//  Primes.c
//  Runner
//
//  Created by Aaron Madlon-Kay on 2019/08/02.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#include "Primes.h"

int reportingInterval = 250;

bool c_is_prime(int n) {
    if (n == 2) {
        return true;
    }
    for (int i = n - 1; i > 1; i--) {
        if (n % i == 0) {
            return false;
        }
    }
    return true;
}

void c_gen_primes() {
    for (int i = 2, count = 0; !c_gen_primes_stop; i++) {
        if (c_is_prime(i)) {
            count++;
            if (count % reportingInterval == 0) {
                c_consume_prime(i);
            }
        }
    }
}
