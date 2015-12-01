package io.appery.tester.rest;

import java.io.IOException;
import java.net.CookieHandler;
import java.net.CookieManager;
import java.net.URI;
import java.util.List;
import java.util.Map;

import io.appery.tester.utils.PrefsUtil;

/**
 * Created by Alexandr.Salin on 11/30/15.
 */
public class TesterCookieStore extends CookieManager {
    public static final String COOKIE_TAG = "cookie";
    @Override
    public Map<String, List<String>> get(URI uri, Map<String, List<String>> requestHeaders) throws IOException {
        return null;
    }

    @Override
    public void put(URI uri, Map<String, List<String>> stringListMap) throws IOException {
        super.put(uri, stringListMap);
        if (stringListMap != null && stringListMap.get("Set-Cookie") != null)
            for (String string : stringListMap.get("Set-Cookie")) {
                if (string.contains("JSESSIONID")) {
                    PrefsUtil.getInstance().putString(COOKIE_TAG,string);
                }
            }
    }

    static public String getSessionId(){
        return PrefsUtil.getInstance().getString(COOKIE_TAG);
    }
}
