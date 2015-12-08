package io.appery.tester.rest.request;

import io.appery.tester.db.entity.ProjectsCollection;
import io.appery.tester.rest.IWebApi;

/**
 * Created by Alexandr.Salin on 12/3/15.
 */
public class GetProjectsRequest extends BaseRequest<ProjectsCollection, IWebApi> {
    public GetProjectsRequest() {
        super(ProjectsCollection.class, IWebApi.class);
    }

    @Override
    ProjectsCollection loadData() {
        return getService().doGetProjects();
    }
}
