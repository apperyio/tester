package io.appery.tester.rest.request;

import io.appery.tester.rest.IWebApi;
import retrofit.client.Response;

/**
 * Created by Alexandr.Salin on 11/30/15.
 */
public class SamlRequest extends BaseRequest<Response,IWebApi> {
    private String path;

    public SamlRequest(String path) {
        super(Response.class,IWebApi.class);
        this.path = path;
    }

    @Override
    Response loadData() {
        return getService().doSamlRequest(path);
    }
}
