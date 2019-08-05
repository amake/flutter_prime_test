#include <jni.h>
#include <string>

const int reportingInterval = 250;

bool is_prime(int n) {
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

bool gen_primes_stop = false;

extern "C" JNIEXPORT void JNICALL
Java_com_example_flutter_1prime_1test_NativePrimes_setEnabled(JNIEnv* env,
                                                              jobject thisObject,
                                                              jboolean enabled) {
    gen_primes_stop = !enabled;
}

extern "C" JNIEXPORT void JNICALL
Java_com_example_flutter_1prime_1test_NativePrimes_genPrimes(JNIEnv* env,
                                                             jobject thisObject) {
    jclass clazz = env->GetObjectClass(thisObject);
    jmethodID consume = env->GetMethodID(clazz, "consume", "(I)V");

    for (int i = 2, count = 0; !gen_primes_stop; i++) {
        if (is_prime(i)) {
            count++;
            if (count % reportingInterval == 0) {
                env->CallVoidMethod(thisObject, consume, i);
            }
        }
    }
}
