package io.appery.tester.ui.login.callback;

import io.appery.tester.rest.SpiceHolder;

/**
 * Created by Alexandr.Salin on 12/2/15.
 */
public interface AuthCallback extends SpiceHolder {
    void onStartAuth();

    void onAuthFailed(Throwable spiceException);

    void onAuthSuccess();
}
