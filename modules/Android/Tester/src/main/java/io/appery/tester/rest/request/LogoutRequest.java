package io.appery.tester.rest.request;

import io.appery.tester.rest.IWebApi;
import retrofit.client.Response;

/**
 * Created by Alexandr.Salin on 12/7/15.
 */
public class LogoutRequest extends BaseRequest<Response, IWebApi> {

    public LogoutRequest() {
        super(Response.class, IWebApi.class);
    }

    @Override
    Response loadData() {
        return getService().doLogout();
    }
}
