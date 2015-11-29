package io.appery.tester.rest;

import android.util.Base64;

import io.appery.tester.utils.Constants;
import io.appery.tester.utils.PrefsUtil;
import retrofit.RequestInterceptor;

/**
 * Created by Alexandr.Salin on 11/29/15.
 */
public class TesterRequestInterceptor implements RequestInterceptor {
    @Override
    public void intercept(RequestFacade request) {
        String username = PrefsUtil.getInstance().getString(Constants.PREFERENCES.USERNAME);
        String password = PrefsUtil.getInstance().getString(Constants.PREFERENCES.PASSWORD);
        String basicAuth = "Basic " + Base64.encodeToString(String.format("%s:%s", username, password).getBytes(), Base64.NO_WRAP);
        request.addHeader("Authorization", basicAuth);
    }
}
