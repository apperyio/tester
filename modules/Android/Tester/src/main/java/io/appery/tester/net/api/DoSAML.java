package io.appery.tester.net.api;

import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;

import java.io.IOException;

import io.appery.tester.net.RestClient;
import io.appery.tester.net.RestManager;
import io.appery.tester.net.api.callback.DoSAMLCallback;

public class DoSAML extends BaseRequest {
    private static final String TAG = "DoSAML";

    private DoSAMLCallback mCallback;

    private String SAMLValue;

    public DoSAML(RestManager restManager, DoSAMLCallback callback, String SAMLValue) {
        super(restManager, null);

        this.mCallback = callback;
        this.SAMLValue = SAMLValue;
    }

    @Override
    HttpResponse doRequest() throws ClientProtocolException, IOException, Exception {
        getRestClient().addParam("SAMLResponse", SAMLValue);
        return getRestClient().execute(RestClient.RequestMethod.POST);
    }

    @Override
    public void onRequestReceived(BaseResponse response) {
        mCallback.onDoSAMLComplete(response);
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
}
