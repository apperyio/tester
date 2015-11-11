package io.appery.tester.net;

import java.io.Serializable;
import java.security.KeyStore;

import org.apache.http.client.CookieStore;
import org.apache.http.client.HttpClient;
import org.apache.http.client.protocol.ClientContext;
import org.apache.http.conn.ClientConnectionManager;
import org.apache.http.conn.scheme.PlainSocketFactory;
import org.apache.http.conn.scheme.Scheme;
import org.apache.http.conn.scheme.SchemeRegistry;
import org.apache.http.conn.ssl.SSLSocketFactory;
import org.apache.http.impl.client.BasicCookieStore;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.impl.conn.tsccm.ThreadSafeClientConnManager;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.apache.http.protocol.BasicHttpContext;
import org.apache.http.protocol.HttpContext;

import android.os.Build;

public class RestManager {

    private String baseURL = "http://gamma.dev.appery.io/";

    private String idpURL;

    private String baseURLConstant;

    // Cookie store
    private CookieStore cookieStore;

    // Create local HTTP context
    private HttpContext httpContext;

    public HttpClient httpClient;

    /**
     * Create new instance.
     */
    public RestManager(String baseURL) {
        this.baseURL = baseURL;
        this.baseURLConstant = baseURL;
        this.idpURL = new StringBuilder(baseURL).insert("https://".length(), "idp.").toString();

        cookieStore = new BasicCookieStore();
        httpContext = new BasicHttpContext();
        httpContext.setAttribute(ClientContext.COOKIE_STORE, cookieStore);

        HttpParams httpParameters = new BasicHttpParams();
        // Set the timeout in milliseconds until a connection is established.
        int timeoutConnection = 120000;
        HttpConnectionParams.setConnectionTimeout(httpParameters, timeoutConnection);

        // Set the default socket timeout (SO_TIMEOUT)
        // in milliseconds which is the timeout for waiting for data.
        int timeoutSocket = 120000;
        HttpConnectionParams.setSoTimeout(httpParameters, timeoutSocket);

        if (Build.VERSION.SDK_INT <= 8) {
            try {
                KeyStore trustStore = KeyStore.getInstance(KeyStore.getDefaultType());
                trustStore.load(null, null);

                SSLSocketFactory sf = new CustomSSLSocketFactory(trustStore);
                sf.setHostnameVerifier(SSLSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER);

                SchemeRegistry registry = new SchemeRegistry();
                registry.register(new Scheme("http", PlainSocketFactory.getSocketFactory(), 80));
                registry.register(new Scheme("https", sf, 443));

                ClientConnectionManager ccm = new ThreadSafeClientConnManager(httpParameters, registry);

                httpClient = new DefaultHttpClient(ccm, httpParameters);
            } catch (Exception e) {
                httpClient = new DefaultHttpClient(httpParameters);
            }
        } else {
            httpClient = new DefaultHttpClient(httpParameters);
        }
    }

    public void setBaseURL(String baseURL) {
        this.baseURL = baseURL;
    }

    public BasicCookieStore getCookieStore() {
        return (BasicCookieStore)cookieStore;
    }

    /**
     * @return the baseURL
     */
    public String getBaseURL() {
        return baseURL;
    }

    public RestClient getRestClient(String url) {
        StringBuilder sbUrl = new StringBuilder(baseURL);
        if (url != null) {
            if (url.startsWith("/")) {
                sbUrl.append(url);
            } else {
                sbUrl = new StringBuilder(url);
            }
        }
        return new RestClient(httpClient, httpContext, sbUrl.toString());
    }

    public String getBaseURLConstant() {
        return baseURLConstant;
    }

    public String getIdpURL() {
        return idpURL;
    }
}
