package io.appery.tester;

import android.app.Application;

import io.appery.tester.net.RestManager;

/**
 * Application for this project.
 *
 * @author ayakovenko
 */
public class TesterApplication extends Application {
    private static TesterApplication instance;
    private RestManager restManager = null;

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;
    }

    public static TesterApplication getInstance() {
        return instance;
    }

    public void setBaseURL(String serverUrl) {
        if ((restManager == null) || (!serverUrl.equals(restManager.getBaseURL()))) {
            restManager = new RestManager(serverUrl);
        }
    }

    public RestManager getRestManager() {
        if (restManager == null) {
            throw new RuntimeException("Base URL is not set");
        }
        return restManager;
    }

}
