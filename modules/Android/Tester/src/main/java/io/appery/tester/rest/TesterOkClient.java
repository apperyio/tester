package io.appery.tester.rest;

import com.squareup.okhttp.OkHttpClient;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;

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

    public TesterOkClient() {
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
