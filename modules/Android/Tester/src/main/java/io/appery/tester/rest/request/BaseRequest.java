package io.appery.tester.rest.request;

import com.octo.android.robospice.request.retrofit.RetrofitSpiceRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Created by Alexandr.Salin on 11/29/15.
 */
public abstract class BaseRequest<T, R> extends RetrofitSpiceRequest<T, R> {
    private static final Logger logger = LoggerFactory.getLogger(BaseRequest.class);

    public BaseRequest(Class<T> clazz, Class<R> retrofitedInterfaceClass) {
        super(clazz, retrofitedInterfaceClass);
        //setRetryPolicy(new DefaultRetryPolicy(1, DefaultRetryPolicy.DEFAULT_DELAY_BEFORE_RETRY, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));
    }

    @Override
    public T loadDataFromNetwork() throws Exception {
        return loadData();
    }

    abstract T loadData();
}