package io.appery.tester.rest.request;

import io.appery.tester.data.Project;
import io.appery.tester.rest.IWebApi;

/**
 * Created by Alexandr.Salin on 12/3/15.
 */
public class GetProjectsRequest extends BaseRequest<Project.ProjectsList, IWebApi> {
    public GetProjectsRequest() {
        super(Project.ProjectsList.class, IWebApi.class);
    }

    @Override
    Project.ProjectsList loadData() {
        return getService().doGetProjects();
    }
}
