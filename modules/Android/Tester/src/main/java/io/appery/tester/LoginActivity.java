package io.appery.tester;

import com.actionbarsherlock.view.Menu;
import com.actionbarsherlock.view.MenuItem;

import io.appery.tester.dialogs.EnterAppCodeDialog;
import io.appery.tester.net.api.BaseResponse;
import io.appery.tester.net.api.DoSAML;
import io.appery.tester.net.api.GetSAML;
import io.appery.tester.net.api.Login;
import io.appery.tester.net.api.Logout;
import io.appery.tester.net.api.callback.DoSAMLCallback;
import io.appery.tester.net.api.callback.GetSAMLCallback;
import io.appery.tester.net.api.callback.LoginCallback;
import io.appery.tester.preview.ProjectPreviewManager;
import io.appery.tester.utils.Constants;
import io.appery.tester.utils.WidgetUtils;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;

import android.view.View;
import android.view.Window;
import android.widget.EditText;


public class LoginActivity extends BaseActivity implements LoginCallback, GetSAMLCallback, DoSAMLCallback{

    protected static final int PREFERENCES = 0;

    private String username;

    private String password;

    private AlertDialog.Builder builder;

    private ProjectPreviewManager projectPreviewManager;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if ((getIntent().getFlags() & Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT) != 0) {
            // Activity was brought to front and not created,
            // Thus finishing this will get us to the last viewed activity
            finish();
            return;
        }
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.login);
        bindUI();
        PreferenceManager.setDefaultValues(this, R.xml.preferences, false);
        ((TesterApplication) getApplication()).setBaseURL(getServerURL());
        projectPreviewManager = new ProjectPreviewManager(getRestManager(),this);
    }

    private void bindUI() {
        findViewById(R.id.enter_code_btn).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                openEnterCodeDialog();
            }
        });
    }

    @Override
    protected void onStart() {
        super.onStart();
        username = getPreferenceAsString(Constants.PREFERENCES.USERNAME, "");
        password = getPreferenceAsString(Constants.PREFERENCES.PASSWORD, "");
        WidgetUtils.setText(this, R.id.login_et, username);
        WidgetUtils.setText(this, R.id.password_et, password);
    }

    @Override
    protected void onResume() {
        super.onResume();
        getRestManager().setBaseURL(getRestManager().getIdpURL());
        Logout logout = new Logout(getRestManager());
       	logout.execute();
        int views[] = new int[] { R.id.login_et, R.id.password_et, R.id.sign_in_btn };
        View focusView = null;
        for (int viewId : views) {
            focusView = findViewById(viewId);
            if (focusView instanceof EditText) {
                if (WidgetUtils.isEmpty((EditText) focusView)) {
                    break;
                }
            }
        }
        focusView.setFocusableInTouchMode(true);
        focusView.requestFocusFromTouch();
    }

    @Override
    public void onLoginFailed(final String errorMessage) {
        runOnUiThread(new Runnable() {

            @Override
            public void run() {
                removeDialog(Constants.DIALOGS.SIGN_IN);
                if (errorMessage.toLowerCase().equals("unauthorized")) {
                    showToast(getString(R.string.unautorized_toast));
                } else {
                    showToast(errorMessage);
                }
            }
        });

    }

    @Override
    public void onLoginSuccess(final String location) {
        setPreference(Constants.PREFERENCES.USERNAME, username);
        setPreference(Constants.PREFERENCES.PASSWORD, password);
        runOnUiThread(new Runnable() {

            @Override
            public void run() {
                // showToast(getString(R.string.autorized_toast));
                removeDialog(Constants.DIALOGS.SIGN_IN);
            }
        });
        getRestManager().setBaseURL(location);
        GetSAML samlAPI = new GetSAML(getRestManager(), this);
        samlAPI.execute();
        //GetUserId getUserId = new GetUserId(getRestManager(), this);
        //getUserId.execute();
    }

    @Override
    public void onDoSAMLComplete(final BaseResponse response) {

        runOnUiThread(new Runnable() {

            @Override
            public void run() {

                try {
                    //String message = response.getMessage().trim();
                    //Long userId = Long.parseLong(message);
                    getRestManager().setBaseURL(getRestManager().getBaseURLConstant());
                    Intent intent = new Intent(LoginActivity.this, ProjectListActivity.class);
                    //intent.putExtra(Constants.EXTRAS.USER_ID, userId);
                    intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                    startActivity(intent);
                } catch (NumberFormatException e) {
                    Log.e("onGetUserId", "Invalid format of USER_ID", e);
                }

            }
        });

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        menu.add(0, PREFERENCES, 0, getString(R.string.preferences_mi));
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
        case PREFERENCES: {
            Intent intent = new Intent(LoginActivity.this, PreferencesActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            startActivity(intent);
            return true;
        }
        }
        return false;
    }

    @Override
    protected Dialog onCreateDialog(int id) {
        switch (id) {
        case Constants.DIALOGS.SIGN_IN:
            ProgressDialog progressDialog = new ProgressDialog(this);
            progressDialog.setCancelable(false);
            progressDialog.setMessage(getString(R.string.signing_in));
            return progressDialog;

        default:
            break;
        }
        return super.onCreateDialog(id);
    }

    /**
     * Sign in to Appery.
     * 
     * @param target
     */
    public void signIn(View target) {
        ((TesterApplication) getApplication()).setBaseURL(getPreferenceAsString(Constants.PREFERENCES.BASE_URL, ""));
        username = WidgetUtils.getText(LoginActivity.this, R.id.login_et);
        password = WidgetUtils.getText(LoginActivity.this, R.id.password_et);
        getRestManager().setBaseURL(getRestManager().getIdpURL());
        String loginTarget = getRestManager().getBaseURLConstant() + Constants.API.LOGIN_TARGET;
        Login loginApi = new Login(getRestManager(), username, password, loginTarget, LoginActivity.this);
        showDialog(Constants.DIALOGS.SIGN_IN);
        loginApi.execute();
    }

    public void openEnterCodeDialog() {
        ((TesterApplication) getApplication()).setBaseURL(getPreferenceAsString(Constants.PREFERENCES.BASE_URL, ""));
        EnterAppCodeDialog enterAppCodeDialog = new EnterAppCodeDialog(this,this.projectPreviewManager);
        enterAppCodeDialog.show();
    }

    @Override
    public void onGetSAMLComplete(BaseResponse response) {
        String saml = response.getMessage().substring(response.getMessage().indexOf("VALUE=\"") + 7, response.getMessage().indexOf("\"/>"));
        String url = response.getMessage().substring(response.getMessage().indexOf("ACTION=\"") + 8, response.getMessage().indexOf("\"><I"));
        //TODO do regex
        /*Pattern pattern = Pattern.compile("/value=\"([^\"]+)\"/i");
        Matcher matcher = pattern.matcher(hash);
        if (matcher.find()) {
            saml = matcher.group(1);
        }*/
        getRestManager().setBaseURL(url);
        DoSAML samlAPI = new DoSAML(getRestManager(), this, saml);
        samlAPI.execute();
    }

}