package io.appery.tester.rest.listener;

import com.octo.android.robospice.persistence.exception.SpiceException;
import com.octo.android.robospice.request.listener.RequestListener;

/**
 * Created by Alexandr.Salin on 11/30/15.
 */
public class BaseListener<RESULT> implements RequestListener<RESULT> {

    @Override
    public void onRequestFailure(SpiceException spiceException) {

    }

    @Override
    public void onRequestSuccess(RESULT result) {

    }
}
