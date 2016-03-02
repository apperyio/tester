package io.appery.tester.rest.listener;

import com.octo.android.robospice.persistence.exception.SpiceException;

import io.appery.tester.ui.login.callback.AuthCallback;
import retrofit.client.Response;

/**
 * Created by Alexandr.Salin on 12/3/15.
 */
public class SamlListener extends BaseListener<Response> {

    private AuthCallback mAuthCallback;

    public SamlListener(AuthCallback authCallback) {
        mAuthCallback = authCallback;
    }

    @Override
    public void onRequestFailure(SpiceException spiceException) {
        super.onRequestFailure(spiceException);
        mAuthCallback.onAuthFailed(spiceException);
    }

    @Override
    public void onRequestSuccess(Response response) {
        super.onRequestSuccess(response);
        mAuthCallback.onAuthSuccess();
    }
}
