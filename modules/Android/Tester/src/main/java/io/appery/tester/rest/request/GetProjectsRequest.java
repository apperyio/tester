package io.appery.tester.rest.request;

import io.appery.tester.db.PersistenceFacade;
import io.appery.tester.db.entity.Project;
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
        cleanProjects();
        ProjectsCollection result = new ProjectsCollection();
        for (Project project : getService().doGetProjects()) {
            if (!project.isDisabled()) {
                result.add(project);
            }
        }
        return result;
    }

    private void cleanProjects() {
        try {
            PersistenceFacade.getInstance().cleanTable(Project.class);
            PersistenceFacade.getInstance().cleanTable(ProjectsCollection.class);
        } catch (Exception ignore) {
        }
    }
}
