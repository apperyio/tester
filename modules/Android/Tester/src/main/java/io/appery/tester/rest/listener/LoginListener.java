package io.appery.tester.rest.listener;

import com.octo.android.robospice.persistence.exception.SpiceException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import io.appery.tester.R;
import io.appery.tester.RestManager;
import io.appery.tester.TesterApplication;
import io.appery.tester.ui.login.callback.AuthCallback;
import io.appery.tester.utils.Constants;
import retrofit.RetrofitError;
import retrofit.client.Response;
import retrofit.mime.TypedByteArray;

/**
 * Created by Alexandr.Salin on 11/30/15.
 */
public class LoginListener extends BaseListener<Response> {
    private static final Logger logger = LoggerFactory.getLogger(LoginListener.class);
    private AuthCallback mAuthCallback;

    public LoginListener(AuthCallback callback) {
        this.mAuthCallback = callback;
    }

    @Override
    public void onRequestFailure(SpiceException spiceException) {
        super.onRequestFailure(spiceException);
        Throwable exception = detectIssue(spiceException);
        if (mAuthCallback != null) {
            mAuthCallback.onAuthFailed(exception);
        }
    }

    private Throwable detectIssue(SpiceException cause) {
        Throwable result = cause;
        if ((cause.getCause() instanceof RetrofitError)) {
            RetrofitError error = (RetrofitError) cause.getCause();
            if (error.getResponse().getStatus() == 500) {
                result = new Exception(TesterApplication.getInstance().getString(R.string.error_incorrect_credentials), cause);
            }
        }
        return result;
    }

    @Override
    public void onRequestSuccess(Response response) {
        super.onRequestSuccess(response);
        String bodyString = new String(((TypedByteArray) response.getBody()).getBytes());
        logger.warn("retrofit {}", bodyString.replaceAll("\n", Constants.EMPTY_STRING));
        //TODO: correct parse
        String saml = bodyString.substring(bodyString.indexOf("VALUE=\"") + 7, bodyString.indexOf("\"/>"));
        String url = bodyString.substring(bodyString.indexOf("ACTION=\"") + 8, bodyString.indexOf("\"><I"));
        if (mAuthCallback != null) {
            RestManager.samlRequest(mAuthCallback, url, saml, new SamlListener(mAuthCallback));
        }
    }

    public void setAuthCallback(AuthCallback callback) {
        this.mAuthCallback = callback;
    }
}
