package io.appery.tester.rest;

import retrofit.client.Response;
import retrofit.http.GET;

/**
 * Created by Alexandr.Salin on 11/28/15.
 */
public interface IWebApi {

    @GET("/app/rest/user/login")
    Response doLogin();
}
