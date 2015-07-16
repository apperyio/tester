package io.appery.tester;

import io.appery.tester.net.RestManager;
import io.appery.tester.net.api.Logout;
import io.appery.tester.utils.Constants;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.preference.PreferenceManager;
import android.util.Log;
import android.widget.Toast;

import com.actionbarsherlock.app.SherlockActivity;
import com.actionbarsherlock.view.Menu;
import com.actionbarsherlock.view.MenuItem;

/**
 * @author Daniel Lukashevich
 */
public abstract class BaseActivity extends SherlockActivity {

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

    public void startActivity(Class<?> _class) {
        Intent intent = new Intent(this, _class);
        startActivity(intent);
    }

    // Menu

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
      //  getMenuInflater().inflate(R.menu.main_menu, menu);
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
        getRestManager().setBaseURL(getRestManager().getIdpURL());
        Logout logout = new Logout(getRestManager());
        logout.execute();
    }

    protected String getServerURL() {
        String fixVersion = getPreferenceAsString(Constants.PREFERENCES.FIX_VERSION, "-1");
        if (fixVersion.equals("-1") || fixVersion.equals("1")) {
            setPreference(Constants.PREFERENCES.FIX_VERSION, "2");
            String serverURL = getPreferenceAsString(Constants.PREFERENCES.BASE_URL, "");
            if (serverURL.equals(Constants.SERVER_CONSTANTS.OLD_APPERY_URL_HTTPS)
                    || serverURL.equals(Constants.SERVER_CONSTANTS.OLD_APPERY_URL_HTTP)) {
                // updating server url to https://appery.io
                setPreference(Constants.PREFERENCES.BASE_URL, Constants.SERVER_CONSTANTS.NEW_APPERY_URL_HTTPS);
                return Constants.SERVER_CONSTANTS.NEW_APPERY_URL_HTTPS;
            }
        }
        return getPreferenceAsString(Constants.PREFERENCES.BASE_URL, "");

    }

}
