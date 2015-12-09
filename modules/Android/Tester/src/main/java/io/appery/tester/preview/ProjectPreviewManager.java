package io.appery.tester.preview;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;

import org.apache.http.client.ClientProtocolException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import io.appery.tester.ApperyActivity;
import io.appery.tester.R;
import io.appery.tester.tasks.DownloadFileTask;
import io.appery.tester.tasks.callback.DownloadFileCallback;
import io.appery.tester.ui.base.activity.BaseActivity;
import io.appery.tester.utils.CommonUtil;
import io.appery.tester.utils.Constants;
import io.appery.tester.utils.FileUtils;
import io.appery.tester.utils.IntentUtils;
import io.appery.tester.utils.NoProjectSourceException;
import io.appery.tester.utils.ProjectStorageManager;

/**
 * Created by Maxim Balyaba on 09.07.2015.
 */
public class ProjectPreviewManager implements DownloadFileCallback {
    private static final Logger logger = LoggerFactory.getLogger(ProjectPreviewManager.class);

    private Context activityContext;

    private String DEBUG_ON_SERVICE_PARAM = "debug=true";

    private String DEBUG_OFF_SERVICE_PARAM = "debug=false";


    /**
     * Contains Cordova resources archive as key and directory as a value.
     */
    private Map<String, String> CORDOVA_RESOURCES;

    public ProjectPreviewManager(Context context) {
        this.activityContext = context;

        CORDOVA_RESOURCES = new HashMap<String, String>();
        CORDOVA_RESOURCES.put("cordova_resources.zip", "/files/resources/lib/");
        CORDOVA_RESOURCES.put("cordova_resources_3.0.zip", "/libs/");
    }

    public void downloadAndStartProjectPreview(String projectURL) {
        DownloadFileTask getApkTask = new DownloadFileTask(activityContext,
                Constants.FILENAME_ZIP, this, new DownloadFileTask.DownloadFileErrorCallback() {
            @Override
            public void onFileDownloadError(Throwable exception) {
                processErrorException(exception);
            }
        });
        getApkTask.execute(projectURL + "?" + DEBUG_OFF_SERVICE_PARAM);
    }

    public void downloadAndStartProjectPreviewByCode(String accessCode) {
        DownloadFileTask getApkTask = new DownloadFileTask(activityContext, Constants.FILENAME_ZIP, this, new DownloadFileTask.DownloadFileErrorCallback() {
            @Override
            public void onFileDownloadError(Throwable exception) {
                if (exception != null && exception instanceof NoProjectSourceException) {
                    NoProjectSourceException noSourceException = (NoProjectSourceException) exception;
                    if (noSourceException.getErrorCode() != null) {
                        if (noSourceException.getErrorCode().intValue() == 404) {
                            CommonUtil.showMessage(activityContext, activityContext.getString(R.string.preview_by_code_not_found_error_toast));
                            return;
                        }
                        if (noSourceException.getErrorCode().intValue() == 403) {
                            CommonUtil.showMessage(activityContext, activityContext.getString(R.string.preview_by_code_expired_error_toast));
                            return;
                        }
                    }
                }
                processErrorException(exception);
            }
        });
        getApkTask.execute(String.format(Constants.API.GET_PROJECT_RESOURCE_BY_CODE, Uri.encode(accessCode)));
    }

    private void processErrorException(Throwable exception) {
        if (exception != null && exception instanceof ClientProtocolException) {
            CommonUtil.showMessage(activityContext, "Can't execute request");
            return;
        }
        if (exception != null && exception instanceof IOException) {
            CommonUtil.showMessage(activityContext, "Unable to connect");
            return;
        }
        CommonUtil.showMessage(activityContext, activityContext.getString(R.string.application_download_error_toast));
    }

    @Override
    public void onFileDownloaded(File file) {
        String fName = file.getName();
        if (Constants.FILENAME_APK.equals(fName)) {
            boolean install = new IntentUtils(activityContext).installApk(file);
            if (!install) {
                CommonUtil.showToast(activityContext.getString(R.string.application_download_error_toast));
            }
        } else if (Constants.FILENAME_ZIP.equals(fName)) {
            // Unzip
            String dirPath = ProjectStorageManager.getWORK_DIRECTORY();
            try {
                FileUtils.checkDir(dirPath);
                FileUtils.clearDirectory(dirPath);
                FileUtils.unzip(ProjectStorageManager.getPROJECT_ZIP_FILE(), dirPath);
                replaceCordovaResources(dirPath);
                Intent intent = new Intent(activityContext, ApperyActivity.class);
                activityContext.startActivity(intent);
            } catch (IOException e) {
                logger.error("Not able , try again later", e);
                CommonUtil.showToast(activityContext.getString(R.string.preview_error_toast));
            }
        }
    }

    private void replaceCordovaResources(String dirPath) {
        for (String archive : this.CORDOVA_RESOURCES.keySet()) {
            String path = dirPath + this.CORDOVA_RESOURCES.get(archive);
            String cordovaArchiveFullPath = path + archive;

            FileUtils.checkDir(path);
            FileUtils.copyAsset(activityContext, archive, cordovaArchiveFullPath);
            try {
                FileUtils.unzip(cordovaArchiveFullPath, path);
                FileUtils.removeFile(cordovaArchiveFullPath);
            } catch (IOException e) {
                logger.error("Not able , try again later", e);
                CommonUtil.showToast(activityContext.getString(R.string.preview_error_toast));
            }
        }
    }

}
