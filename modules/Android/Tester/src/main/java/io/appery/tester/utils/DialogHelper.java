package io.appery.tester.utils;

import android.content.Context;
import android.widget.EditText;

import com.afollestad.materialdialogs.DialogAction;
import com.afollestad.materialdialogs.MaterialDialog;

import io.appery.tester.R;
import io.appery.tester.RestManager;
import io.appery.tester.TesterApplication;
import io.appery.tester.db.entity.Project;
import io.appery.tester.rest.TesterSpiceEndpoint;

/**
 * Created by Alexandr.Salin on 12/2/15.
 */
public class DialogHelper {
    static public MaterialDialog buildAuthProgressDialog(Context context) {
        return new MaterialDialog.Builder(context)
                .title(R.string.signing_in)
                .content(R.string.please_wait)
                .progress(true, 0)
                .cancelable(false)
                .show();
    }

    static public MaterialDialog buildLogoutProgressDialog(Context context) {
        return new MaterialDialog.Builder(context)
                .title(R.string.signing_out)
                .content(R.string.please_wait)
                .progress(true, 0)
                .cancelable(false)
                .show();
    }

    static public MaterialDialog buildDownloadProjectsProgressDialog(Context context) {
        return new MaterialDialog.Builder(context)
                .title(R.string.refresh_projects_list)
                .content(R.string.please_wait)
                .progress(true, 0)
                .cancelable(false)
                .show();
    }

    static public MaterialDialog buildProjectActionDialog(final Context context, final Project project) {
        return new MaterialDialog.Builder(context)
                .title(R.string.application_name)
                .content(String.format(context.getString(R.string.download_project_message), project.getName()))
                .positiveText(R.string.project_action_run)
                .negativeText(R.string.project_action_cancel)
                .onPositive(new MaterialDialog.SingleButtonCallback() {
                    @Override
                    public void onClick(MaterialDialog materialDialog, DialogAction dialogAction) {
                        materialDialog.dismiss();
                        RestManager.getProjectFile(context, project.getResourcesLink());
                    }
                })
                .onNegative(new MaterialDialog.SingleButtonCallback() {
                    @Override
                    public void onClick(MaterialDialog materialDialog, DialogAction dialogAction) {
                        materialDialog.dismiss();
                    }
                })
                .show();
    }

    static public MaterialDialog buildProjectByCodeDialog(final Context context) {
        return new MaterialDialog.Builder(context)
                .title(R.string.enter_app_code_dialog_title)
                .customView(R.layout.dialog_enter_code, true)
                .positiveText(R.string.enter_app_code_pos_button)
                .negativeText(R.string.enter_app_code_cancel_button)
                .onPositive(new MaterialDialog.SingleButtonCallback() {
                    @Override
                    public void onClick(MaterialDialog materialDialog, DialogAction dialogAction) {
                        materialDialog.dismiss();
                        EditText text = (EditText) materialDialog.findViewById(R.id.et_code);
                        RestManager.getProjectFileByCode(context, WidgetUtils.getText(text));
                    }
                })
                .onNegative(new MaterialDialog.SingleButtonCallback() {
                    @Override
                    public void onClick(MaterialDialog materialDialog, DialogAction dialogAction) {
                        materialDialog.dismiss();
                    }
                })
                .show();
    }

    public static MaterialDialog buildDownloadProjectDialog(Context context) {
        return new MaterialDialog.Builder(context)
                .title(R.string.download_project_files)
                .content(R.string.please_wait)
                .progress(true, 0)
                .cancelable(false)
                .show();
    }
}
