package io.appery.tester.rest;

import retrofit.ErrorHandler;
import retrofit.RetrofitError;

/**
 * Created by Alexandr.Salin on 11/29/15.
 */
public class TesterErrorHandler implements ErrorHandler {
    @Override
    public Throwable handleError(RetrofitError cause) {
        return cause;
    }
}