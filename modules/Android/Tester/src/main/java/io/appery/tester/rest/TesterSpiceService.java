package io.appery.tester.rest;

import com.octo.android.robospice.retrofit.RetrofitGsonSpiceService;
import com.squareup.okhttp.OkHttpClient;

import java.security.cert.CertificateException;
import java.util.concurrent.TimeUnit;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

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
}