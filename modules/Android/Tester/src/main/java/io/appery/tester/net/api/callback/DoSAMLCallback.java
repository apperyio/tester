package io.appery.tester.net.api.callback;

import io.appery.tester.net.api.BaseResponse;

/**
 * @author Daniel Lukashevich
 */
public interface DoSAMLCallback {

    public void onDoSAMLComplete(BaseResponse response);

}
