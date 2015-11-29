package io.appery.tester.rest.request;

import io.appery.tester.rest.IWebApi;
import retrofit.client.Response;

/**
 * Created by Alexandr.Salin on 11/29/15.
 */
public class LoginRequest extends BaseRequest<Response, IWebApi> {

    public LoginRequest() {
        super(Response.class, IWebApi.class);
    }

    @Override
    Response loadData() {
        return getService().doLogin();
    }
}
