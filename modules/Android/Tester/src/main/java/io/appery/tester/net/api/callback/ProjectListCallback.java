package io.appery.tester.net.api.callback;

import io.appery.tester.db.entity.Project;
import io.appery.tester.net.api.BaseResponse;

import java.util.List;

/**
 * @author Daniel Lukashevich
 */
public interface ProjectListCallback {

    public void onProjectListReceived(List<Project> projects, BaseResponse response);

}
