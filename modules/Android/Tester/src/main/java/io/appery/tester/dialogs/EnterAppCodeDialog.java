package io.appery.tester.dialogs;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.text.InputType;
import android.widget.EditText;
import io.appery.tester.R;
import io.appery.tester.preview.ProjectPreviewManager;

/**
 * Created by Maxim Balyaba on 13.07.2015.
 */
public class EnterAppCodeDialog {

    private Context context;

    private ProjectPreviewManager projectPreviewManager;

    private Dialog dialog;

    public EnterAppCodeDialog(Context context, ProjectPreviewManager projectPreviewManager) {
        super();
        this.context = context;
        this.projectPreviewManager = projectPreviewManager;
        prepareDialog();
    }

    private void prepareDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setTitle(context.getString(R.string.enter_app_code_dialog_title));
        final EditText input = new EditText(context);
        input.setInputType(InputType.TYPE_CLASS_TEXT);
        builder.setView(input);

        builder.setPositiveButton(context.getString(R.string.enter_app_code_pos_button), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                String codeText = input.getText().toString();
                projectPreviewManager.downloadAndStartProjectPreviewByCode(codeText);
            }
        });

        builder.setNegativeButton(context.getString(R.string.enter_app_code_cancel_button), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
            }
        });
        this.dialog = builder.create();
    }

    public void show() {
        this.dialog.show();
    }
}
