package io.appery.tester.rest;

import android.app.Application;

import com.nostra13.universalimageloader.utils.StorageUtils;
import com.octo.android.robospice.persistence.CacheManager;
import com.octo.android.robospice.persistence.binary.InFileInputStreamObjectPersister;
import com.octo.android.robospice.persistence.exception.CacheCreationException;
import com.octo.android.robospice.persistence.file.InFileObjectPersister;
import com.octo.android.robospice.persistence.ormlite.InDatabaseObjectPersisterFactory;
import com.octo.android.robospice.persistence.ormlite.RoboSpiceDatabaseHelper;
import com.octo.android.robospice.retrofit.RetrofitGsonSpiceService;

import java.util.ArrayList;
import java.util.List;

import io.appery.tester.db.Contract;
import io.appery.tester.db.entity.Project;
import io.appery.tester.db.entity.ProjectsCollection;
import retrofit.RestAdapter;

/**
 * Created by Alexandr.Salin on 11/29/15.
 */
public class TesterSpiceService extends RetrofitGsonSpiceService {

    private static final int NETWORK_MAX_THREADS = 1;

    @Override
    public void onCreate() {
        super.onCreate();
        addRetrofitInterface(IWebApi.class);
    }

    @Override
    protected String getServerUrl() {
        throw new UnsupportedOperationException("Use Endpoint instead");
    }

    @Override
    public int getMaximumThreadCount() {
        return NETWORK_MAX_THREADS;
    }

    /**
     * setup Retrofit adapter
     * also in this case we setup custom request interceptor for add specific headers,
     * setup OkHttpClient for make all internet request asynchronous
     * setup handler for handle all internet errors
     *
     * @return
     */
    @Override
    protected RestAdapter.Builder createRestAdapterBuilder() {

        RestAdapter.Builder builder = new RestAdapter.Builder();
        builder.setRequestInterceptor(new TesterRequestInterceptor());
        builder.setConverter(new TesterGsonConverter());
        builder.setEndpoint(new TesterSpiceEndpoint());
        builder.setClient(TesterOkClient.getTesterOkClient());
        builder.setLogLevel(RestAdapter.LogLevel.FULL);
        builder.setErrorHandler(new TesterErrorHandler());
        return builder;
    }

    @Override
    public CacheManager createCacheManager(Application application) throws CacheCreationException {
        CacheManager cacheManager = new CacheManager();
        RoboSpiceDatabaseHelper databaseHelper = new RoboSpiceDatabaseHelper(application, Contract.DATABASE_NAME, Contract.DATABASE_VERSION);
        InFileInputStreamObjectPersister inFilePersister = new InFileInputStreamObjectPersister(application, StorageUtils.getCacheDirectory(application));
        InDatabaseObjectPersisterFactory inDatabaseObjectPersisterFactory = new InDatabaseObjectPersisterFactory(application, databaseHelper, Contract.getUris());
        cacheManager.addPersister(inDatabaseObjectPersisterFactory);
        cacheManager.addPersister(inFilePersister);
        return cacheManager;
    }
}