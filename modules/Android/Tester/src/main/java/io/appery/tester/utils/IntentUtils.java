package io.appery.tester.utils;

import java.io.File;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;

/**
 * @author Daniel Lukashevich
 */
public class IntentUtils {

    private Context mContext;

    /**
     * Create new instance.
     */
    public IntentUtils(Context ctx) {
        mContext = ctx;
    }

    public final boolean installApk(String sUri) {
        return false;
    }

    /**
     * Install application from Uri
     * 
     * @param uri
     *            - uri to file
     * @return
     */
    public final boolean installApk(Uri uri) {
        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setDataAndType(uri, "application/vnd.android.package-archive");
        mContext.startActivity(intent);

        return true;
    }

    /**
     * Install application on the phone
     * 
     * @param file
     *            - apk file
     * @return
     */
    public final boolean installApk(File file) {
        if (file != null && file.exists()) {
            return installApk(Uri.fromFile(file));
        }

        return false;
    }

}
