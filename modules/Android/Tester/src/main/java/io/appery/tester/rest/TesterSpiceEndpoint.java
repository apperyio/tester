package io.appery.tester.rest;

import io.appery.tester.R;
import io.appery.tester.TesterApplication;
import io.appery.tester.utils.Constants;
import io.appery.tester.utils.PrefsUtil;
import io.appery.tester.utils.UserHelper;
import retrofit.Endpoint;

/**
 * Created by Alexandr.Salin on 11/29/15.
 */
public class TesterSpiceEndpoint implements Endpoint {
    @Override
    public String getUrl() {
        String defUrl = TesterApplication.getInstance().getString(R.string.base_url);
        String url = PrefsUtil.getInstance().getString(Constants.PREFERENCES.BASE_URL, defUrl);
        return UserHelper.hasSAMLKey() ? url : buildIdp(url);
    }

    private String buildIdp(String url) {
        return new StringBuilder(url).insert("https://".length(), "idp.").toString();
    }

    @Override
    public String getName() {
        throw new UnsupportedOperationException("do not use in this implementation");
    }
}
