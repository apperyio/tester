package io.appery.tester.utils;

import android.content.Context;

import com.afollestad.materialdialogs.MaterialDialog;

import io.appery.tester.R;

/**
 * Created by Alexandr.Salin on 12/2/15.
 */
public class DialogHelper {
    static public MaterialDialog buildAuthProgressDialog(Context context) {
        return new MaterialDialog.Builder(context)
                .title(R.string.signing_in)
                .content(R.string.please_wait)
                .progress(true, 0)
                .cancelable(false)
                .show();
    }
}
