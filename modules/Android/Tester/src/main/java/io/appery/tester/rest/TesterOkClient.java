package io.appery.tester.rest;

import com.squareup.okhttp.OkHttpClient;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.net.CookieHandler;
import java.security.cert.CertificateException;
import java.util.concurrent.TimeUnit;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import retrofit.client.OkClient;
import retrofit.client.Request;
import retrofit.client.Response;

/**
 * Created by Alexandr.Salin on 11/29/15.
 */
public class TesterOkClient extends OkClient {

    private static final Logger logger = LoggerFactory.getLogger(TesterOkClient.class);

    public TesterOkClient(OkHttpClient client) {
        super(client);
    }

    static public TesterOkClient getTesterOkClient() {
        OkHttpClient okHttpClient = new OkHttpClient();
        try {
            // Create a trust manager that does not validate certificate chains
            final TrustManager[] trustAllCerts = new TrustManager[] {
                    new X509TrustManager() {
                        @Override
                        public void checkClientTrusted(java.security.cert.X509Certificate[] chain, String authType) throws CertificateException {
                        }

                        @Override
                        public void checkServerTrusted(java.security.cert.X509Certificate[] chain, String authType) throws CertificateException {
                        }

                        @Override
                        public java.security.cert.X509Certificate[] getAcceptedIssuers() {
                            return null;
                        }
                    }
            };

            // Install the all-trusting trust manager
            final SSLContext sslContext = SSLContext.getInstance("SSL");
            sslContext.init(null, trustAllCerts, new java.security.SecureRandom());
            // Create an ssl socket factory with our all-trusting manager
            final SSLSocketFactory sslSocketFactory = sslContext.getSocketFactory();


            okHttpClient.setSslSocketFactory(sslSocketFactory);
            okHttpClient.setHostnameVerifier(new HostnameVerifier() {
                @Override
                public boolean verify(String hostname, SSLSession session) {
                    return true;
                }
            });


        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        okHttpClient.setReadTimeout(60, TimeUnit.SECONDS);
        okHttpClient.setConnectTimeout(60, TimeUnit.SECONDS);
        okHttpClient.setFollowRedirects(true);
        okHttpClient.setFollowSslRedirects(true);
        TesterCookieStore myCookieManager = new TesterCookieStore();
        CookieHandler.setDefault(myCookieManager);
        return new TesterOkClient(okHttpClient);
    }

    @Override
    public Response execute(Request request) throws IOException {
        Response response = super.execute(request);
        if (response.getStatus() == 200) {
            logger.warn(request.toString());
        }
        return response;
    }

}
