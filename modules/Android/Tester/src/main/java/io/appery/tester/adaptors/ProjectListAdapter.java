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
import android.widget.LinearLayout;

/**
 * @author Daniel Lukashevich
 */
public class ProjectListAdapter extends BaseAdapter {

    private Context mContext;

    private List<Project> mProjectList = new ArrayList<Project>();

    public void setmProjectList(List<Project> mProjectList) {
        this.mProjectList = mProjectList;
    }
    public ProjectListAdapter(Context context, List<Project> projects) {
        this.mContext = context;
        this.mProjectList = projects;
    }

    @Override
    public int getCount() {
        if (mProjectList==null) return 0;
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
        WidgetUtils.setText(view, R.id.lastEditor_tv, project.getOwner());

        String lastEditDate = "";
        if (project.getLastEditDate() != null) {
            lastEditDate = DateFormat.getMediumDateFormat(mContext).format(project.getLastEditDate());
        } else {
            LinearLayout dateLayout = (LinearLayout) view.findViewById(R.id.lastEditDate_lo);
            dateLayout.setVisibility(View.GONE);
        }
        WidgetUtils.setText(view, R.id.lastEditDate_tv, lastEditDate);
    }

}
