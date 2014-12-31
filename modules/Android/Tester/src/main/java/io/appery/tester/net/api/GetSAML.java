package io.appery.tester.net.api;

import android.util.Log;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;

import java.io.IOException;
import java.io.InputStream;

import io.appery.tester.net.RestClient;
import io.appery.tester.net.RestManager;
import io.appery.tester.net.api.callback.GetSAMLCallback;
import io.appery.tester.utils.IOUtils;

public class GetSAML extends BaseRequest {
    private static final String TAG = "DoSAML";

    private GetSAMLCallback mCallback;

    public GetSAML(RestManager restManager, GetSAMLCallback callback) {
        super(restManager, null);

        this.mCallback = callback;
    }

    @Override
    HttpResponse doRequest() throws ClientProtocolException, IOException, Exception {
        return getRestClient().execute(RestClient.RequestMethod.GET);
    }

    @Override
    public void onRequestReceived(BaseResponse response) {
        mCallback.onGetSAMLComplete(response);
    }

    /*
     * (non-Javadoc)
     *
     * @see io.appery.tester.net.api.BaseRequest#getTag()
     */
    @Override
    protected String getTag() {
        return TAG;
    }

    /**
     * Execute API.
     */
    public void execute() {
        new Thread(new GetSAMLRequestExecutor()).start();
    }

    /**
     * Request executor // Non UI Thread
     */
    private class GetSAMLRequestExecutor implements Runnable {

        @Override
        public void run() {

            try {
                // Call request
                HttpResponse httpResponse = doRequest();
                if (httpResponse == null) {
                    notifyCallback(true, "Wrong Http Request");
                    return;
                }

                // Handle response code
                int responseCode = httpResponse.getStatusLine().getStatusCode();
                if (!((responseCode >= 200) && (responseCode <= 400) || (responseCode == 404))) {
                    String message = httpResponse.getStatusLine().getReasonPhrase();
                    notifyCallback(true, message);
                    return;
                }

                // Getting response entity
                HttpEntity entity = httpResponse.getEntity();
                if (entity != null) {

                    InputStream instream = entity.getContent();
                    String response = IOUtils.convertStreamToString(instream);

                    notifyCallback(false, response);

                    instream.close();
                } else {
                    notifyCallback(false, null);
                }

            } catch (ClientProtocolException e) {
                Log.e(getTag(), "Can't execute request", e);
                notifyCallback(true, e.getMessage());
            } catch (IOException e) {
                Log.e(getTag(), "Can't execute request", e);
                notifyCallback(true, "Unable to connect");
            } catch (Exception e) {
                Log.e(getTag(), "Can't execute request", e);
                notifyCallback(true, "Unknown error");
            }
        }
    }
}
