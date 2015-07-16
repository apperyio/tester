package io.appery.tester;

import io.appery.tester.adaptors.FolderAdapter;
import io.appery.tester.adaptors.ProjectListAdapter;
import io.appery.tester.comparators.ProjectComparator;
import io.appery.tester.data.Project;
import io.appery.tester.data.SerializedCookie;
import io.appery.tester.net.api.BaseResponse;
import io.appery.tester.net.api.GetProjectList;
import io.appery.tester.net.api.callback.ProjectListCallback;
import io.appery.tester.preview.ProjectPreviewManager;
import io.appery.tester.utils.Constants;
import java.io.Serializable;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.FrameLayout;
import android.widget.ListView;
import com.actionbarsherlock.app.ActionBar;
import com.actionbarsherlock.view.Menu;
import com.actionbarsherlock.view.MenuItem;
import com.actionbarsherlock.view.SubMenu;
import org.apache.http.cookie.Cookie;
import org.apache.http.impl.cookie.BasicClientCookie;

/**
 * @author Daniel Lukashevich
 */
public class ProjectListActivity extends BaseActivity implements ProjectListCallback{

    // UI
    private ListView mProjectListView;

    // Data
    private List<Project> projectList = new ArrayList<Project>();
    private Project selectedProject;
    private int sortBy = ProjectComparator.BY_EDIT_DATE;

    // User
    private Long userId = 0l;

    private String[] PROJECTS_ACTIONS;

    private String RUN_PROJECT_ACTION;

    public static  final String ALL_FOLDERS = "ALL";

    public static  final String MY_FOLDER = "My folder";

    public static  final int ALL_FOLDERS_POSITION = 0;

    public static  final int MY_FOLDER_POSITION = 1;

    private String CORDOVA_LIB_DIR = "/files/resources/lib/";

    private String CORDOVA_ANGULAR_LIB_DIR = "/libs/";

    private ProjectListAdapter mProjectAdapter;

    FolderAdapter mFolderAdapter;

    List<String> mFolders = new ArrayList<String>();

    private static List<String> savedCookiesName = Arrays.asList(new String[]{"JSESSIONID", "APPSSO"});

    private static List<Cookie> savedCookieList = new ArrayList<Cookie>();

    private static final String UNAUTHORIZED_RESPONSE_MESSAGE = "Unauthorized";

    private ProjectPreviewManager projectPreviewManager;

    @SuppressWarnings("unchecked")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.projects);
        projectPreviewManager = new ProjectPreviewManager(getRestManager(),this);
        if (savedInstanceState != null) {
            sortBy = savedInstanceState.getInt(Constants.EXTRAS.SORT_BY, ProjectComparator.BY_EDIT_DATE);
            projectList = (List<Project>) savedInstanceState.get(Constants.EXTRAS.PROJECTS_LIST);
            selectedProject = (Project) savedInstanceState.get(Constants.EXTRAS.SELECTED_PROJECT);
            for (String cookieName : savedCookiesName){
                if (savedInstanceState.containsKey(cookieName)){
                    SerializedCookie cookie = (SerializedCookie) savedInstanceState.getSerializable(cookieName);
                    BasicClientCookie savedCookie = new BasicClientCookie(cookie.getName(), cookie.getValue());
                    savedCookie.setDomain(cookie.getDomain());
                    savedCookie.setPath(cookie.getPath());
                    savedCookieList.add(savedCookie);
                    Log.d("MY", "saved instance cookie"+ cookieName +" = "+ cookie);
                }
            }
            for (Cookie cookie : savedCookieList) {
                getRestManager().getCookieStore().addCookie(cookie);
            }
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

        userId = getIntent().getLongExtra(Constants.EXTRAS.USER_ID, -1);

        // request for projects
        PreferenceManager.setDefaultValues(this, R.xml.preferences, false);
        ((TesterApplication) getApplication()).setBaseURL(getServerURL());

        GetProjectList getProjectList = new GetProjectList(getRestManager(), this);
        showDialog(Constants.DIALOGS.PROGRESS);
        getProjectList.execute();

        // preparing project actions list
        this.RUN_PROJECT_ACTION = getString(R.string.project_action_run);
        String[] PROJECTS_ACTIONS = { this.RUN_PROJECT_ACTION, //this.DEBUG_PROJECT_ACTION,
                getString(R.string.project_action_cancel) };
        this.PROJECTS_ACTIONS = PROJECTS_ACTIONS;

        // folders
        mFolders.add(ALL_FOLDERS);

        mFolderAdapter  = new FolderAdapter(this, mFolders ,getResources().getColor(android.R.color.holo_blue_light));
        customizeActionBar();
    }


    private static boolean sHackReady;
    private static boolean sHackAvailable;
    private static Field sRecreateDisplayList;
    private static Method sGetDisplayList;

    OnItemClickListener onFolderClick = new OnItemClickListener() {
        @Override
        public void onItemClick(AdapterView<?> adapterView, View view, int i, long id) {
            mFolderAdapter.setSelected(i,view);
            updateProjectsList(sortBy);
            //mSlidingMenu.toggle();
        }
    };
    View.OnClickListener onRefreshClick = new View.OnClickListener() {

        @Override
        public void onClick(View view) {
            GetProjectList getProjectList = new GetProjectList(ProjectListActivity.this.getRestManager(), ProjectListActivity.this);
            showDialog(Constants.DIALOGS.PROGRESS);
            getProjectList.execute();
        }
    } ;

    /***
     * Add indicator  ,  tittle and submenu to actionbar
     */

    private void customizeActionBar(){
        ActionBar bar = getSupportActionBar();
        View title = LayoutInflater.from(this).inflate(R.layout.actionbar_tittle , null , false);
        /*mIndicatorView = (ImageView)title.findViewById(R.id.im_indicator);
        mIndicatorView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                   mSlidingMenu.toggle(true);
            }
        });*/

        FrameLayout.LayoutParams prms = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT, Gravity.CENTER_VERTICAL);

        title.setLayoutParams(prms);
        bar.setCustomView(title);
        bar.setDisplayShowCustomEnabled(true);
    }

    @Override
    protected void onResume() {
        super.onResume();

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
        List<Cookie> cookies = getRestManager().getCookieStore().getCookies();
        for (Cookie cookie : cookies){
            if (savedCookiesName.contains(cookie.getName())) {
                outState.putSerializable(cookie.getName(), new SerializedCookie(cookie));
            }
        }
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
                    removeDialog(Constants.DIALOGS.PROGRESS);
                } catch (Exception e) {
                }

                if (response.hasError() && UNAUTHORIZED_RESPONSE_MESSAGE.equals(response.getMessage())) {
                    finish();
                    return;
                }

                if (response.hasError()) {
                    showToast(response.getMessage());

                    //finish();
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
            builder.setItems(new CharSequence[] { getString(R.string.sort_by_name),
                    getString(R.string.sort_by_createdate ) , getString(R.string.sort_by_modifydate) },
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
    public boolean onCreateOptionsMenu(Menu menu) {

        SubMenu subMenu = menu.addSubMenu(getString(R.string.sort_mi));
        subMenu.add(0, Constants.MENU_OPTIONS.REFRESH, Menu.NONE, R.string.refresh_mi);
        //subMenu.add(0, Constants.MENU_OPTIONS.SELECT_FOLDER,Menu.NONE, R.string.folders);
        subMenu.add(0, Constants.MENU_OPTIONS.SORT_BY_NAME, Menu.NONE, R.string.sort_by_name);
        subMenu.add(0, Constants.MENU_OPTIONS.SORT_BY_CREATE,Menu.NONE, R.string.sort_by_createdate);
        subMenu.add(0, Constants.MENU_OPTIONS.SORT_BY_EDIT,Menu.NONE, R.string.sort_by_modifydate);
        subMenu.add(0, Constants.MENU_OPTIONS.LOGOUT,Menu.NONE, R.string.logout_mi);

        MenuItem subMenu1Item = subMenu.getItem();
        subMenu1Item.setIcon(R.drawable.abs__ic_menu_moreoverflow_normal_holo_light);
        subMenu1Item.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS );
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
        case Constants.MENU_OPTIONS.SORT_BY_NAME:
            updateProjectsList(ProjectComparator.BY_NAME);
            break;
        case Constants.MENU_OPTIONS.SORT_BY_EDIT:
            updateProjectsList(ProjectComparator.BY_EDIT_DATE);
            break;
        case Constants.MENU_OPTIONS.SORT_BY_CREATE:
            updateProjectsList(ProjectComparator.BY_CREATE_DATE);
            break;
        case Constants.MENU_OPTIONS.LOGOUT :
             // for action logout we simply go on login activity
             // in login activity onresume there is action to perform logout
            finish();
            break;

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
    }

    private void updateProjectsList(int orderBy) {
        Comparator<Project> comparator;
        sortBy = orderBy;
        switch (orderBy){
            case  ProjectComparator.BY_NAME :
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

    private void updateFolders(List<Project> projects){
        List<String> owners = new ArrayList<String>();
        String  username = getPreferenceAsString(Constants.PREFERENCES.USERNAME, "");
        for(Project pr : projects)
            if (!username.equals(pr.getOwner())&& !owners.contains(pr.getOwner()))
                owners.add(pr.getOwner());
        Collections.sort(owners);
        mFolders.clear();
        mFolders.add(ALL_FOLDERS);
        mFolders.add(MY_FOLDER);
        mFolders.addAll(owners);
        mFolderAdapter.selected=0;
        mFolderAdapter.setFolders(mFolders);
        mFolderAdapter.notifyDataSetChanged();
    }

    /**
     * get list projects by owner
     * if user select ALL = return all )
     * @return
     */
    private List<Project> getFilteredProjects(){
        if (mFolderAdapter.getSelected()==ALL_FOLDERS_POSITION) return projectList;
        String owner ;
        if (mFolderAdapter.getSelected()==MY_FOLDER_POSITION)
            owner = getPreferenceAsString(Constants.PREFERENCES.USERNAME,"");
        else
            owner = mFolders.get(mFolderAdapter.getSelected());

        List<Project> res = new ArrayList<Project>();
        for(Project p:projectList){
            if(owner.equals(p.getOwner()))
                res.add(p);
        }
        return res;
    }
}
