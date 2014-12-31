package io.appery.tester.net.api;

import io.appery.tester.net.RestClient.RequestMethod;
import io.appery.tester.net.RestManager;
import io.appery.tester.net.api.callback.LoginCallback;
import io.appery.tester.utils.Base64;
import io.appery.tester.utils.Constants;
import io.appery.tester.utils.IOUtils;

import java.io.IOException;
import java.io.InputStream;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;

import android.util.Log;

/**
 * This class provides functionality for Login API <BR/>
 * It used HTTP Base Authentification <BR/>
 * 
 * @author Daniel Lukashevich
 */
public class Login extends BaseRequest {

    private static final String TAG = "Login";

    private LoginCallback callback;

    private String login = "";

    private String password = "";

    private String loginTarget = "";

    public Login(RestManager restManager, String login, String password, String loginTarget, LoginCallback callback) {
        super(restManager, Constants.API.LOGIN);

        this.login = login;
        this.password = password;
        this.loginTarget = loginTarget;
        this.callback = callback;
    }

    @Override
    HttpResponse doRequest() throws ClientProtocolException, IOException, Exception {
        getRestClient().addParam("cn", login);
        getRestClient().addParam("pwd", password);
        getRestClient().addParam("target", loginTarget);

        return getRestClient().execute(RequestMethod.GET);
    }

    @Override
    public void onRequestReceived(BaseResponse response) {
        if (response.hasError()) {
            callback.onLoginFailed(response.getMessage());
        } else {
            callback.onLoginSuccess(response.getMessage());
        }
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

    @Override
    public void execute() {
        new Thread(new LoginRequestExecutor()).start();
    }

    /**
     * Request executor // Non UI Thread
     */
    private class LoginRequestExecutor implements Runnable {

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
                if (responseCode == 500) {
                    String message = "Incorrect email address or password";
                    notifyCallback(true, message);
                    return;
                } else if (responseCode != 302){
                    String message = httpResponse.getStatusLine().getReasonPhrase();
                    notifyCallback(true, message);
                    return;
                }

                // Getting location header
                HttpEntity entity = httpResponse.getEntity();


                if (entity != null) {

                    InputStream instream = entity.getContent();
                    String response = IOUtils.convertStreamToString(instream);

                    notifyCallback(false, httpResponse.getFirstHeader("location").getValue());

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
