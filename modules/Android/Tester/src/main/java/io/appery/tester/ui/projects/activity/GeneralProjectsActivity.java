package io.appery.tester.ui.projects.activity;

import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;

import butterknife.Bind;
import io.appery.tester.R;
import io.appery.tester.utils.comparators.ProjectComparator;
import io.appery.tester.ui.base.activity.BaseActivity;
import io.appery.tester.ui.projects.callback.MasterCallback;
import io.appery.tester.ui.projects.callback.SlaveCallback;

/**
 * Created by Alexandr.Salin on 12/6/15.
 */
public class GeneralProjectsActivity extends BaseActivity implements MasterCallback {
    private SlaveCallback slave;

    @Bind(R.id.toolbar_home)
    protected Toolbar toolbar;

    @Override
    protected int getResId() {
        return R.layout.activity_projects;
    }

    @Override
    protected void afterViews(Bundle savedInstanceState) {
        super.afterViews(savedInstanceState);
        setSupportActionBar(toolbar);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.mn_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (slave == null) {
            return false;
        }
        switch (item.getItemId()) {
            case R.id.menu_refresh:
                slave.refresh();
                return true;
            case R.id.menu_sort_by_name:
                slave.updateProjectsList(ProjectComparator.BY_NAME);
                break;
            case R.id.menu_sort_by_modify_date:
                slave.updateProjectsList(ProjectComparator.BY_EDIT_DATE);
                break;
            case R.id.menu_sort_by_create_date:
                slave.updateProjectsList(ProjectComparator.BY_CREATE_DATE);
                break;
            case R.id.menu_logout:
                finish();
                break;
            default:
                super.onOptionsItemSelected(item);
                break;
        }
        return true;
    }

    @Override
    public void onRegister(SlaveCallback slave) {
        this.slave = slave;
    }

    @Override
    public void unRegister() {
        slave = null;
    }
}
