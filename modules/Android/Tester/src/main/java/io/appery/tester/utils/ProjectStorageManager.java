package io.appery.tester.utils;

import com.nostra13.universalimageloader.utils.StorageUtils;

import io.appery.tester.TesterApplication;

public class ProjectStorageManager {

    public static String getBase_DIR() {
        return StorageUtils.getCacheDirectory(TesterApplication.getInstance()).getAbsolutePath();
    }

    public static String getPROJECT_ZIP_FILE() {
        return getBase_DIR() + "/files/" + Constants.FILENAME_ZIP;
    }

    public static String getWORK_DIRECTORY() {
        return getBase_DIR() + "/app_default";
    }
}
