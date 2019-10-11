package io.appery.tester.ui.login.fragment;

import android.content.Intent;
import android.support.design.widget.Snackbar;
import android.util.Log;
import android.widget.EditText;

import com.afollestad.materialdialogs.MaterialDialog;

import butterknife.Bind;
import butterknife.OnClick;
import io.appery.tester.Constants;
import io.appery.tester.R;
import io.appery.tester.RestManager;
import io.appery.tester.db.entity.User;
import io.appery.tester.rest.listener.LoginListener;
import io.appery.tester.ui.base.fragment.BaseFragment;
import io.appery.tester.ui.login.callback.AuthCallback;
import io.appery.tester.ui.projects.activity.GeneralProjectsActivity;
import io.appery.tester.utils.DialogHelper;
import io.appery.tester.utils.PrefsUtil;
import io.appery.tester.utils.WidgetUtils;

/**
 * Created by Alexandr.Salin on 11/28/15.
 */
public class AuthFragment extends BaseFragment implements AuthCallback {

    private static final String TAG = "AuthFragment";

    @Bind(R.id.login_et)
    EditText etUsername;

    @Bind(R.id.password_et)
    EditText etPassword;

    private MaterialDialog progressDialog;

    private LoginListener loginListener;

    @Override
    protected int getResId() {
        return R.layout.fragment_auth;
    }

    @OnClick(R.id.enter_code_btn)
    protected void enterCodeClick() {
        DialogHelper.buildProjectByCodeDialog(getContext());
    }

    @Override
    public void onStart() {
        super.onStart();
        String username = PrefsUtil.getInstance().getString(Constants.PREFERENCES.USERNAME, Constants.EMPTY_STRING);
        String password = PrefsUtil.getInstance().getString(Constants.PREFERENCES.PASSWORD, Constants.EMPTY_STRING);
        WidgetUtils.setText(getActivity(), R.id.login_et, username);
        WidgetUtils.setText(getActivity(), R.id.password_et, password);
        loginListener = new LoginListener(this);
    }

    @Override
    public void onStop() {
        super.onStop();
        loginListener.setAuthCallback(null);
    }

    @OnClick(R.id.sign_in_btn)
    protected void doLogin() {
        String username = etUsername.getText().toString();
        String password = etPassword.getText().toString();
        onStartAuth();
        RestManager.doLogin(this, new User(username, password), loginListener);
    }

    @Override
    public void onStartAuth() {
        progressDialog = DialogHelper.buildAuthProgressDialog(getContext());
    }

    @Override
    public void onAuthFailed(Throwable spiceException) {
        Log.e(TAG, "Authentication failed", spiceException);
        progressDialog.dismiss();
        Snackbar.make(etUsername, spiceException.getMessage(), Snackbar.LENGTH_LONG)
                .setAction("Action", null).show();
    }

    @Override
    public void onAuthSuccess() {
        Log.d(TAG, "Authentication successed");
        progressDialog.dismiss();
        Intent intent = new Intent(getContext(), GeneralProjectsActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(intent);
    }
}
