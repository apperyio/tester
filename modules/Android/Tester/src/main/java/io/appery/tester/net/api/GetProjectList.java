package io.appery.tester.net.api;

import io.appery.tester.db.entity.Project;
import io.appery.tester.net.RestClient.RequestMethod;
import io.appery.tester.net.RestManager;
import io.appery.tester.net.api.callback.ProjectListCallback;
import io.appery.tester.utils.Constants;
import io.appery.tester.utils.JsonParser;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;

/**
 * This class provides functionality for GetProjectList API <BR/>
 * 
 * @author Daniel Lukashevich
 */
    public class GetProjectList extends BaseRequest {

    protected static final String TAG = "BaseRequest";

    private ProjectListCallback mCallback;

    public GetProjectList(RestManager restManager, ProjectListCallback callback) {
        super(restManager, Constants.API.GET_PROJECTLIST);
        this.mCallback = callback;
    }

    @Override
    HttpResponse doRequest() throws ClientProtocolException, IOException, Exception {
        return getRestClient().execute(RequestMethod.GET);
    }

    @Override
    public void onRequestReceived(BaseResponse response) {
        List<Project> projects = new ArrayList<Project>();

        projects = JsonParser.getProjects(response.getMessage());

        if (mCallback != null) {
            mCallback.onProjectListReceived(projects, response);
        }

    }

    /*
     * (non-Javadoc)
     * 
     * @see io.appery.tester.net.api.BaseRequest#getTag()
     */
    @Override
    protected String getTag() {
        return TAG;
    }

}
