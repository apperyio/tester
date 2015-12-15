package io.appery.tester.utils;

import com.nostra13.universalimageloader.utils.StorageUtils;

import java.io.File;

import io.appery.tester.Constants;
import io.appery.tester.TesterApplication;

public class ProjectStorageManager {

    public static String getBase_DIR() {
        return StorageUtils.getCacheDirectory(TesterApplication.getInstance()).getAbsolutePath();
    }

    public static String getPROJECT_ZIP_FILE() {
        String result = getBase_DIR() + "/arch/";
        File dir = new File(result);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        return result + Constants.FILENAME_ZIP;
    }

    public static String getWORK_DIRECTORY() {
        return getBase_DIR() + "/project";
    }
}
