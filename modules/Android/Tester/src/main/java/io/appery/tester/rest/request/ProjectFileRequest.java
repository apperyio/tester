package io.appery.tester.rest.request;

import android.content.Context;
import android.content.Intent;

import com.afollestad.materialdialogs.MaterialDialog;
import com.octo.android.robospice.persistence.exception.SpiceException;
import com.octo.android.robospice.request.ProgressByteProcessor;
import com.octo.android.robospice.request.listener.RequestListener;
import com.octo.android.robospice.request.simple.BinaryRequest;

import org.apache.commons.io.IOUtils;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Map;

import io.appery.tester.ui.appery.ApperyActivity;
import io.appery.tester.R;
import io.appery.tester.TesterApplication;
import io.appery.tester.utils.CommonUtil;
import io.appery.tester.Constants;
import io.appery.tester.utils.FileUtils;
import io.appery.tester.utils.ProjectStorageManager;
import retrofit.RetrofitError;
import roboguice.util.temp.Ln;

/**
 * Created by Alexandr.Salin on 12/10/15.
 */
public class ProjectFileRequest extends BinaryRequest implements RequestListener<InputStream> {

    protected File cacheFile;
    private Context context;
    private MaterialDialog dialog;
    private Map<String, String> CORDOVA_RESOURCES;
    private static final String DEBUG_OFF_SERVICE_PARAM = "debug=false";

    public ProjectFileRequest(Context ctx, MaterialDialog dialog, final String url) {
        super(url + "?" + DEBUG_OFF_SERVICE_PARAM);
        this.dialog = dialog;
        this.cacheFile = new File(ProjectStorageManager.getPROJECT_ZIP_FILE());
        this.context = ctx;
        CORDOVA_RESOURCES = new HashMap<String, String>();
        CORDOVA_RESOURCES.put("cordova_resources.zip", "/files/resources/lib/");
        CORDOVA_RESOURCES.put("cordova_resources_3.0.zip", "/libs/");
    }

    @Override
    public InputStream processStream(final int contentLength, final InputStream inputStream) throws IOException {
        OutputStream fileOutputStream = null;
        try {
            // touch
            boolean isTouchedNow = cacheFile.setLastModified(System.currentTimeMillis());
            if (!isTouchedNow) {
                Ln.d("Modification time of file %s could not be changed normally ", cacheFile.getAbsolutePath());
            }
            fileOutputStream = new FileOutputStream(cacheFile);
            readBytes(inputStream, new ProgressByteProcessor(this, fileOutputStream, contentLength));
            return new FileInputStream(cacheFile);
        } finally {
            IOUtils.closeQuietly(fileOutputStream);
        }
    }

    public File getCacheFile() {
        return cacheFile;
    }

    @Override
    public void onRequestFailure(SpiceException exception) {
        dialog.dismiss();
        Context ctx = TesterApplication.getInstance();
        if (exception != null && exception.getCause() instanceof RetrofitError) {
            RetrofitError error = (RetrofitError) exception.getCause();
            if (error.getResponse() == null) {
                CommonUtil.showMessage(ctx, "Can't execute request");
                return;
            }
            if (error.getResponse().getStatus() == 404) {
                CommonUtil.showMessage(ctx, ctx.getString(R.string.preview_by_code_not_found_error_toast));
                return;
            }
            if (error.getResponse().getStatus() == 403) {
                CommonUtil.showMessage(ctx, ctx.getString(R.string.preview_by_code_expired_error_toast));
                return;
            }
        }
        if (exception != null && exception.getCause() instanceof IOException) {
            CommonUtil.showMessage(ctx, "Unable to connect");
            return;
        }
        CommonUtil.showMessage(ctx, ctx.getString(R.string.application_download_error_toast));
    }

    @Override
    public void onRequestSuccess(InputStream inputStream) {
        String fName = getCacheFile().getName();
        if (Constants.FILENAME_ZIP.equals(fName)) {
            // Unzip
            String dirPath = ProjectStorageManager.getWORK_DIRECTORY();
            try {
                FileUtils.checkDir(dirPath);
                FileUtils.clearDirectory(dirPath);
                FileUtils.unzip(ProjectStorageManager.getPROJECT_ZIP_FILE(), dirPath);
                replaceCordovaResources(dirPath);
                Intent intent = new Intent(context, ApperyActivity.class);
                context.startActivity(intent);
            } catch (IOException e) {
                CommonUtil.showToast(context.getString(R.string.preview_error_toast));
            }
        }
        dialog.dismiss();
    }

    private void replaceCordovaResources(String dirPath) {
        for (String archive : this.CORDOVA_RESOURCES.keySet()) {
            String path = dirPath + this.CORDOVA_RESOURCES.get(archive);
            String cordovaArchiveFullPath = path + archive;

            FileUtils.checkDir(path);
            FileUtils.copyAsset(context, archive, cordovaArchiveFullPath);
            try {
                FileUtils.unzip(cordovaArchiveFullPath, path);
                FileUtils.removeFile(cordovaArchiveFullPath);
            } catch (IOException e) {
                CommonUtil.showToast(context.getString(R.string.preview_error_toast));
            }
        }
    }
}