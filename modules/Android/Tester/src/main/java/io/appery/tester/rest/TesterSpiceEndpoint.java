package io.appery.tester.rest;

import android.text.TextUtils;

import io.appery.tester.Constants;
import io.appery.tester.R;
import io.appery.tester.TesterApplication;
import io.appery.tester.utils.PrefsUtil;
import io.appery.tester.utils.UserHelper;
import retrofit.Endpoint;

/**
 * Created by Alexandr.Salin on 11/29/15.
 */
public class TesterSpiceEndpoint implements Endpoint {
    @Override
    public String getUrl() {
        return getBaseIdpUrl();
    }

    private static String buildIdp(String url) {
        if (!url.contains("https://")) {
            throw new IllegalArgumentException("Use only https protocol!");
        }
        return new StringBuilder(url).insert("https://".length(), "idp.").toString();
    }

    @Override
    public String getName() {
        throw new UnsupportedOperationException("do not use in this implementation");
    }

    public static String getBaseIdpUrl() {
        String url = getBaseUrl();
        return UserHelper.hasSAMLKey() ? url : buildIdp(url);
    }

    public static String getBaseUrl() {
        String defUrl = TesterApplication.getInstance().getString(R.string.base_url);
        String url = PrefsUtil.getInstance().getString(Constants.PREFERENCES.BASE_URL);
        if (TextUtils.isEmpty(url)) {
            PrefsUtil.getInstance().putString(Constants.PREFERENCES.BASE_URL, defUrl);
            url = defUrl;
        }
        return url;
    }

}
