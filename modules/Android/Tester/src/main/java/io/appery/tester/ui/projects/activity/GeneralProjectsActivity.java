package io.appery.tester.ui.projects.activity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Toast;

import butterknife.Bind;
import butterknife.OnClick;
import io.appery.tester.Constants;
import io.appery.tester.R;
import io.appery.tester.db.entity.SortType;
import io.appery.tester.ui.base.activity.BaseActivity;
import io.appery.tester.ui.projects.callback.MasterCallback;
import io.appery.tester.ui.projects.callback.SlaveCallback;
import io.appery.tester.utils.DialogHelper;
import io.appery.tester.utils.PermissionsUtil;

/**
 * Created by Alexandr.Salin on 12/6/15.
 */
public class GeneralProjectsActivity extends BaseActivity implements MasterCallback, PermissionsUtil.PermissionRequestHandler {

    private static final String TAG = "GeneralProjectsActivity";

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
        PermissionsUtil.askTesterHasAllNeededPermissions(this);
    }

    @OnClick(R.id.toolbar_enter_code)
    public void onEnterCodeClick() {
        DialogHelper.buildProjectByCodeDialog(this);
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
                slave.updateSortList(SortType.BY_NAME);
                break;
            case R.id.menu_sort_by_modify_date:
                slave.updateSortList(SortType.BY_MODIFY_DATE);
                break;
            case R.id.menu_sort_by_create_date:
                slave.updateSortList(SortType.BY_CREATION_DATE);
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

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (!PermissionsUtil.checkTesterHasAllNeededPermissions(this)) {
            Toast.makeText(this, R.string.toast_permissions_denied, Toast.LENGTH_LONG).show();
            finish();
        }
    }

    @Override
    public Activity getTargetActivity() {
        return this;
    }

    @Override
    public int getRequestCode() {
        return Constants.RequestCode.PPERMISSION_REQUEST_CODE;
    }
}
