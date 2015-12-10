package io.appery.tester.ui.appery;

import io.appery.tester.utils.ProjectStorageManager;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;

import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.webkit.ValueCallback;

/**
 * @author Daniel Lukashevich
 */
public class ApperyActivity extends org.apache.cordova.CordovaActivity {

    private static final String TAG = "ApperyActivity";

    protected static final int FILECHOOSER_RESULTCODE = 101;
    public static final String DEFAULT_ACCEPT_TYPE = "image/*";
    protected ValueCallback<Uri> mUploadMessage;

    @Override
    public void onCreate(Bundle arg0) {
        super.onCreate(arg0);

        String indexPath = "file://" + getStartFileName();

        //TODO: not ability after update cordova
        //loadUrlTimeoutValue = 60000;
        //clearCache();
        loadUrl(indexPath);
    }

    @Override
    public void onReceivedError(int errorCode, String description, String failingUrl) {
        Log.e(TAG, "An error received: \"" + description + "\" at '" + failingUrl + "'");
        // super.onReceivedError(errorCode, description, failingUrl);
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
            } catch (Exception e) {// Catch exception if any
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
