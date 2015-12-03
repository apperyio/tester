package io.appery.tester.rest;

import io.appery.tester.data.Project;
import io.appery.tester.utils.Constants;
import retrofit.client.Response;
import retrofit.http.GET;
import retrofit.http.POST;
import retrofit.http.Path;
import retrofit.http.Query;

/**
 * Created by Alexandr.Salin on 11/28/15.
 */
public interface IWebApi {
    @GET(Constants.API.LOGIN)
    Response doLogin(@Query(Constants.PARAMS.USERNAME_PARAM) String username, @Query(Constants.PARAMS.PASSWORD_PARAM) String password, @Query(Constants.PARAMS.TARGET_PARAM) String target);

    @POST("/{path}")
    Response doSamlRequest(@Path(encode = false, value = "path") String path, @Query(Constants.PARAMS.SAML_RESPONSE_PARAM) String samlValue);

    @GET(Constants.API.GET_PROJECTLIST)
    Project.ProjectsList doGetProjects();

}
