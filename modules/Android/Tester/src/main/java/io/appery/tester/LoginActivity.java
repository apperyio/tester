package io.appery.tester;

import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;

import butterknife.Bind;
import butterknife.OnClick;
import io.appery.tester.ui.base.activity.BaseActivity;
import io.appery.tester.ui.dialogs.EnterAppCodeDialog;
import io.appery.tester.net.api.BaseResponse;
import io.appery.tester.net.api.DoSAML;
import io.appery.tester.net.api.GetSAML;
import io.appery.tester.net.api.Login;
import io.appery.tester.net.api.Logout;
import io.appery.tester.net.api.callback.DoSAMLCallback;
import io.appery.tester.net.api.callback.GetSAMLCallback;
import io.appery.tester.net.api.callback.LoginCallback;
import io.appery.tester.preview.ProjectPreviewManager;
import io.appery.tester.utils.CommonUtil;
import io.appery.tester.utils.Constants;
import io.appery.tester.utils.WidgetUtils;


public class LoginActivity extends BaseActivity implements LoginCallback, GetSAMLCallback, DoSAMLCallback {

    private String username;

    private String password;
    private ProjectPreviewManager projectPreviewManager;

    @Override
    protected int getResId() {
        return R.layout.ac_auth;
    }

    @Override
    protected void afterViews(Bundle savedInstanceState) {
        super.afterViews(savedInstanceState);
        if ((getIntent().getFlags() & Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT) != 0) {
            // Activity was brought to front and not created,
            // Thus finishing this will get us to the last viewed activity
            finish();
            return;
        }

        PreferenceManager.setDefaultValues(this, R.xml.preferences, false);
        ((TesterApplication) getApplication()).setBaseURL(getServerURL());
        projectPreviewManager = new ProjectPreviewManager(getRestManager(), this);

    }

    @Override
    protected void onResume() {
        super.onResume();
        getRestManager().setBaseURL(getRestManager().getIdpURL());
        Logout logout = new Logout(getRestManager());
        logout.execute();
        int views[] = new int[]{R.id.login_et, R.id.password_et, R.id.sign_in_btn};
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
                    CommonUtil.showToast(getString(R.string.unautorized_toast));
                } else {
                    CommonUtil.showToast(errorMessage);
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
                removeDialog(Constants.DIALOGS.SIGN_IN);
            }
        });
        getRestManager().setBaseURL(location);
        GetSAML samlAPI = new GetSAML(getRestManager(), this);
        samlAPI.execute();
    }

    @Override
    public void onDoSAMLComplete(final BaseResponse response) {
        runOnUiThread(new Runnable() {

            @Override
            public void run() {
                try {
                    getRestManager().setBaseURL(getRestManager().getBaseURLConstant());
                    Intent intent = new Intent(LoginActivity.this, ProjectListActivity.class);
                    intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                    startActivity(intent);
                } catch (NumberFormatException e) {
                    Log.e("onGetUserId", "Invalid format of USER_ID", e);
                }
            }
        });
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



    @Override
    public void onGetSAMLComplete(BaseResponse response) {
        String saml = response.getMessage().substring(response.getMessage().indexOf("VALUE=\"") + 7, response.getMessage().indexOf("\"/>"));
        String url = response.getMessage().substring(response.getMessage().indexOf("ACTION=\"") + 8, response.getMessage().indexOf("\"><I"));
        getRestManager().setBaseURL(url);
        DoSAML samlAPI = new DoSAML(getRestManager(), this, saml);
        samlAPI.execute();
    }

}