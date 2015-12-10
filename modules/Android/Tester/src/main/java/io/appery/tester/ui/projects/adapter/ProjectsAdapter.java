package io.appery.tester.ui.projects.adapter;

import android.content.Context;
import android.database.Cursor;
import android.text.format.DateFormat;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CursorAdapter;
import android.widget.ImageView;

import java.util.Date;

import io.appery.tester.Constants;
import io.appery.tester.R;
import io.appery.tester.db.entity.Project;
import io.appery.tester.db.entity.ProjectType;
import io.appery.tester.utils.WidgetUtils;

/**
 * Created by Alexandr.Salin on 12/7/15.
 */
public class ProjectsAdapter extends CursorAdapter {

    public ProjectsAdapter(Context context, Cursor c, boolean autoRequery) {
        super(context, c, autoRequery);
    }

    public ProjectsAdapter(Context context, Cursor c, int flags) {
        super(context, c, flags);
    }

    @Override
    public View newView(Context context, Cursor cursor, ViewGroup parent) {
        return LayoutInflater.from(context).inflate(R.layout.project_list_item, parent, false);
    }

    @Override
    public void bindView(View view, Context context, Cursor cursor) {
        String name = cursor.getString(cursor.getColumnIndexOrThrow(Project.NAME_FIELD));
        String owner = cursor.getString(cursor.getColumnIndexOrThrow(Project.OWNER_FIELD));
        long lastEditDate = cursor.getLong(cursor.getColumnIndexOrThrow(Project.LAST_EDIT_DATE_FIELD));
        int type = cursor.getInt(cursor.getColumnIndexOrThrow(Project.TYPE_FIELD));

        WidgetUtils.setText(view, R.id.title_tv, name);
        WidgetUtils.setText(view, R.id.lastEditor_tv, owner);
        ImageView logo = (ImageView) view.findViewById(R.id.logo);

        String lastEditDateText = Constants.EMPTY_STRING;
        if (lastEditDate > 0) {
            lastEditDateText = DateFormat.getMediumDateFormat(context).format(new Date(lastEditDate));
        }
        WidgetUtils.setText(view, R.id.lastEditDate_tv, lastEditDateText);
        setupLogo(logo, type);
    }

    private void setupLogo(ImageView logo, int type) {
        switch (ProjectType.get(type)) {
            case METRO:
                logo.setImageResource(R.drawable.ic_bootstrap);
                break;
            case ANGULAR:
                logo.setImageResource(R.drawable.ic_bootstrap);
                break;
            case ANGULAR_IONIC:
                logo.setImageResource(R.drawable.ic_ionic);
                break;
            case MOBILE:
                logo.setImageResource(R.drawable.ic_jqm);
                break;
        }
    }
}
