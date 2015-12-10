package io.appery.tester.utils;

import android.text.TextUtils;

import io.appery.tester.Constants;
import io.appery.tester.db.entity.User;

/**
 * Created by Alexandr.Salin on 11/29/15.
 */
public class UserHelper {
    public static void saveUser(User user) {
        PrefsUtil.getInstance().putString(Constants.PREFERENCES.USERNAME, user.getUsername());
        PrefsUtil.getInstance().putString(Constants.PREFERENCES.PASSWORD, user.getPassword());
    }

    public static User getUser() {
        String username = PrefsUtil.getInstance().getString(Constants.PREFERENCES.USERNAME);
        String password = PrefsUtil.getInstance().getString(Constants.PREFERENCES.PASSWORD);
        User user = new User(username, password);
        user.setTarget(PrefsUtil.getInstance().getString(Constants.PREFERENCES.BASE_URL) + "/app/");
        user.setSamlKey(PrefsUtil.getInstance().getString(Constants.PREFERENCES.SAML_KEY));
        return user;
    }

    static public void updateSAMLKey(String samlKey) {
        PrefsUtil.getInstance().putStringCommit(Constants.PREFERENCES.SAML_KEY, samlKey);
    }

    static public String getSAMLKey() {
        return PrefsUtil.getInstance().getString(Constants.PREFERENCES.SAML_KEY);
    }

    static public boolean hasSAMLKey() {
        return !TextUtils.isEmpty(getSAMLKey());
    }
}
