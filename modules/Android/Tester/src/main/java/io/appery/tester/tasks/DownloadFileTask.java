package io.appery.tester.tasks;

import io.appery.tester.ui.base.activity.BaseActivity;
import io.appery.tester.tasks.callback.DownloadFileCallback;
import io.appery.tester.utils.Constants;
import io.appery.tester.utils.IOUtils;

import java.io.File;

import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;

/**
 * This is Async Task allows to download file from internet. File Object from requested Url will be received through
 * {@link DownloadFileCallback} interface. <BR/>
 * Note:<BR/>
 * Do NOT reuse this task to avoid memory leaks because it use reference to a Activity context.
 * 
 * @author Daniel Lukashevich
 */
public class DownloadFileTask extends AsyncTask<String, Void, File> {

    private static final String TAG = "DownloadFileTask";

    private BaseActivity mContext;

    private String mFileName;

    private DownloadFileCallback mCallback;

    private DownloadFileErrorCallback errorCallback;

    private Throwable downloadException;

    private boolean isError = false;

    public DownloadFileTask(Context context, String fileName, DownloadFileCallback callback) {
        this.mContext = (BaseActivity) context;
        this.mFileName = fileName;
        this.mCallback = callback;
    }

    public DownloadFileTask(Context context, String fileName, DownloadFileCallback callback,DownloadFileErrorCallback errorCallback) {
        this.mContext = (BaseActivity) context;
        this.mFileName = fileName;
        this.mCallback = callback;
        this.errorCallback = errorCallback;
    }

    public interface DownloadFileErrorCallback{

        public void onFileDownloadError(Throwable exception);

    }

    /**
     * Register callback to get downloaded File
     * 
     * @param callback
     */
    public void registerCallback(DownloadFileCallback callback) {
        this.mCallback = callback;
    }

    @Override
    protected void onPreExecute() {
        mContext.showDialog(Constants.DIALOGS.PROGRESS);
    }

    @Override
    protected File doInBackground(String... params) {
        try {
            File file = IOUtils.downloadFile(mContext, params[0], mFileName);
            return file;
        } catch (Throwable e) {
            Log.e(TAG, "Can't download file", e);
            this.downloadException = e;
            this.isError = true;
        }

        return null;
    }

    @Override
    protected void onPostExecute(File result) {
        mContext.removeDialog(Constants.DIALOGS.PROGRESS);
        if (mCallback != null && !isError){
            mCallback.onFileDownloaded(result);
        }
        if (errorCallback != null && isError){
            Log.d("IOUtils", "DownloadFileTask onFileDownloadError ");
            errorCallback.onFileDownloadError(this.downloadException);
        }
    }

}
