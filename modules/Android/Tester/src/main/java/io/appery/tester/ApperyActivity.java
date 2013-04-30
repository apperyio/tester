package io.appery.tester;

import io.appery.tester.utils.ProjectStorageManager;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;

import org.apache.cordova.CordovaChromeClient;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CordovaWebViewClient;
import org.apache.cordova.IceCreamCordovaWebViewClient;
import org.apache.cordova.api.CordovaInterface;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.webkit.ValueCallback;

/**
 * @author Daniel Lukashevich
 */
public class ApperyActivity extends org.apache.cordova.DroidGap {

    private static final String TAG = "ApperyActivity";

    protected static final int FILECHOOSER_RESULTCODE = 101;
    public static final String DEFAULT_ACCEPT_TYPE = "image/*";
    protected ValueCallback<Uri> mUploadMessage;

    @Override
    public void onCreate(Bundle arg0) {
        super.onCreate(arg0);

        String indexPath = "file://" + getStartFileName();


        loadUrlTimeoutValue = 60000;
        clearCache();
        loadUrl(indexPath);
        setBooleanProperty("loadInWebView", true);
    }

    /**
     * Create and initialize web container with default web view objects.
     */
    @Override
    public void init() {
        CordovaWebView webView = new CordovaWebView(this);
        CordovaWebViewClient webViewClient;
        if (android.os.Build.VERSION.SDK_INT < 11) {
            webViewClient = new CordovaWebViewClient(this, webView);
        } else {
            webViewClient = new IceCreamCordovaWebViewClient(this, webView);
        }
        this.init(webView, webViewClient, new ApperyChromeClient(this, webView));
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
                System.err.println("Error: " + e.getMessage());
            }
        }

        return path + File.separator + fileName;
    }

    /** This class is used to make <input type="file" ... /> work in APK **/
    public class ApperyChromeClient extends CordovaChromeClient {
        public ApperyChromeClient(CordovaInterface cordova) {
            super(cordova);
        }

        public ApperyChromeClient(CordovaInterface ctx, CordovaWebView app) {
            super(ctx, app);
        }

        public void openFileChooser(ValueCallback<Uri> uploadMsg) {
            openFileChooser(uploadMsg, DEFAULT_ACCEPT_TYPE);
        }

        public void openFileChooser(ValueCallback<Uri> uploadMsg, String acceptType) {
            if (acceptType == null || acceptType.isEmpty()) {
                acceptType = DEFAULT_ACCEPT_TYPE;
            }
            ApperyActivity.this.mUploadMessage = uploadMsg;
            Intent i = new Intent(Intent.ACTION_GET_CONTENT);
            i.addCategory(Intent.CATEGORY_OPENABLE);
            i.setType(acceptType);
            ApperyActivity.this.startActivityForResult(Intent.createChooser(i, "File Chooser"),
                    ApperyActivity.FILECHOOSER_RESULTCODE);
        }

        public void openFileChooser(ValueCallback<Uri> uploadMsg, String acceptType, String capture) {
            openFileChooser(uploadMsg, acceptType);
        }
    }
}
