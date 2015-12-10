package io.appery.tester.rest.request;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import io.appery.tester.rest.IWebApi;
import retrofit.client.Response;

/**
 * Created by Alexandr.Salin on 11/30/15.
 */
public class SamlRequest extends BaseRequest<Response, IWebApi> {
    private static final Logger logger = LoggerFactory.getLogger(SamlRequest.class);
    private String saml;

    public SamlRequest(String samlValue) {
        super(Response.class, IWebApi.class);
        this.saml = samlValue;
    }

    @Override
    Response loadData() {
        logger.warn("retr saml = {}", saml);
        return getService().doSamlRequest(saml);
    }
}
