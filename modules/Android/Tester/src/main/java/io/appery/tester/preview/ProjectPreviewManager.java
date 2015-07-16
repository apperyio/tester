package io.appery.tester.preview;

import android.net.Uri;

import org.apache.http.client.ClientProtocolException;

import java.io.File;
import java.io.IOException;

import io.appery.tester.ApperyActivity;
import io.appery.tester.BaseActivity;
import io.appery.tester.R;
import io.appery.tester.net.RestManager;
import io.appery.tester.tasks.DownloadFileTask;
import io.appery.tester.tasks.callback.DownloadFileCallback;
import io.appery.tester.utils.Constants;
import io.appery.tester.utils.FileUtils;
import io.appery.tester.utils.IntentUtils;
import io.appery.tester.utils.NoProjectSourceException;
import io.appery.tester.utils.ProjectStorageManager;
import io.appery.tester.utils.ToastUtils;

/**
 * Created by Maxim Balyaba on 09.07.2015.
 */
public class ProjectPreviewManager implements DownloadFileCallback {

    private RestManager restManager;

    private BaseActivity activityContext;

    private String DEBUG_ON_SERVICE_PARAM = "debug=true";

    private String DEBUG_OFF_SERVICE_PARAM = "debug=false";

    private static final String CORDOVA_LIB_DIR = "/files/resources/lib/";

    private static final String CORDOVA_ANGULAR_LIB_DIR = "/libs/";

    public ProjectPreviewManager(RestManager restManager, BaseActivity context) {
        this.restManager = restManager;
        this.activityContext = context;
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
        restManager.setBaseURL(restManager.getBaseURLConstant());
        DownloadFileTask getApkTask = new DownloadFileTask(activityContext, Constants.FILENAME_ZIP, this, new DownloadFileTask.DownloadFileErrorCallback() {
            @Override
            public void onFileDownloadError(Throwable exception) {
                if (exception != null && exception instanceof NoProjectSourceException) {
                    NoProjectSourceException noSourceException = (NoProjectSourceException) exception;
                    if (noSourceException.getErrorCode() != null) {
                        if (noSourceException.getErrorCode().intValue() == 404) {
                            ToastUtils.showMessage(activityContext, activityContext.getString(R.string.preview_by_code_not_found_error_toast));
                            return;
                        }
                        if (noSourceException.getErrorCode().intValue() == 403) {
                            ToastUtils.showMessage(activityContext, activityContext.getString(R.string.preview_by_code_expired_error_toast));
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
            ToastUtils.showMessage(activityContext, "Can't execute request");
            return;
        }
        if (exception != null && exception instanceof IOException) {
            ToastUtils.showMessage(activityContext, "Unable to connect");
            return;
        }
        ToastUtils.showMessage(activityContext, activityContext.getString(R.string.application_download_error_toast));
    }

    @Override
    public void onFileDownloaded(File file) {
        //  TODO - Check filename and do what you need
        // apk file - install
        String fName = file.getName();
        if (Constants.FILENAME_APK.equals(fName)) {
            boolean install = new IntentUtils(activityContext).installApk(file);
            if (!install) {
                activityContext.showToast(activityContext.getString(R.string.application_download_error_toast));
            }
        } else if (Constants.FILENAME_ZIP.equals(fName)) {
            // Unzip
            String dirPath = ProjectStorageManager.getWORK_DIRECTORY();
            try {
                FileUtils.checkDir(dirPath);
                FileUtils.clearDirectory(dirPath);
                FileUtils.unzip(ProjectStorageManager.getPROJECT_ZIP_FILE(), dirPath);
                replaceCordovaResources(dirPath);
                activityContext.startActivity(ApperyActivity.class);
            } catch (IOException e) {
                e.printStackTrace();
                activityContext.showToast(activityContext.getString(R.string.preview_error_toast));
            }
        }
    }

    private void replaceCordovaResources(String dirPath) {
        String path = dirPath + this.CORDOVA_LIB_DIR;
        if (!FileUtils.isDirExists(path)) {
            path = dirPath + this.CORDOVA_ANGULAR_LIB_DIR;
        }
        String cordovaAssetArchiveFileName = "cordova_resources.zip";
        FileUtils.copyAsset(activityContext, cordovaAssetArchiveFileName, path + cordovaAssetArchiveFileName);
        try {
            FileUtils.unzip(path + cordovaAssetArchiveFileName, path);
            FileUtils.removeFile(path + cordovaAssetArchiveFileName);
        } catch (IOException e) {
            e.printStackTrace();
            activityContext.showToast(activityContext.getString(R.string.preview_error_toast));
        }
    }

}
