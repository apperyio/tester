package io.appery.tester.ui.appery;

import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;

import org.apache.cordova.CordovaActivity;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;

import io.appery.tester.utils.ProjectStorageManager;

/**
 * @author Daniel Lukashevich
 */
public class ApperyActivity extends CordovaActivity {

    private static final String TAG = "ApperyActivity";

    @Override
    public void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        loadUrl("file://" + getStartFileName());
    }

    @Override
    public void onReceivedError(int errorCode, String description, String failingUrl) {
        Log.e(TAG, "An error received: \"" + description + "\" at '" + failingUrl + "'");
    }

    private String getStartFileName() {
        String path = ProjectStorageManager.getWORK_DIRECTORY();
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

    /* (non-Javadoc)
     * @see org.apache.cordova.CordovaActivity#onKeyUp(int, android.view.KeyEvent)
     */
    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        boolean result = super.onKeyUp(keyCode, event);
        // End activity if return to projects list
        if (result) {
            finish();
        }
        return result;
    }
}
