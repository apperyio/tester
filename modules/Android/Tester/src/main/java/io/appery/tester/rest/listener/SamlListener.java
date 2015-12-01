package io.appery.tester.rest.listener;

import com.octo.android.robospice.persistence.exception.SpiceException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import io.appery.tester.utils.UserHelper;
import retrofit.client.Response;
import retrofit.mime.TypedByteArray;

/**
 * Created by Alexandr.Salin on 11/30/15.
 */
public class SamlListener extends BaseListener<Response> {
    private static final Logger logger = LoggerFactory.getLogger(SamlListener.class);
    @Override
    public void onRequestFailure(SpiceException spiceException) {
        super.onRequestFailure(spiceException);
    }

    @Override
    public void onRequestSuccess(Response response) {
        super.onRequestSuccess(response);
        String bodyString = new String(((TypedByteArray) response.getBody()).getBytes());
        logger.warn("retrofit {}",bodyString.toString());
        bodyString.replace("1","2");
       // UserHelper.updateSAMLKey(parseHtml(bodyString));
    }

    private String parseHtml(String bodyString) {
        String saml = bodyString.substring(bodyString.indexOf("VALUE=\"") + 7, bodyString.indexOf("\"/>"));
        String url = bodyString.substring(bodyString.indexOf("ACTION=\"") + 8, bodyString.indexOf("\"><I"));
        return saml;
    }
}
