package io.appery.tester.net.api.callback;

/**
 * @author Daniel Lukashevich
 */
public interface LoginCallback {

    public void onLoginSuccess(String hash);

    public void onLoginFailed(String errorMessage);

}
