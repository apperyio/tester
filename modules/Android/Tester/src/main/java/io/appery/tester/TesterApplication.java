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

    private RestManager restManager = null;

    /**
     * Create new instance of application.
     */
    public TesterApplication() {

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
