package io.appery.tester.ui.projects.fragment;

import android.content.Context;
import android.os.Bundle;
import android.widget.ListView;

import com.afollestad.materialdialogs.MaterialDialog;
import com.octo.android.robospice.persistence.exception.SpiceException;
import com.octo.android.robospice.request.listener.RequestListener;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

import butterknife.Bind;
import io.appery.tester.R;
import io.appery.tester.RestManager;
import io.appery.tester.db.entity.Project;
import io.appery.tester.ui.base.fragment.BaseFragment;
import io.appery.tester.ui.projects.adapter.ProjectListAdapter;
import io.appery.tester.ui.projects.callback.MasterCallback;
import io.appery.tester.ui.projects.callback.SlaveCallback;
import io.appery.tester.utils.CommonUtil;
import io.appery.tester.utils.DialogHelper;
import io.appery.tester.utils.comparators.ProjectComparator;

/**
 * Created by Alexandr.Salin on 12/6/15.
 */
public class ProjectListFragment extends BaseFragment implements RequestListener<Project.ProjectsList> , SlaveCallback{
    private MasterCallback master;
    private MaterialDialog dialog;

    @Bind(R.id.project_list)
    ListView list;

    @Override
    protected int getResId() {
        return R.layout.fragment_projects;
    }

    @Override
    protected void afterViews(Bundle savedInstanceState) {
        super.afterViews(savedInstanceState);
        refresh();
        list.setAdapter(new ProjectListAdapter(getContext(), CommonUtil.<Project>getNewArrayList()));
    }

    @Override
    public void refresh() {
        dialog = DialogHelper.buildAuthProgressDialog(getContext());
        RestManager.getProjectsList(this,this);
    }

    @Override
    public void onRequestFailure(SpiceException spiceException) {
        dialog.dismiss();
    }

    @Override
    public void onRequestSuccess(Project.ProjectsList projects) {
        dialog.dismiss();
        ProjectListAdapter adapter = (ProjectListAdapter) list.getAdapter();
        adapter.setmProjectList(projects);
        adapter.notifyDataSetChanged();
    }

    @Override
    public void updateProjectsList(int sortType) {
/*        Comparator<Project> comparator;
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
        Collections.sort(projectList, comparator);*/
        ProjectListAdapter adapter = (ProjectListAdapter) list.getAdapter();
        //adapter.setmProjectList(getFilteredProjects());
        adapter.notifyDataSetChanged();
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        master = (MasterCallback) context;
        master.onRegister(this);
    }

    @Override
    public void onDetach() {
        super.onDetach();
        master.unRegister();
        master = null;
    }
}
