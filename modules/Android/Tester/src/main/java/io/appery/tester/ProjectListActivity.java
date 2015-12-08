package io.appery.tester;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;

import com.octo.android.robospice.persistence.exception.SpiceException;
import com.octo.android.robospice.request.listener.RequestListener;

import org.apache.http.cookie.Cookie;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import io.appery.tester.db.entity.Project;
import io.appery.tester.db.entity.ProjectsCollection;
import io.appery.tester.net.api.BaseResponse;
import io.appery.tester.net.api.callback.ProjectListCallback;
import io.appery.tester.preview.ProjectPreviewManager;
import io.appery.tester.ui.base.activity.BaseActivity;
import io.appery.tester.ui.projects.adapter.ProjectListAdapter;
import io.appery.tester.utils.CommonUtil;
import io.appery.tester.utils.Constants;
import io.appery.tester.utils.comparators.ProjectComparator;

/**
 * @author Daniel Lukashevich
 */
public class ProjectListActivity extends BaseActivity implements ProjectListCallback, RequestListener<ProjectsCollection> {

    // UI
    private ListView mProjectListView;

    // Data
    private List<Project> projectList = new ArrayList<Project>();
    private Project selectedProject;
    private int sortBy = ProjectComparator.BY_EDIT_DATE;


    private String[] PROJECTS_ACTIONS;

    private String RUN_PROJECT_ACTION;

    public static final String ALL_FOLDERS = "ALL";

    public static final String MY_FOLDER = "My folder";

    public static final int ALL_FOLDERS_POSITION = 0;

    public static final int MY_FOLDER_POSITION = 1;

    private ProjectListAdapter mProjectAdapter;

    //FolderAdapter mFolderAdapter;

    List<String> mFolders = new ArrayList<String>();

    private static List<String> savedCookiesName = Arrays.asList(new String[]{"JSESSIONID", "APPSSO"});

    private static List<Cookie> savedCookieList = new ArrayList<Cookie>();

    private static final String UNAUTHORIZED_RESPONSE_MESSAGE = "Unauthorized";

    private ProjectPreviewManager projectPreviewManager;

    @Override
    protected int getResId() {
        return R.layout.activity_projects;
    }

    @Override
    protected void afterViews(Bundle savedInstanceState) {
        super.afterViews(savedInstanceState);
        projectPreviewManager = new ProjectPreviewManager(getRestManager(), this);
        if (savedInstanceState != null) {
            sortBy = savedInstanceState.getInt(Constants.EXTRAS.SORT_BY, ProjectComparator.BY_EDIT_DATE);
            projectList = (List<Project>) savedInstanceState.get(Constants.EXTRAS.PROJECTS_LIST);
            selectedProject = (Project) savedInstanceState.get(Constants.EXTRAS.SELECTED_PROJECT);
        }

        mProjectListView = (ListView) findViewById(R.id.project_list);
        mProjectListView.setOnItemClickListener(new OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int pos, long id) {
                selectedProject = (Project) mProjectListView.getItemAtPosition(pos);
                showDialog(Constants.DIALOGS.PROJECT_ACTION);
            }
        });
        mProjectAdapter = new ProjectListAdapter(ProjectListActivity.this, projectList);
        mProjectListView.setAdapter(mProjectAdapter);

        // request for projects
        PreferenceManager.setDefaultValues(this, R.xml.preferences, false);
        ((TesterApplication) getApplication()).setBaseURL(getServerURL());

        //GetProjectList getProjectList = new GetProjectList(getRestManager(), this);
        showDialog(Constants.DIALOGS.PROGRESS);
        //getProjectList.execute();
        //RestManager.getProjectsList(this,this);

        // preparing project actions list
        this.RUN_PROJECT_ACTION = getString(R.string.project_action_run);
        String[] PROJECTS_ACTIONS = {this.RUN_PROJECT_ACTION, //this.DEBUG_PROJECT_ACTION,
                getString(R.string.project_action_cancel)};
        this.PROJECTS_ACTIONS = PROJECTS_ACTIONS;

        // folders
        mFolders.add(ALL_FOLDERS);

        // mFolderAdapter = new FolderAdapter(this, mFolders, getResources().getColor(android.R.color.holo_blue_light));
    }


    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        if (selectedProject != null) {
            //outState.putSerializable(Constants.EXTRAS.SELECTED_PROJECT, selectedProject);
            outState.putSerializable(Constants.EXTRAS.PROJECTS_LIST, (Serializable) projectList);
            outState.putSerializable(Constants.EXTRAS.SORT_BY, sortBy);
        }
    }

    @Override
    public void onProjectListReceived(final List<Project> projects, final BaseResponse response) {
        runOnUiThread(new Runnable() {

            @Override
            public void run() {

                try {
                    removeDialog(Constants.DIALOGS.PROGRESS);
                } catch (Exception e) {
                }

                if (response.hasError() && UNAUTHORIZED_RESPONSE_MESSAGE.equals(response.getMessage())) {
                    finish();
                    return;
                }

                if (response.hasError()) {
                    CommonUtil.showToast(response.getMessage());
                    return;
                }
                projectList = projects;
                updateFolders(projects);
                updateProjectsList(ProjectComparator.BY_EDIT_DATE);
            }
        });

    }

    @Override
    protected Dialog onCreateDialog(int id) {
        switch (id) {
            case Constants.DIALOGS.PROJECT_ACTION:
                AlertDialog.Builder builder = new AlertDialog.Builder(this);
                builder.setItems(PROJECTS_ACTIONS, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int item) {
                        removeDialog(Constants.DIALOGS.PROJECT_ACTION);
                        if (PROJECTS_ACTIONS[item].equals(RUN_PROJECT_ACTION)) {
                            projectPreviewManager.downloadAndStartProjectPreview(selectedProject.getResourcesLink());
                        }
                    }
                });

                return builder.create();
            case Constants.DIALOGS.SORT:
                builder = new AlertDialog.Builder(this);
                builder.setTitle(R.string.sort_order);
                builder.setItems(new CharSequence[]{getString(R.string.sort_by_name),
                                getString(R.string.sort_by_createdate), getString(R.string.sort_by_modifydate)},
                        new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                updateProjectsList(which);
                            }
                        });

                return builder.create();
            default:
                break;
        }
        return super.onCreateDialog(id);
    }


    @Override
    protected void onPrepareDialog(int id, Dialog dialog) {
        /*switch (id) {
            case Constants.DIALOGS.PROJECT_ACTION:
                dialog.setTitle(selectedProject.getName());
                break;
            default:
                break;
        }*/
        super.onPrepareDialog(id, dialog);
    }


    private void updateProjectsList(int orderBy) {
        Comparator<Project> comparator;
        sortBy = orderBy;
        switch (orderBy) {
            case ProjectComparator.BY_NAME:
                comparator = new ProjectComparator(ProjectComparator.BY_NAME, ProjectComparator.ASC);
                break;
            case ProjectComparator.BY_CREATE_DATE:
                comparator = new ProjectComparator(ProjectComparator.BY_CREATE_DATE, ProjectComparator.DESC);
                break;
            default:
                comparator = new ProjectComparator(ProjectComparator.BY_EDIT_DATE, ProjectComparator.DESC);
                break;
        }
        Collections.sort(projectList, comparator);
        mProjectAdapter.setmProjectList(getFilteredProjects());
        mProjectAdapter.notifyDataSetChanged();
    }

    private void updateFolders(List<Project> projects) {
        List<String> owners = new ArrayList<String>();
        String username = getPreferenceAsString(Constants.PREFERENCES.USERNAME, "");
        for (Project pr : projects)
            if (!username.equals(pr.getOwner()) && !owners.contains(pr.getOwner()))
                owners.add(pr.getOwner());
        Collections.sort(owners);
        mFolders.clear();
        mFolders.add(ALL_FOLDERS);
        mFolders.add(MY_FOLDER);
        mFolders.addAll(owners);
        // mFolderAdapter.selected = 0;
        //mFolderAdapter.setFolders(mFolders);
        //mFolderAdapter.notifyDataSetChanged();
    }

    /**
     * get list projects by owner
     * if user select ALL = return all )
     *
     * @return
     */
    private List<Project> getFilteredProjects() {
        /*if (mFolderAdapter.getSelected() == ALL_FOLDERS_POSITION) return projectList;
        String owner;
        if (mFolderAdapter.getSelected() == MY_FOLDER_POSITION)
            owner = getPreferenceAsString(Constants.PREFERENCES.USERNAME, "");
        else
            owner = mFolders.get(mFolderAdapter.getSelected());*/

        List<Project> res = new ArrayList<Project>();
        /*for (Project p : projectList) {
            if (owner.equals(p.getOwner()))
                res.add(p);
        }*/
        return res;
    }

    @Override
    public void onRequestFailure(SpiceException spiceException) {
        try {
            removeDialog(Constants.DIALOGS.PROGRESS);
        } catch (Exception e) {
        }
    }

    @Override
    public void onRequestSuccess(ProjectsCollection projects) {
        try {
            removeDialog(Constants.DIALOGS.PROGRESS);
        } catch (Exception e) {
        }
        projectList = projects;
        updateFolders(projects);
        updateProjectsList(ProjectComparator.BY_EDIT_DATE);
    }
}
