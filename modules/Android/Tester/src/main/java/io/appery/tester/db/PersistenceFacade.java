package io.appery.tester.db;

import com.j256.ormlite.android.apptools.OpenHelperManager;
import com.j256.ormlite.table.TableUtils;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.SQLException;

import io.appery.tester.TesterApplication;
import io.appery.tester.utils.ThreadUtil;

/**
 * Use this instance only from background thread
 * Created by Alexandr.Salin on 12/10/15.
 */
public class PersistenceFacade {
    private static final Logger logger = LoggerFactory.getLogger(PersistenceFacade.class);
    private static PersistenceFacade instance;
    private static DatabaseHelper helper;

    public static synchronized PersistenceFacade getInstance() {
        if (instance == null) {
            instance = new PersistenceFacade();
        }
        return instance;
    }

    protected DatabaseHelper getHelper() {
        ThreadUtil.checkAndThrowIfUIThread();
        if (helper == null) {
            synchronized (this) {
                if (helper == null) {
                    helper = OpenHelperManager.getHelper(TesterApplication.getInstance(), DatabaseHelper.class);
                }
            }
        }
        return helper;
    }

    public <T> void cleanTable(Class<T> clazz) throws SQLException {
        TableUtils.dropTable(getHelper().getConnectionSource(), clazz, true);
        TableUtils.createTable(getHelper().getConnectionSource(), clazz);
    }
}