package io.appery.tester.rest.request;

import io.appery.tester.rest.IWebApi;
import io.appery.tester.rest.TesterSpiceEndpoint;
import io.appery.tester.Constants;
import retrofit.client.Response;

/**
 * Created by Alexandr.Salin on 11/30/15.
 */
public class SamlRequest extends BaseRequest<Response, IWebApi> {
    private String path;
    private String saml;

    public SamlRequest(String path, String samlValue) {
        super(Response.class, IWebApi.class);
        this.path = path;
        this.saml = samlValue;
    }

    @Override
    Response loadData() {
        return getService().doSamlRequest(path.replace(new TesterSpiceEndpoint().getUrl(), Constants.EMPTY_STRING), saml);
    }
}
