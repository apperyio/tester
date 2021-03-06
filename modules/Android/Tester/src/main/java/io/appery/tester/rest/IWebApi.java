package io.appery.tester.rest;

import io.appery.tester.Constants;
import io.appery.tester.db.entity.ProjectsCollection;
import retrofit.client.Response;
import retrofit.http.Field;
import retrofit.http.FormUrlEncoded;
import retrofit.http.GET;
import retrofit.http.POST;
import retrofit.http.Query;

/**
 * Created by Alexandr.Salin on 11/28/15.
 */
public interface IWebApi {
    @GET(Constants.API.LOGIN)
    Response doLogin(@Query(Constants.PARAMS.USERNAME_PARAM) String username, @Query(Constants.PARAMS.PASSWORD_PARAM) String password, @Query(Constants.PARAMS.TARGET_PARAM) String target);

    @FormUrlEncoded
    @POST(Constants.API.SAML_ENDPOINT)
    Response doSamlRequest(@Field(Constants.PARAMS.SAML_RESPONSE_PARAM) String samlValue);

    @GET(Constants.API.GET_PROJECTLIST)
    ProjectsCollection doGetProjects();

    @GET(Constants.API.LOGOUT)
    Response doLogout();

}
