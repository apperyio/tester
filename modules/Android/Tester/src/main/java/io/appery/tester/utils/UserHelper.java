package io.appery.tester.utils;

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
        return user;
    }

    static public void updateLocation(String location) {
        PrefsUtil.getInstance().putString(Constants.PREFERENCES.LOCATION, location);
    }
}
