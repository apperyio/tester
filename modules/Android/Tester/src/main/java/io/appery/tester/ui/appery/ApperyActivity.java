package io.appery.tester.ui.appery;

import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;

import org.apache.cordova.CordovaActivity;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.engine.SystemWebViewEngine;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;

import io.appery.tester.R;
import io.appery.tester.db.entity.ProjectType;
import io.appery.tester.utils.CommonUtil;
import io.appery.tester.utils.ProjectStorageManager;

/**
 * @author Daniel Lukashevich
 */
public class ApperyActivity extends CordovaActivity {

    private static final String TAG = "ApperyActivity";
    private ProjectType projectType;

    @Override
    public void onCreate(Bundle bundle) {
        this.projectType = ProjectType.get(this.getIntent().getIntExtra("project_type", ProjectType.IONIC4.getId()));
        super.onCreate(bundle);
        if (isIonicEngineRequired()) {
            loadUrl("http://localhost:8080/index.html");
        } else {
            loadUrl("file://" + getStartFileName());
        }
        CommonUtil.showMessage(this.getBaseContext(), this.getBaseContext().getString(R.string.stop_an_app_toast));
    }

    @Override
    public void onReceivedError(int errorCode, String description, String failingUrl) {
        Log.e(TAG, "An error received: \"" + description + "\" at '" + failingUrl + "'");
    }

    /* (non-Javadoc)
     * @see org.apache.cordova.CordovaActivity#onKeyUp(int, android.view.KeyEvent)
     */
    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        boolean result = super.onKeyUp(keyCode, event);
        // End activity if return to projects list
        if (keyCode == KeyEvent.KEYCODE_BACK && event.getEventTime() - event.getDownTime() > 2000) {
            Log.d(TAG, "Finish activity");
            finish();
        }
        return result;
    }

    @Override
    protected CordovaWebView makeWebView() {
        if (isIonicEngineRequired()) {
            preferences.set("webview", "com.ionicframework.cordova.webview.IonicWebViewEngine");
        } else {
            preferences.set("webview", SystemWebViewEngine.class.getCanonicalName());
        }
        return super.makeWebView();
    }

    private String getStartFileName() {
        String path = ProjectStorageManager.getWORK_DIRECTORY().getAbsolutePath();
        String fileName = "index.html";

        File descriptor = new File(path, "descriptor.txt");
        if (descriptor.exists()) {
            try {
                FileInputStream fstream = new FileInputStream(descriptor);
                // Get the object of DataInputStream
                DataInputStream in = new DataInputStream(fstream);
                BufferedReader br = new BufferedReader(new InputStreamReader(in));
                String strLine = br.readLine();
                if (strLine != null) {
                    fileName = strLine.trim();
                }
                in.close();
            } catch (Exception e) {
                Log.e(TAG, "Can't define start file name", e);
            }
        }

        return path + File.separator + fileName;
    }

    private boolean isIonicEngineRequired() {
//        return this.projectType == ProjectType.IONIC4;
        return true;
    }
}
