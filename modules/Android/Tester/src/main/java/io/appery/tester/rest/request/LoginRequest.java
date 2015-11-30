package io.appery.tester.rest.request;

import io.appery.tester.db.entity.User;
import io.appery.tester.rest.IWebApi;
import io.appery.tester.utils.UserHelper;
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
        User user = UserHelper.getUser();
        return getService().doLogin(user.getUsername(), user.getPassword(), user.getTarget());
    }
}
