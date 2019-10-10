package io.appery.tester.utils;

import com.nostra13.universalimageloader.utils.StorageUtils;

import java.io.File;

import io.appery.tester.Constants;
import io.appery.tester.TesterApplication;

public class ProjectStorageManager {

    public static File getBase_DIR() {
        return StorageUtils.getCacheDirectory(TesterApplication.getInstance()).getAbsoluteFile();
    }

    public static File getPROJECT_ZIP_FILE() {
        File dir = new File(getBase_DIR(), "arch");
        if (!dir.exists()) {
            dir.mkdirs();
        }
        return new File(dir, Constants.FILENAME_ZIP);
    }

    public static File getWORK_DIRECTORY() {
        return new File(getBase_DIR(), "project");
    }
}
