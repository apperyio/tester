package io.appery.tester.utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import android.content.Context;
import android.util.Log;

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
     * @param zipPath
     * @param destPath
     * @throws IOException
     */
    public static final void unzip(String zipPath, String destPath) throws IOException {
        // source zip file
        File zipFile = new File(zipPath);

        FileInputStream fis = new FileInputStream(zipFile);
        ZipInputStream zis = new ZipInputStream(fis);

        ZipEntry zipEntry = null; // single zip entry

        while ((zipEntry = zis.getNextEntry()) != null) {
            String name = zipEntry.getName();
            if (zipEntry.isDirectory()) {
                checkDir(name);
            } else {
                File fileOut = new File(destPath, name);
                checkDir(fileOut.getParent());
                FileOutputStream fout = new FileOutputStream(fileOut);
                byte[] buffer = new byte[1024];
                int len1 = 0;
                while ((len1 = zis.read(buffer)) != -1) {
                    fout.write(buffer, 0, len1);
                }

                zis.closeEntry();
                IOUtils.closeStream(fout);
            }
        }
        IOUtils.closeStream(zis);
    }

    /**
     * This function helps to create folder in <code>dirPath</code>
     * 
     * @param dirPath
     */
    public static void checkDir(String dirPath) {
        File dir = new File(dirPath);

        if (!dir.exists()) {
            dir.mkdirs();
        }
    }

    /**
     * Is exists <code>dirPath</code> in filesystem
     *
     * @param dirPath
     */
    public static boolean isDirExists(String dirPath) {
        File dir = new File(dirPath);
        return dir.exists();
    }

    /**
     * Unzip file from <code>zipFilePath</code> to the current directory
     * 
     * @param zipFilePath
     * @throws IOException
     */
    public static final void extractHere(String zipFilePath) throws IOException {
        File zipFile = new File(zipFilePath);
        String destPath = zipFile.getParent();

        unzip(zipFilePath, destPath);
    }

    /**
     * Clear directory.
     * 
     * @param dir
     * @throws IOException
     */
    public static final void clearDirectory(String dirPath) throws IOException {
        if (dirPath != null) {
            File dir = new File(dirPath);
            if (!dir.isDirectory()) {
                return;
            }
            for (File file : dir.listFiles()) {
                if (file.isDirectory()) {
                    clearDirectory(file.getPath());
                } else {
                    file.delete();
                }
            }
            dir.delete();
        }
    }

    /**
     * Copy asset to file.
     * 
     * @param assetName
     * @param destFileName
     * @throws IOException
     */
    public static final void copyAsset(Context ctx, String assetName, String destFileName) {
        try {
            InputStream in = ctx.getAssets().open(assetName);
            OutputStream out = new FileOutputStream(new File(destFileName));

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
    
    public static final void removeFile(String path){
    	File file = new File(path);
    	if(file.exists()){
    		if(!file.delete()){
    			Log.e(TAG,"Can't delete file  "+path);
    		}else{
    			Log.d(TAG,"File  "+path+" was deleted successfully");
    		}
    	}else{
    		Log.e(TAG,"File "+path+" doesn't exist");
    	}
    	
    }

}
