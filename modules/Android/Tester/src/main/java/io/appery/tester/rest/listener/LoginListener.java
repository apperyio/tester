package io.appery.tester.rest.listener;

import com.octo.android.robospice.persistence.exception.SpiceException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import io.appery.tester.RestManager;
import io.appery.tester.rest.SpiceHolder;
import io.appery.tester.rest.TesterSpiceEndpoint;
import io.appery.tester.utils.Constants;
import retrofit.client.Response;
import retrofit.mime.TypedByteArray;

/**
 * Created by Alexandr.Salin on 11/30/15.
 */
public class LoginListener extends BaseListener<Response> {
    private static final Logger logger = LoggerFactory.getLogger(LoginListener.class);
    private SpiceHolder spiceHolder;

    public LoginListener(SpiceHolder spiceHolder) {
        this.spiceHolder = spiceHolder;
    }

    @Override
    public void onRequestFailure(SpiceException spiceException) {
        super.onRequestFailure(spiceException);
    }

    @Override
    public void onRequestSuccess(Response response) {
        super.onRequestSuccess(response);
        String bodyString = new String(((TypedByteArray) response.getBody()).getBytes());
        logger.warn("retrofit {}",bodyString.replaceAll("\n",Constants.EMPTY_STRING));
        if (spiceHolder != null) {
            RestManager.doSamlRequest(spiceHolder, preparePath(response.getUrl()), new SamlListener());
        }
        logger.warn("retrofit {}",bodyString.toString());
    }

    private String preparePath(String url) {
        return url.replace(new TesterSpiceEndpoint().getUrl(), Constants.EMPTY_STRING);
    }

    public void setSpiceHolder(SpiceHolder spiceHolder) {
        this.spiceHolder = spiceHolder;
    }
}
