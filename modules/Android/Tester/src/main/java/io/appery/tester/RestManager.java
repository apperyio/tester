package io.appery.tester;

import android.content.Context;
import android.net.Uri;

import com.octo.android.robospice.persistence.DurationInMillis;
import com.octo.android.robospice.request.listener.RequestListener;

import java.io.InputStream;

import io.appery.tester.db.entity.Project;
import io.appery.tester.db.entity.ProjectsCollection;
import io.appery.tester.db.entity.User;
import io.appery.tester.rest.SpiceHolder;
import io.appery.tester.rest.TesterSpiceEndpoint;
import io.appery.tester.rest.listener.BaseListener;
import io.appery.tester.rest.request.GetProjectsRequest;
import io.appery.tester.rest.request.LoginRequest;
import io.appery.tester.rest.request.LogoutRequest;
import io.appery.tester.rest.request.ProjectFileRequest;
import io.appery.tester.rest.request.SamlRequest;
import io.appery.tester.utils.DialogHelper;
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
        if (!UserHelper.hasSAMLKey()) {
            return;
        }
        holder.getSpiceManager().execute(new LogoutRequest(), new BaseListener<Response>());
    }

    public static void samlRequest(SpiceHolder holder, String samlValue, RequestListener<Response> listener) {
        UserHelper.updateSAMLKey(samlValue);
        holder.getSpiceManager().execute(new SamlRequest(samlValue), listener);
    }

    public static void getProjectsListImmidiatly(SpiceHolder holder, RequestListener<ProjectsCollection> listener) {
        holder.getSpiceManager().execute(new GetProjectsRequest(), Project.class.getSimpleName(), DurationInMillis.ALWAYS_EXPIRED, listener);
    }

    public static void getProjectFile(Context context, String url) {
        SpiceHolder holder = (SpiceHolder) context;
        String cUrl = TesterSpiceEndpoint.getBaseIdpUrl() + url;
        ProjectFileRequest request = new ProjectFileRequest(context, DialogHelper.buildDownloadProjectDialog(context), cUrl);
        holder.getSpiceManager().removeDataFromCache(InputStream.class);
        holder.getSpiceManager().execute(request, "PROJECT_FILE_ZIP", DurationInMillis.ALWAYS_EXPIRED, request);
    }

    public static void getProjectFileByCode(Context context, String code) {
        SpiceHolder holder = (SpiceHolder) context;
        String cUrl = TesterSpiceEndpoint.getBaseIdpUrl() + String.format(Constants.API.GET_PROJECT_RESOURCE_BY_CODE, Uri.encode(code));
        ProjectFileRequest request = new ProjectFileRequest(context, DialogHelper.buildDownloadProjectDialog(context), cUrl);
        holder.getSpiceManager().removeDataFromCache(InputStream.class);
        holder.getSpiceManager().execute(request, "PROJECT_FILE_ZIP", DurationInMillis.ALWAYS_EXPIRED, request);
    }
}
