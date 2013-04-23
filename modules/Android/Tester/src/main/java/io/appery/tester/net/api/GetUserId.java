package io.appery.tester.net.api;

import io.appery.tester.net.RestClient.RequestMethod;
import io.appery.tester.net.RestManager;
import io.appery.tester.net.api.callback.UserIdCallback;
import io.appery.tester.utils.Constants;

import java.io.IOException;

import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;

/**
 * 
 */
public class GetUserId extends BaseRequest {

    private static final String TAG = "GetUserId";

    private UserIdCallback mCallback;

    public GetUserId(RestManager restManager, UserIdCallback callback) {
        super(restManager, Constants.API.GET_USER_ID);

        this.mCallback = callback;
    }

    @Override
    HttpResponse doRequest() throws ClientProtocolException, IOException, Exception {
        return getRestClient().execute(RequestMethod.GET);
    }

    @Override
    public void onRequestReceived(BaseResponse response) {
        mCallback.onGetUserId(response);
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
