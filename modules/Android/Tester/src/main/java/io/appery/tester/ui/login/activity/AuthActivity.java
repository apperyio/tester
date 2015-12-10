package io.appery.tester.ui.login.activity;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;

import butterknife.Bind;
import io.appery.tester.ui.preferences.PreferencesActivity;
import io.appery.tester.R;
import io.appery.tester.ui.base.activity.BaseActivity;
import io.appery.tester.Constants;

/**
 * Created by Alexandr.Salin on 11/28/15.
 */
public class AuthActivity extends BaseActivity {

    @Bind(R.id.toolbar_home)
    protected Toolbar toolbar;

    @Override
    protected int getResId() {
        return R.layout.activity_auth;
    }

    @Override
    protected void afterViews(Bundle savedInstanceState) {
        super.afterViews(savedInstanceState);
        setSupportActionBar(toolbar);
        toolbar.setTitle(Constants.EMPTY_STRING);
        getSupportActionBar().setTitle(null);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.mn_login, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.menu_preferences: {
                Intent intent = new Intent(this, PreferencesActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                startActivity(intent);
                return true;
            }
        }
        return false;
    }
}
