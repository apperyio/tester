package io.appery.tester.utils;

import io.appery.tester.BaseActivity;
import io.appery.tester.net.RestClient;

import java.io.BufferedReader;
import java.io.Closeable;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import android.content.Context;

/**
 * @author Daniel Lukashevich
 */
public class IOUtils {

    /**
     * Utilite method to convert input stream to string
     * 
     * @param is
     *            - input stream to convert
     * @return String value of data from <code>is</code>
     */
    public static String convertStreamToString(InputStream is) {

        BufferedReader reader = new BufferedReader(new InputStreamReader(is));
        StringBuilder sb = new StringBuilder();

        String line = null;
        try {
            while ((line = reader.readLine()) != null) {
                sb.append(line + "\n");
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            closeStream(is);
        }
        return sb.toString();
    }

    /**
     * Utilite method to close stream
     * 
     * @param stream
     *            <code>stream</code> to close
     */
    public static final void closeStream(Closeable stream) {
        if (stream != null)
            try {
                stream.close();
                stream = null;
            } catch (IOException e) {
                e.printStackTrace();
            }
    }

    /**
     * Download file from internet. I will be stored in internal storage.
     * 
     * @param ctx
     *            - application context
     * @param sUrl
     *            - url to file
     * @param fileName
     *            - <code>String</code> value of filename
     * @return downloaded <code>File</code> object
     * @throws Exception
     * @throws IllegalStateException
     */
    public static final File downloadFile(final BaseActivity ctx, String sUrl, String fileName)
            throws IllegalStateException, Exception {

        String filePath = ProjectStorageManager.getBase_DIR() + "/files";
        FileUtils.checkDir(filePath);
        File file = new File(filePath, fileName);
        if (!file.exists()) {
            file.createNewFile();
        }

        FileOutputStream fos = new FileOutputStream(new File(filePath, fileName), false);

        InputStream is = getInputStream(ctx.getRestManager().getRestClient(sUrl));

        byte[] buffer = new byte[1024];
        int len1 = 0;
        while ((len1 = is.read(buffer)) != -1) {
            fos.write(buffer, 0, len1);
        }
        fos.flush();

        IOUtils.closeStream(fos);
        IOUtils.closeStream(is);

        if (file.exists()) {
            return file;
        }

        return null;
    }

    void downloadFileToDir(final Context ctx, String sUrl, String dirName) {

    }

    public static InputStream getInputStream(RestClient restClient) throws IllegalStateException, Exception {
        restClient.setFollowRedirects(true);
        return restClient.execute().getEntity().getContent();
    }

}
