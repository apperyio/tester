package io.appery.tester.tasks.callback;

import java.io.File;

/**
 * @author Daniel Lukashevich
 */
public interface DownloadFileCallback {

    public void onFileDownloaded(File file);

}
