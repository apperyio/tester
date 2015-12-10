package io.appery.tester.ui.projects.fragment;

import android.content.Context;
import android.os.Bundle;
import android.support.design.widget.Snackbar;
import android.widget.ListView;

import com.afollestad.materialdialogs.MaterialDialog;
import com.octo.android.robospice.persistence.exception.SpiceException;
import com.octo.android.robospice.request.listener.RequestListener;

import butterknife.Bind;
import butterknife.OnItemClick;
import io.appery.tester.R;
import io.appery.tester.RestManager;
import io.appery.tester.db.entity.Project;
import io.appery.tester.db.entity.ProjectsCollection;
import io.appery.tester.ui.base.fragment.BaseFragment;
import io.appery.tester.ui.projects.adapter.ProjectListAdapter;
import io.appery.tester.ui.projects.callback.MasterCallback;
import io.appery.tester.ui.projects.callback.SlaveCallback;
import io.appery.tester.utils.CommonUtil;
import io.appery.tester.utils.DialogHelper;

/**
 * Created by Alexandr.Salin on 12/6/15.
 */
public class ProjectListFragment extends BaseFragment implements RequestListener<ProjectsCollection>, SlaveCallback {
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

    @OnItemClick(R.id.project_list)
    void onItemSelected(int position) {
        Project selectedProject = (Project) list.getItemAtPosition(position);
        DialogHelper.buildProjectActionDialog(getContext(), selectedProject);
    }

    @Override
    public void refresh() {
        dialog = DialogHelper.buildDownloadProjectsProgressDialog(getContext());
        RestManager.getProjectsListImmidiatly(this, this);
    }

    @Override
    public void onRequestFailure(SpiceException spiceException) {
        dialog.dismiss();
        Snackbar.make(list, spiceException.getMessage(), Snackbar.LENGTH_LONG).show();
    }

    @Override
    public void onRequestSuccess(ProjectsCollection projects) {
        dialog.dismiss();
        ProjectListAdapter adapter = (ProjectListAdapter) list.getAdapter();
        adapter.setmProjectList(projects);
        adapter.notifyDataSetChanged();
    }

    @Override
    public void updateProjectsList(int sortType) {
        ProjectListAdapter adapter = (ProjectListAdapter) list.getAdapter();
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
