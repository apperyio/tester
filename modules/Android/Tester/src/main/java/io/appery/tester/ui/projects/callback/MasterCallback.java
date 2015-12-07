package io.appery.tester.ui.projects.callback;

/**
 * Created by Alexandr.Salin on 12/6/15.
 */
public interface MasterCallback {
    void onRegister(SlaveCallback slave);

    void unRegister();
}
