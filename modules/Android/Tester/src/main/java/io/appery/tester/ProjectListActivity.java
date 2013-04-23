package io.appery.tester;

import io.appery.tester.adaptors.ProjectListAdapter;
import io.appery.tester.comparators.ProjectComparator;
import io.appery.tester.data.Project;
import io.appery.tester.net.api.BaseResponse;
import io.appery.tester.net.api.GetProjectList;
import io.appery.tester.net.api.callback.ProjectListCallback;
import io.appery.tester.tasks.DownloadFileTask;
import io.appery.tester.tasks.callback.DownloadFileCallback;
import io.appery.tester.utils.Constants;
import io.appery.tester.utils.FileUtils;
import io.appery.tester.utils.IntentUtils;
import io.appery.tester.utils.LogReader;
import io.appery.tester.utils.ProjectStorageManager;

import java.io.File;
import java.io.IOException;
import java.io.Serializable;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import org.jivesoftware.smack.XMPPException;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import android.widget.Toast;

/**
 * @author Daniel Lukashevich
 */
public class ProjectListActivity extends BaseActivity implements ProjectListCallback, DownloadFileCallback {

    private static final int SORT_BY_NAME = 0;

    private static final int SORT_BY_DATE = 1;

    // UI
    private ListView mProjectListView;

    // Data
    private List<Project> projectList;
    private Project selectedProject;
    private int sortBy = SORT_BY_NAME;

    // User
    private Long userId = 0l;

    // Log
    private LogReader logReader = null;

    private String[] PROJECTS_ACTIONS;

    private String DEBUG_PROJECT_ACTION;

    private String DEBUG_ON_SERVICE_PARAM = "debug=true";

    private String DEBUG_OFF_SERVICE_PARAM = "debug=false";

    private String RUN_PROJECT_ACTION;

    @SuppressWarnings("unchecked")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        
        setContentView(R.layout.projects);

        if (savedInstanceState != null) {
            sortBy = savedInstanceState.getInt(Constants.EXTRAS.SORT_BY, SORT_BY_DATE);
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

        userId = getIntent().getLongExtra(Constants.EXTRAS.USER_ID, -1);

        // preparing project actions list
        this.DEBUG_PROJECT_ACTION = getString(R.string.project_action_debug);
        this.RUN_PROJECT_ACTION = getString(R.string.project_action_run);
        String[] PROJECTS_ACTIONS = { this.RUN_PROJECT_ACTION, //this.DEBUG_PROJECT_ACTION,
                getString(R.string.project_action_cancel) };
        this.PROJECTS_ACTIONS = PROJECTS_ACTIONS;
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (projectList == null) {
            GetProjectList getProjectList = new GetProjectList(getRestManager(), this);
            showDialog(Constants.DIALOGS.PROGRESS);
            getProjectList.execute();
        }
    }

    @Override
    protected void onStop() {
        super.onStop();
        /*
         * selectedProject = null; projectList = null;
         */
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        if (selectedProject != null) {
            outState.putSerializable(Constants.EXTRAS.SELECTED_PROJECT, selectedProject);
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
                    dismissDialog(Constants.DIALOGS.PROGRESS);
                } catch (Exception e) {
                }

                if (response.hasError()) {
                    showToast(response.getMessage());
                    finish();
                    return;
                }

                projectList = projects;

                updateProjectsList(SORT_BY_DATE);
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
                    // Debug mode
                    removeDialog(Constants.DIALOGS.PROJECT_ACTION);
                    if (PROJECTS_ACTIONS[item].equals(DEBUG_PROJECT_ACTION)) {
                        if (logReader == null) {
                            Log.e("MobileTester", "***Creating new LogReader***");
                            logReader = new LogReader();
                            try {
                                // clear old log
                                Runtime.getRuntime().exec(LogReader.LOGCAT_CLEAR_CMD);
                                logReader.setXMPPConnection(
                                        getPreferenceAsString(Constants.PREFERENCES.XMPP_SERVER, ""),
                                        Integer.parseInt(getPreferenceAsString(Constants.PREFERENCES.XMPP_PORT, "0")),
                                        userId, selectedProject.getId(),
                                        getPreferenceAsString(Constants.PREFERENCES.USERNAME, "User"));

                                logReader.start();

                            } catch (NumberFormatException e) {

                                Log.e("MobileTester", e.getMessage());

                            } catch (XMPPException e) {

                                Log.e("MobileTester", "Error setXMPPConnection" + e.getMessage());

                            } catch (IOException e) {
                                Log.e("MobileTester", "IOException" + e.getMessage());
                            }

                        }
                        try {
                            if (logReader.getSender().isJoined()) {
                                logReader.getSender().leaveRoom();
                            }
                            logReader.getSender().joinToRoom(selectedProject.getId());

                        } catch (XMPPException e) {

                            Log.e("MobileTester", e.getMessage());
                        }
                        DownloadFileTask getApkTask = new DownloadFileTask(ProjectListActivity.this,
                                Constants.FILENAME_ZIP, ProjectListActivity.this);
                        getApkTask.execute(selectedProject.getResourcesLink() + "?" + DEBUG_ON_SERVICE_PARAM);
                    }
                    // Run without debug
                    if (PROJECTS_ACTIONS[item].equals(RUN_PROJECT_ACTION)) {
                        if (logReader != null) {
                            logReader.stopCollect();
                        }
                        DownloadFileTask getApkTask = new DownloadFileTask(ProjectListActivity.this,
                                Constants.FILENAME_ZIP, ProjectListActivity.this);
                        getApkTask.execute(selectedProject.getResourcesLink() + "?" + DEBUG_OFF_SERVICE_PARAM);
                    }

                }
            });
            return builder.create();
        case Constants.DIALOGS.SORT:
            builder = new AlertDialog.Builder(this);
            builder.setTitle(R.string.sort_order);
            builder.setItems(new CharSequence[] { getString(R.string.sort_by_name), getString(R.string.sort_by_date) },
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
        switch (id) {
        case Constants.DIALOGS.PROJECT_ACTION:
            dialog.setTitle(selectedProject.getName());
            break;
        default:
            break;
        }
        super.onPrepareDialog(id, dialog);
    }

    @Override
    public void onFileDownloaded(File file) {

        if (file == null) {
            Toast.makeText(this, getString(R.string.file_download_error_toast), Toast.LENGTH_LONG).show();
            return;
        }

        // TODO - Check filename and do what you need
        // apk file - install
        String fName = file.getName();
        if (Constants.FILENAME_APK.equals(fName)) {
            boolean install = new IntentUtils(this).installApk(file);
            if (!install) {
                showToast(getString(R.string.application_download_error_toast));
            }
        } else if (Constants.FILENAME_ZIP.equals(fName)) {
            // Unzip
            String dirPath = ProjectStorageManager.getWORK_DIRECTORY();

            try {
                FileUtils.checkDir(dirPath);
                FileUtils.clearDirectory(dirPath);

                FileUtils.unzip(ProjectStorageManager.getPROJECT_ZIP_FILE(), dirPath);
                startActivity(ApperyActivity.class);
            } catch (IOException e) {
                e.printStackTrace();
                showToast(getString(R.string.preview_error_toast));
            }
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuItem item = menu.add(Menu.NONE, Constants.MENU_OPTIONS.REFRESH, Menu.NONE, getString(R.string.refresh_mi));
        item.setIcon(R.drawable.refresh);

        item = menu.add(Menu.NONE, Constants.MENU_OPTIONS.SORT, Menu.NONE, getString(R.string.sort_mi));
        item.setIcon(android.R.drawable.ic_menu_sort_alphabetically);

        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
        case Constants.MENU_OPTIONS.REFRESH:
            GetProjectList getProjectList = new GetProjectList(getRestManager(), this);
            showDialog(Constants.DIALOGS.PROGRESS);
            getProjectList.execute();
            return true;
        case Constants.MENU_OPTIONS.SORT:
            showDialog(Constants.DIALOGS.SORT);
            return true;
        default:
            break;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        // The activity is about to be destroyed.
        Log.e("ProjectListActivity", "***onDestroy***");
        if (logReader != null) {
            logReader.stopCollect();
        }
    }

    private void updateProjectsList(int orderBy) {
        Comparator<Project> comparator;
        sortBy = orderBy;
        if (orderBy == SORT_BY_NAME) {
            comparator = new ProjectComparator(ProjectComparator.BY_NAME, ProjectComparator.ASC);
        } else {
            comparator = new ProjectComparator(ProjectComparator.BY_DATE, ProjectComparator.DESC);
        }
        Collections.sort(projectList, comparator);
        mProjectListView.setAdapter(new ProjectListAdapter(ProjectListActivity.this, projectList));
    }

}
