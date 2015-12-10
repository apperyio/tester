package io.appery.tester;

import android.app.Application;

/**
 * Application for this project.
 *
 * @author ayakovenko
 */
public class TesterApplication extends Application {
    private static TesterApplication instance;

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;
    }

    public static TesterApplication getInstance() {
        return instance;
    }
}
