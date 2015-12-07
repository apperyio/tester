package io.appery.tester.ui.base.activity;

import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.MenuItem;

import io.appery.tester.R;
import io.appery.tester.TesterApplication;
import io.appery.tester.net.RestManager;
import io.appery.tester.ui.login.activity.AuthActivity;
import io.appery.tester.utils.Constants;

/**
 * @author Daniel Lukashevich
 */
public abstract class BaseActivity extends SpiceActivity {

    @Override
    protected Dialog onCreateDialog(int id) {
        switch (id) {
            case Constants.DIALOGS.PROGRESS:
                ProgressDialog progressDialog = new ProgressDialog(this);
                progressDialog.setCancelable(false);
                progressDialog.setMessage(getString(R.string.please_wait));

                return progressDialog;

            default:
                break;
        }
        return super.onCreateDialog(id);
    }


    @Override
    protected void onPrepareDialog(int id, Dialog dialog) {
        super.onPrepareDialog(id, dialog);
    }

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

    public String getPreferenceAsString(String key, String defValue) {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
        if (prefs != null) {
            return prefs.getString(key, defValue);
        }
        return null;
    }

    public RestManager getRestManager() {
        return TesterApplication.getInstance().getRestManager();
    }

    /**
     * Logout.
     */
    protected void logout() {
        io.appery.tester.RestManager.doLogout(this);
    }

    protected String getServerURL() {
        return getString(R.string.base_url);
    }

}
