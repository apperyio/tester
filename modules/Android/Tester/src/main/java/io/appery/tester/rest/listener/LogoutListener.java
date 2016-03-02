package io.appery.tester.rest.listener;

import android.content.Context;

import com.afollestad.materialdialogs.MaterialDialog;
import com.octo.android.robospice.persistence.exception.SpiceException;

import io.appery.tester.Constants;
import io.appery.tester.utils.DialogHelper;
import io.appery.tester.utils.UserHelper;
import retrofit.client.Response;

/**
 * Created by Alexandr.Salin on 12/13/15.
 */
public class LogoutListener extends BaseListener<Response> {

    private Context context;
    private MaterialDialog dialog;

    public LogoutListener(Context ctx) {
        this.context = ctx;
    }

    public void onStart() {
        dialog = DialogHelper.buildLogoutProgressDialog(context);
    }

    @Override
    public void onRequestFailure(SpiceException spiceException) {
        super.onRequestFailure(spiceException);
        dialog.dismiss();
        clean();
    }

    @Override
    public void onRequestSuccess(Response response) {
        super.onRequestSuccess(response);
        dialog.dismiss();
        clean();
    }

    private void clean() {
        UserHelper.updateSAMLKey(Constants.EMPTY_STRING);
    }
}
