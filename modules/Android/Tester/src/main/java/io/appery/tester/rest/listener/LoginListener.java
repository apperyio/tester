package io.appery.tester.rest.listener;

import com.octo.android.robospice.persistence.exception.SpiceException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import io.appery.tester.R;
import io.appery.tester.RestManager;
import io.appery.tester.TesterApplication;
import io.appery.tester.ui.login.callback.AuthCallback;
import io.appery.tester.Constants;
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
            if (error.getResponse() != null && error.getResponse().getStatus() == 500) {
                result = new Exception(TesterApplication.getInstance().getString(R.string.error_incorrect_credentials), cause);
            }else{
                result = error;
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
        try {
            String saml = bodyString.substring(bodyString.indexOf("VALUE=\"") + 7, bodyString.indexOf("\"/>"));
            logger.warn("after retrofit login success we obtain and saml : {}", saml);
            if (mAuthCallback != null) {
                RestManager.samlRequest(mAuthCallback, saml, new SamlListener(mAuthCallback));
            }
        } catch (Exception e) {
            if (mAuthCallback != null) {
                mAuthCallback.onAuthFailed(e);
            }
        }
    }

    public void setAuthCallback(AuthCallback callback) {
        this.mAuthCallback = callback;
    }
}
