package io.appery.tester.net.api;

/**
 * @author Daniel Lukashevich
 */
public class BaseResponse {

    private boolean hasError = false;
    private String msMessage = "";

    public BaseResponse(boolean failed) {
        hasError = failed;
    }

    public void setMessage(String sMessage) {
        msMessage = sMessage;
    }

    public String getMessage() {
        return msMessage;
    }

    public boolean hasError() {
        return hasError;
    }

}
