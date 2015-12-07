package io.appery.tester.ui.projects.adapter;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;

import java.util.ArrayList;
import java.util.List;

import io.appery.tester.db.entity.Project;

/**
 * Created by Alexandr.Salin on 12/7/15.
 */
public class ProjectsAdapter extends BaseAdapter{
    private List<Project> projects = new ArrayList<>();

    public ProjectsAdapter(Context context) {
    }

    @Override
    public int getCount() {
        return 0;
    }

    @Override
    public Object getItem(int position) {
        return null;
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        return null;
    }

    public void setProjects(List<Project> projects){

    }

    public void setSort(){

    }
}
