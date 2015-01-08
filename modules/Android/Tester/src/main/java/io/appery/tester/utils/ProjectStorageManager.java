package io.appery.tester.utils;

import android.os.Environment;

public class ProjectStorageManager {

    public static String getBase_DIR() {
        return Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState()) ? Environment
                .getExternalStorageDirectory() + "/data/io.appery.tester" : Environment.getDataDirectory()
                + "/data/io.appery.tester";
    }

    public static String getPROJECT_ZIP_FILE() {
        return getBase_DIR() + "/files/" + Constants.FILENAME_ZIP;
    }

    public static String getWORK_DIRECTORY() {
        return getBase_DIR() + "/.app_default";
    }

    public static String getOLD_WORK_DIRECTORY() {
        return getBase_DIR() + "/app_default";
    }
}
