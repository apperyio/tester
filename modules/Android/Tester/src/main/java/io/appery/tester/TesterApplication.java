package io.appery.tester;

import io.appery.tester.net.RestManager;
import android.app.Application;

/**
 * Application for this project.
 * 
 * @author ayakovenko
 * 
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
        if (serverUrl == null) {
            throw new RuntimeException();
        }
        if (!serverUrl.startsWith("https")){
            serverUrl = serverUrl.replaceFirst("http", "https");
        }
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
