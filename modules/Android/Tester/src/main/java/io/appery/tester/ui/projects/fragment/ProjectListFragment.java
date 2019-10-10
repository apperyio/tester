package io.appery.tester.ui.projects.fragment;

import android.content.Context;
import android.database.Cursor;
import android.os.Bundle;
import android.support.design.widget.Snackbar;
import android.support.v4.app.LoaderManager;
import android.support.v4.content.CursorLoader;
import android.support.v4.content.Loader;
import android.widget.ListView;

import com.afollestad.materialdialogs.MaterialDialog;
import com.octo.android.robospice.persistence.exception.SpiceException;
import com.octo.android.robospice.request.listener.RequestListener;

import butterknife.Bind;
import butterknife.OnItemClick;
import io.appery.tester.Constants;
import io.appery.tester.R;
import io.appery.tester.RestManager;
import io.appery.tester.db.entity.Project;
import io.appery.tester.db.entity.ProjectsCollection;
import io.appery.tester.db.entity.SortType;
import io.appery.tester.ui.base.fragment.BaseFragment;
import io.appery.tester.ui.projects.adapter.ProjectsAdapter;
import io.appery.tester.ui.projects.callback.MasterCallback;
import io.appery.tester.ui.projects.callback.SlaveCallback;
import io.appery.tester.utils.DialogHelper;

/**
 * Created by Alexandr.Salin on 12/6/15.
 */
public class ProjectListFragment extends BaseFragment implements RequestListener<ProjectsCollection>, SlaveCallback, LoaderManager.LoaderCallbacks<Cursor> {
    private MasterCallback master;
    private MaterialDialog dialog;
    private SortType mSortType = SortType.BY_CREATION_DATE;

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
    }

    @OnItemClick(R.id.project_list)
    void onItemSelected(int position) {
        Cursor cursor = (Cursor) list.getItemAtPosition(position);
        String name = cursor.getString(cursor.getColumnIndexOrThrow(Project.NAME_FIELD));
        String guid = cursor.getString(cursor.getColumnIndexOrThrow(Project.GUID_FIELD));
        int type = cursor.getInt(cursor.getColumnIndexOrThrow(Project.TYPE_FIELD));
        String libVersion = cursor.getString(cursor.getColumnIndexOrThrow(Project.LIB_VERSION_FIELD));
        Project project = new Project(name, guid, type, libVersion);
        RestManager.getProjectFile(getContext(), project, project.getResourcesLink());
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
        updateSortList(mSortType);
    }

    @Override
    public void updateSortList(SortType sortType) {
        mSortType = sortType;
        Bundle bundle = new Bundle();
        bundle.putSerializable(Constants.EXTRAS.SORT_BY, sortType);
        getLoaderManager().restartLoader(Constants.Loader.PROJECT_LOADER, bundle, this);
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

    @Override
    public Loader<Cursor> onCreateLoader(int id, Bundle args) {
        SortType sortType = (SortType) args.getSerializable(Constants.EXTRAS.SORT_BY);
        return new CursorLoader(
                getContext(),
                Project.contentUri,
                Project.PROJECT_LIST_FRAGMENT_PROJECTION,
                Project.PROJECT_LIST_FRAGMENT_WHERE,
                null,
                Project.getSortOrder(sortType));
    }

    @Override
    public void onLoadFinished(Loader<Cursor> loader, Cursor data) {
        list.setAdapter(new ProjectsAdapter(getContext(), data, false));
    }

    @Override
    public void onLoaderReset(Loader<Cursor> loader) {

    }
}
