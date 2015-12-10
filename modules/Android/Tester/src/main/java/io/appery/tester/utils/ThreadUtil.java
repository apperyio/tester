package io.appery.tester.utils;

import android.os.Looper;

/**
 * Created by Alexandr.Salin on 12/10/15.
 */
public class ThreadUtil {
    public static void checkAndThrowIfUIThread() {
        if (isUIThread()) {
            throw new RuntimeException("Called from UI thread.");
        }
    }

    public static void checkAndThrowIfNonUIThread() {
        if (!isUIThread()) {
            throw new RuntimeException("Called non from UI thread.");
        }
    }

    public static boolean isUIThread() {
        return Looper.myLooper() == Looper.getMainLooper();
    }
}
