package io.appery.tester;

import com.octo.android.robospice.persistence.DurationInMillis;
import com.octo.android.robospice.request.listener.RequestListener;

import io.appery.tester.db.entity.Project;
import io.appery.tester.db.entity.ProjectsCollection;
import io.appery.tester.db.entity.User;
import io.appery.tester.rest.SpiceHolder;
import io.appery.tester.rest.request.GetProjectsRequest;
import io.appery.tester.rest.request.LoginRequest;
import io.appery.tester.rest.request.SamlRequest;
import io.appery.tester.utils.UserHelper;
import retrofit.client.Response;

/**
 * Created by Alexandr.Salin on 11/28/15.
 */
public class RestManager {

    public static void doLogin(SpiceHolder holder, User user, RequestListener<Response> listener) {
        UserHelper.saveUser(user);
        holder.getSpiceManager().execute(new LoginRequest(), listener);
    }

    public static void doLogout(SpiceHolder holder) {
        //holder.getSpiceManager().execute(new LogoutRequest(), new BaseListener<Response>());
    }

    public static void samlRequest(SpiceHolder holder, String url, String samlValue, RequestListener<Response> listener) {
        UserHelper.updateSAMLKey(samlValue);
        holder.getSpiceManager().execute(new SamlRequest(url, samlValue), listener);
    }

    public static void getProjectsListImmidiatly(SpiceHolder holder, RequestListener<ProjectsCollection> listener) {
        holder.getSpiceManager().execute(new GetProjectsRequest(), Project.class.getSimpleName(), DurationInMillis.ALWAYS_EXPIRED, listener);
    }


}
