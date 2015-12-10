package io.appery.tester.rest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.net.CookieHandler;
import java.net.CookieManager;

import retrofit.client.OkClient;
import retrofit.client.Request;
import retrofit.client.Response;

/**
 * Created by Alexandr.Salin on 11/29/15.
 */
public class TesterOkClient extends OkClient {
    private static final Logger logger = LoggerFactory.getLogger(TesterOkClient.class);
    static CookieManager cookieManager = new CookieManager();

    public TesterOkClient() {
    }

    static public TesterOkClient getTesterOkClient() {
        logger.warn("COOKIES");
        CookieHandler.setDefault(cookieManager);
        return new TesterOkClient();
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
