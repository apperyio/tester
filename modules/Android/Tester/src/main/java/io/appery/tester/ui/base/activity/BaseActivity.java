package io.appery.tester.ui.base.activity;

import android.content.Intent;
import android.view.MenuItem;

import io.appery.tester.R;
import io.appery.tester.RestManager;
import io.appery.tester.ui.login.activity.AuthActivity;

/**
 * @author Daniel Lukashevich
 */
public abstract class BaseActivity extends SpiceActivity {

    public void startActivity(Class<?> _class) {
        Intent intent = new Intent(this, _class);
        startActivity(intent);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {

        switch (item.getItemId()) {
            case R.id.menu_logout:
                logout();
                startActivity(AuthActivity.class);
                return true;

            default:
                break;
        }

        return super.onOptionsItemSelected(item);
    }

    /**
     * Logout.
     */
    protected void logout() {
        RestManager.doLogout(this, this);
    }

}
