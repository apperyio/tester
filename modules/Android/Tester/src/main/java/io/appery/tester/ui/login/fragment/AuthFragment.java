package io.appery.tester.ui.login.fragment;

import butterknife.OnClick;
import io.appery.tester.R;
import io.appery.tester.preview.ProjectPreviewManager;
import io.appery.tester.ui.base.fragment.BaseFragment;
import io.appery.tester.ui.dialogs.EnterAppCodeDialog;
import io.appery.tester.utils.Constants;
import io.appery.tester.utils.PrefsUtil;
import io.appery.tester.utils.WidgetUtils;

/**
 * Created by Alexandr.Salin on 11/28/15.
 */
public class AuthFragment extends BaseFragment {

    private ProjectPreviewManager projectPreviewManager;

    @Override
    protected int getResId() {
        return R.layout.frg_auth;
    }

    @OnClick(R.id.enter_code_btn)
    protected void enterCodeClick() {
        EnterAppCodeDialog enterAppCodeDialog = new EnterAppCodeDialog(getContext(), projectPreviewManager);
        enterAppCodeDialog.show();
    }

    @Override
    public void onStart() {
        super.onStart();
        String username = PrefsUtil.getInstance().getString(Constants.PREFERENCES.USERNAME, Constants.EMPTY_STRING);
        String password = PrefsUtil.getInstance().getString(Constants.PREFERENCES.PASSWORD, Constants.EMPTY_STRING);
        WidgetUtils.setText(getActivity(), R.id.login_et, username);
        WidgetUtils.setText(getActivity(), R.id.password_et, password);
    }

}
