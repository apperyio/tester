package io.appery.tester.rest;

import io.appery.tester.utils.Constants;
import retrofit.client.Response;
import retrofit.http.GET;
import retrofit.http.Query;

/**
 * Created by Alexandr.Salin on 11/28/15.
 */
public interface IWebApi {

    @GET("/doLogin")
    Response doLogin(@Query(Constants.PARAMS.USERNAME_PARAM) String username, @Query(Constants.PARAMS.PASSWORD_PARAM) String password, @Query(Constants.PARAMS.TARGET_PARAM) String target);
}
