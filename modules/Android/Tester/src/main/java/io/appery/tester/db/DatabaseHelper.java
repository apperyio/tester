package io.appery.tester.db;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;

import com.octo.android.robospice.persistence.ormlite.RoboSpiceDatabaseHelper;

import java.io.File;
import java.io.InputStream;

/**
 * Created by Alexandr.Salin on 12/6/15.
 */
public class DatabaseHelper extends RoboSpiceDatabaseHelper {
    public DatabaseHelper(Context context) {
        super(context, Contract.DATABASE_NAME, Contract.DATABASE_VERSION);
    }

    public DatabaseHelper(Context context, String databaseName, int databaseVersion) {
        super(context, databaseName, databaseVersion);
    }

    public DatabaseHelper(Context context, String databaseName, SQLiteDatabase.CursorFactory factory, int databaseVersion) {
        super(context, databaseName, factory, databaseVersion);
    }

    public DatabaseHelper(Context context, String databaseName, SQLiteDatabase.CursorFactory factory, int databaseVersion, int configFileId) {
        super(context, databaseName, factory, databaseVersion, configFileId);
    }

    public DatabaseHelper(Context context, String databaseName, SQLiteDatabase.CursorFactory factory, int databaseVersion, File configFile) {
        super(context, databaseName, factory, databaseVersion, configFile);
    }

    public DatabaseHelper(Context context, String databaseName, SQLiteDatabase.CursorFactory factory, int databaseVersion, InputStream stream) {
        super(context, databaseName, factory, databaseVersion, stream);
    }
}
