package io.appery.tester.utils;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashSet;
import java.util.Set;

import io.appery.tester.TesterApplication;

/**
 * Base class for working with SharedPreferences
 * Created by Alexandr.Salin on 11/28/15.
 */
public class PrefsUtil {
    private static final Logger logger = LoggerFactory.getLogger(PrefsUtil.class);
    public static final String PREFERENCES_NAME = "PicPlaySP";

    private static PrefsUtil sInstance = new PrefsUtil();
    ;
    private SharedPreferences mSharedPreferences;

    private PrefsUtil() {
       // mSharedPreferences = TesterApplication.getInstance().getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE);
        mSharedPreferences = PreferenceManager.getDefaultSharedPreferences(TesterApplication.getInstance());;
    }

    public static PrefsUtil getInstance() {
        return sInstance;
    }

    public void putString(String key, String value) {
        SharedPreferences.Editor editor = mSharedPreferences.edit();
        editor.putString(key, value);
        editor.apply();
    }

    public void putStringCommit(String key, String value) {
        SharedPreferences.Editor editor = mSharedPreferences.edit();
        editor.putString(key, value);
        editor.commit();
    }

    public void clearAll() {
        SharedPreferences.Editor editor = mSharedPreferences.edit();
        editor.clear();
        editor.apply();
    }

    public void clearValue(String key) {
        SharedPreferences.Editor editor = mSharedPreferences.edit();
        editor.remove(key);
        editor.apply();
    }

    public void putInt(String key, int value) {
        SharedPreferences.Editor editor = mSharedPreferences.edit();
        editor.putInt(key, value);
        editor.apply();
    }

    public void putFloat(String key, float value) {
        SharedPreferences.Editor editor = mSharedPreferences.edit();
        editor.putFloat(key, value);
        editor.apply();
    }

    public float getFloat(String key, float defaultValue) {
        float value = mSharedPreferences.getFloat(key, defaultValue);
        return value;
    }

    public String getString(String key) {
        String value = mSharedPreferences.getString(key, "");
        return value;
    }

    public String getString(String key, String defValue) {
        return mSharedPreferences.getString(key, defValue);
    }

    public int getInt(String key) {
        int value = mSharedPreferences.getInt(key, -1);
        return value;
    }

    public int getInt(String key, int defValue) {
        int value = mSharedPreferences.getInt(key, defValue);
        return value;
    }

    public void putBool(String key, boolean value) {
        SharedPreferences.Editor editor = mSharedPreferences.edit();
        editor.putBoolean(key, value);
        logger.info("put bool key {}, value {}", key, value);
        editor.apply();
    }

    public boolean getBoolean(String key) {
        boolean value = mSharedPreferences.getBoolean(key, false);
        logger.info("get bool key {}, value {}", key, value);
        return value;
    }

    public boolean getBoolean(String key, boolean defValue) {
        boolean value = mSharedPreferences.getBoolean(key, defValue);
        logger.info("get bool key {}, value {}", key, value);
        return value;
    }

    public void putStringSet(String key, Set<String> value) {
        SharedPreferences.Editor editor = mSharedPreferences.edit();
        editor.putStringSet(key, value);
        editor.apply();
    }

    public Set<String> getStringSet(String key) {
        return mSharedPreferences.getStringSet(key, new HashSet<String>());
    }

}

