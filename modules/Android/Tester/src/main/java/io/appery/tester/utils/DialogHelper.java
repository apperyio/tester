package io.appery.tester.utils;

import android.content.Context;

import com.afollestad.materialdialogs.DialogAction;
import com.afollestad.materialdialogs.MaterialDialog;

import io.appery.tester.R;
import io.appery.tester.db.entity.Project;
import io.appery.tester.preview.ProjectPreviewManager;

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
                .title(R.string.app_name)
                .content(String.format(context.getString(R.string.download_project_message), project.getName()))
                .positiveText(R.string.project_action_run)
                .negativeText(R.string.project_action_cancel)
                .onPositive(new MaterialDialog.SingleButtonCallback() {
                    @Override
                    public void onClick(MaterialDialog materialDialog, DialogAction dialogAction) {
                        materialDialog.dismiss();
                        new ProjectPreviewManager(context).downloadAndStartProjectPreview(project.getResourcesLink());
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
}
