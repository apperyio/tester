package io.appery.tester;

import io.appery.tester.net.RestManager;
import io.appery.tester.net.api.Logout;
import io.appery.tester.utils.Constants;
import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Toast;

/**
 * @author Daniel Lukashevich
 */
public abstract class BaseActivity extends Activity {

    // Toasts
    public void showToast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_LONG).show();
    }

    public void showToast(int id) {
        String message = getString(id);
        showToast(message);
    }

    // Dialogs

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

    protected void startActivity(Class<?> _class) {
        Intent intent = new Intent(this, _class);
        startActivity(intent);
    }

    // Menu

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.main_menu, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {

        switch (item.getItemId()) {
        case R.id.menu_logout:
            logout();
            startActivity(LoginActivity.class);
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

    public void setPreference(String key, String value) {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
        if (prefs != null) {
            try {
                Editor editor = prefs.edit();
                editor.putString(key, value);
                editor.commit();
            } catch (Exception e) {
                Log.e(BaseActivity.class.getName(), "Set preference error");
            }
        }
    }

    public String getBaseURL() {
        return ((TesterApplication) getApplication()).getRestManager().getBaseURL();
    }

    public RestManager getRestManager() {
        RestManager manager = ((TesterApplication) getApplication()).getRestManager();
        return manager;
    }

    /**
     * Logout.
     */
    protected void logout() {
        Logout logout = new Logout(getRestManager());
        logout.execute();
    }

}
