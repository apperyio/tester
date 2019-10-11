package io.appery.tester.utils;

import android.content.Context;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Objects;

import io.appery.tester.R;
import io.appery.tester.db.entity.ProjectType;

public class CordovaUtils {

  private static final String CORDOVA_4_1_1 = "4.1.1";
  private static final String CORDOVA_5_2_2 = "5.2.2";
  private static final String CORDOVA_7_1_4 = "7.1.4";
  private static final String CORDOVA_8_0_0 = "8.0.0";
  private static final String CORDOVA_8_0_0_IONIC = "8.0.0-ionic";
  private static final String CORDOVA_LATEST = CORDOVA_8_0_0;
  private static final Map<ProjectType, Map<String, String>> CORDOVA_VERSIONS;
  private static Map<String, CordovaAssetsData> CORDOVA_ASSETS_META;

  static {
    CORDOVA_VERSIONS = new HashMap<>();

    Map<String, String> jqm = new HashMap<>();
    jqm.put("v4.1", CORDOVA_7_1_4);
    jqm.put("v5.0", CORDOVA_7_1_4);
    jqm.put("v5.1", CORDOVA_8_0_0);
    CORDOVA_VERSIONS.put(ProjectType.JQM, jqm);

    Map<String, String> angular = new HashMap<>();
    angular.put("v1.1", CORDOVA_4_1_1);
    angular.put("v1.2", CORDOVA_5_2_2);
    angular.put("v1.3", CORDOVA_7_1_4);
    angular.put("v2.0", CORDOVA_7_1_4);
    angular.put("v2.1", CORDOVA_8_0_0);
    CORDOVA_VERSIONS.put(ProjectType.ANGULAR, angular);
    CORDOVA_VERSIONS.put(ProjectType.ANGULAR_IONIC, angular);

    Map<String, String> ionic3 = new HashMap<>();
    ionic3.put("v1.0", CORDOVA_8_0_0_IONIC);
    CORDOVA_VERSIONS.put(ProjectType.IONIC3, ionic3);

    Map<String, String> ionic4 = new HashMap<>();
    ionic4.put("v1.0", CORDOVA_8_0_0_IONIC);
    ionic4.put("v1.1", CORDOVA_8_0_0_IONIC);
    CORDOVA_VERSIONS.put(ProjectType.IONIC4, ionic4);
  }

  public static String getCordovaVersion(ProjectType projectType, String libVersion) {
    Map<String, String> versionsMap = CORDOVA_VERSIONS.get(projectType);
    if (versionsMap != null && libVersion != null) {
      if (versionsMap.containsKey(libVersion)) {
        return versionsMap.get(libVersion);
      }
    }
    return CORDOVA_LATEST;
  }

  public static void prepareAllCordovaResources(Context context, File baseDir) {
    for (String cordovaVersion: getCordovaAssetsMeta().keySet()) {
      prepareCordovaResources(context, cordovaVersion, baseDir);
    }
  }

  public static void prepareCordovaResources(Context context, String cordovaVersion, File baseDir) {
    CordovaAssetsData data = getCordovaAssetsData(cordovaVersion);
    File cordovaArchiveFile = new File(baseDir, data.fileName);
    File destDir = new File(baseDir, data.rootDirectory);

    FileUtils.prepareDirectory(destDir);
    FileUtils.copyAsset(context, data.fileName, cordovaArchiveFile);
    try {
      FileUtils.unzip(cordovaArchiveFile, destDir);
      FileUtils.removeFile(cordovaArchiveFile);
    } catch (IOException e) {
      CommonUtil.showToast(context.getString(R.string.preview_error_toast));
    }
  }

  static CordovaAssetsData getCordovaAssetsData(String cordovaVersion) {
    Map<String, CordovaAssetsData> meta = getCordovaAssetsMeta();
    if (meta.containsKey(cordovaVersion)) {
      return Objects.requireNonNull(meta.get(cordovaVersion));
    }
    return Objects.requireNonNull(meta.get(CORDOVA_LATEST));
  }

  static Map<String, CordovaAssetsData> getCordovaAssetsMeta() {
    if (CORDOVA_ASSETS_META == null) {
      CORDOVA_ASSETS_META = new LinkedHashMap<>();
      CORDOVA_ASSETS_META.put(CORDOVA_4_1_1, new CordovaAssetsData("cordova_resources_4_1_1.zip", "/files/resources/lib/"));
      CORDOVA_ASSETS_META.put(CORDOVA_5_2_2, new CordovaAssetsData("cordova_resources_5_2_2.zip", "/libs/"));
      CORDOVA_ASSETS_META.put(CORDOVA_7_1_4, new CordovaAssetsData("cordova_resources_7_1_4.zip", "/"));
      CORDOVA_ASSETS_META.put(CORDOVA_8_0_0, new CordovaAssetsData("cordova_resources_8_0_0.zip", "/"));
      CORDOVA_ASSETS_META.put(CORDOVA_8_0_0_IONIC, new CordovaAssetsData("cordova_resources_8_0_0_ionic.zip", "/"));
    }
    return  CORDOVA_ASSETS_META;
  }

  private static class CordovaAssetsData {

    String fileName;
    String rootDirectory;

    CordovaAssetsData(String fileName, String rootDirectory) {
      this.fileName = fileName;
      this.rootDirectory = rootDirectory;
    }
  }
}
