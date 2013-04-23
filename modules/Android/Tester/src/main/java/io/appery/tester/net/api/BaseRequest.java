package io.appery.tester.net.api;

import io.appery.tester.net.RestClient;
import io.appery.tester.net.RestManager;
import io.appery.tester.net.api.callback.RequestCallback;
import io.appery.tester.utils.IOUtils;

import java.io.IOException;
import java.io.InputStream;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;

import android.util.Log;

/**
 * @author Daniel Lukashevich
 */
public abstract class BaseRequest implements RequestCallback {

    private RestClient restClient;

    public BaseRequest(RestManager restManager, String url) {
        Log.d(getTag(), "Create");
        this.restClient = restManager.getRestClient(url);
    }

    /**
     * restClient Specific API request functionality
     * 
     * @return - HttpResponse to handle all returned codes, errors, success result
     * @throws ClientProtocolException
     * @throws IOException
     */
    /* package */abstract HttpResponse doRequest() throws ClientProtocolException, IOException, Exception;

    /**
     * Execute API.
     */
    public void execute() {
        new Thread(new RequestExecutor()).start();
    }

    /**
     * Request executor // Non UI Thread
     */
    private class RequestExecutor implements Runnable {

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
                if (!((responseCode >= 200) && (responseCode <= 400))) {
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
                Log.e(getTag(), e.getMessage(), e);
                notifyCallback(true, e.getMessage());
            } catch (IOException e) {
                Log.e(getTag(), e.getMessage(), e);
                notifyCallback(true, "Unable to connect");
            } catch (Exception e) {
                Log.e(getTag(), e.getMessage(), e);
                notifyCallback(true, "Unknown error");
            }

        }
    }

    /**
     * Notify Callback
     * 
     * @param failed
     *            <code>true</code> if request failed
     * @param response
     */
    private void notifyCallback(final boolean failed, final String response) {
        BaseResponse baseResponse = new BaseResponse(failed);
        baseResponse.setMessage(response);

        onRequestReceived(baseResponse);

        Log.d(getTag(), "Response: " + response);
    }

    /**
     * @return the restClient
     */
    public RestClient getRestClient() {
        return restClient;
    }

    /**
     * @return the tag
     */
    protected abstract String getTag();

    /*
     * (non-Javadoc)
     * 
     * @see io.appery.tester.net.api.callback.RequestCallback#onRequestReceived(io.appery.tester.net.api.BaseResponse)
     */
    @Override
    public void onRequestReceived(BaseResponse response) {
        Log.d(getTag(), response.getMessage());
    }

}
