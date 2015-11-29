package io.appery.tester;

import com.octo.android.robospice.request.listener.RequestListener;

import java.util.concurrent.TimeUnit;

import io.appery.tester.db.entity.User;
import io.appery.tester.rest.SpiceHolder;
import io.appery.tester.rest.request.LoginRequest;
import io.appery.tester.utils.Constants;
import io.appery.tester.utils.UserHelper;
import retrofit.client.Response;

/**
 * Created by Alexandr.Salin on 11/28/15.
 */
public class RestManager {

    public static void doLogin(SpiceHolder holder, User user, RequestListener<Response> listener) {
        UserHelper.saveUser(user);
        holder.getSpiceManager().execute(new LoginRequest(), Constants.API.LOGIN, TimeUnit.SECONDS.toMillis(60), listener);
    }

    public static void doLogout() {
    }

}
