package io.appery.tester.utils;

import android.content.Context;
import android.util.Log;

import java.io.Closeable;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

/**
 * Use this class to work with files, directories and zip files.<BR/>
 * 
 * @author Daniel Lukashevich
 */
public class FileUtils {
	
	private final static String TAG = "FileUtils";

    /**
     * This method allow to unzip file from <code>zipPath</code> to <code>destPath</code>
     * 
     * @param zipFile
     * @param destDir
     * @throws IOException
     */
    public static final void unzip(File zipFile, File destDir) throws IOException {
        // source zip file
        FileInputStream fis = new FileInputStream(zipFile);
        ZipInputStream zis = new ZipInputStream(fis);

        ZipEntry zipEntry = null; // single zip entry

        while ((zipEntry = zis.getNextEntry()) != null) {
            String name = zipEntry.getName();
            if (zipEntry.isDirectory()) {
                prepareDirectory(new File(destDir, name));
            } else {
                File fileOut = new File(destDir, name);
                prepareDirectory(fileOut.getParentFile());
                FileOutputStream fout = new FileOutputStream(fileOut);
                byte[] buffer = new byte[1024];
                int len1 = 0;
                while ((len1 = zis.read(buffer)) != -1) {
                    fout.write(buffer, 0, len1);
                }

                zis.closeEntry();
                closeStream(fout);
            }
        }
        closeStream(zis);
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
     * This function helps to create folder in <code>dirPath</code>
     *
     * @param dir
     */
    public static void prepareDirectory(File dir) {
        if (!dir.exists()) {
            dir.mkdirs();
        }
    }

    /**
     * Clear directory.
     *
     * @throws IOException
     */
    public static void clearDirectory(File dir) throws IOException {
            if (!dir.isDirectory()) {
                return;
            }
            for (File file : dir.listFiles()) {
                if (file.isDirectory()) {
                    clearDirectory(file.getAbsoluteFile());
                } else {
                    file.delete();
                }
            }
            dir.delete();
    }

    /**
     * Copy asset to file.
     * 
     * @param assetName
     * @param destFile
     * @throws IOException
     */
    public static void copyAsset(Context ctx, String assetName, File destFile) {
        try {
            InputStream in = ctx.getAssets().open(assetName);
            OutputStream out = new FileOutputStream(destFile);

            byte[] buf = new byte[1024];
            int len;
            while ((len = in.read(buf)) > 0) {
                out.write(buf, 0, len);
            }
            in.close();
            out.close();
            Log.d(TAG,"File copied.");
        } catch (FileNotFoundException ex) {
        	Log.e(TAG,ex.getMessage() + " in the specified directory.");
            System.exit(0);
        } catch (IOException e) {
            Log.e(TAG, "Can't copy asset: " + assetName, e);
        }
    }
    
    public static final void removeFile(File file){
    	if(file.exists()){
    		if(!file.delete()){
    			Log.e(TAG,"Can't delete file  "+file);
    		}else{
    			Log.d(TAG,"File  "+file+" was deleted successfully");
    		}
    	} else {
    		Log.e(TAG,"File "+file+" doesn't exist");
    	}
    	
    }

}
