package io.appery.tester.adaptors;

import io.appery.tester.R;
import io.appery.tester.data.Project;
import io.appery.tester.utils.WidgetUtils;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.text.format.DateFormat;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;

/**
 * @author Daniel Lukashevich
 */
public class ProjectListAdapter extends BaseAdapter {

    private Context mContext;

    private List<Project> mProjectList = new ArrayList<Project>();

    public ProjectListAdapter(Context context, List<Project> projects) {
        this.mContext = context;
        this.mProjectList = projects;
    }

    @Override
    public int getCount() {
        return mProjectList.size();
    }

    @Override
    public Project getItem(int position) {
        return mProjectList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {

        if (convertView == null) {
            convertView = LayoutInflater.from(mContext).inflate(R.layout.project_list_item, null);
        }

        fillView(convertView, position);

        return convertView;
    }

    private void fillView(View view, int pos) {
        Project project = mProjectList.get(pos);
        WidgetUtils.setText(view, R.id.title_tv, project.getName());
        WidgetUtils.setText(view, R.id.lastEditor_tv, project.getLastEditor());

        String lastEditDate = "";
        if (project.getLastEditDate() != null) {
            lastEditDate = DateFormat.getMediumDateFormat(mContext).format(project.getLastEditDate());
        }
        WidgetUtils.setText(view, R.id.lastEditDate_tv, lastEditDate);
    }

}
