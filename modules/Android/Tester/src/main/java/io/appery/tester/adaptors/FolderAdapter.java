package io.appery.tester.adaptors;

import android.R;

import android.content.Context;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Created with IntelliJ IDEA.
 * User: apai
 * Date: 25.04.13
 * Time: 14:12
 *
 * class used for display , select folders
 */
public class FolderAdapter extends BaseAdapter {
    public int selected=-1;
    private View selectedView=null;
    private int mSelectedColor;
    private int mDefaultFolderID=0;



    private List<String> mFolders= new ArrayList<String>();
    private Context mContext;

    static class ViewHolder {
        public TextView tvFolder;
    }
    public FolderAdapter(Context context , List<String> folders , int selectedCcolor){
        mContext=  context;
        mFolders = folders;
        mSelectedColor =selectedCcolor;
    }

    @Override
    public int getCount() {
        return mFolders.size();
    }

    @Override
    public String getItem(int i) {
        if (mFolders.size()>i)
            return mFolders.get(i);
        else
            return null;
    }

    @Override
    public long getItemId(int i) {
        return i;
    }

    @Override
    public View getView(int i, View view, ViewGroup viewGroup) {
        if (view==null) {
            view = LayoutInflater.from(mContext).inflate(io.appery.tester.R.layout.folder_row, null);
            ViewHolder holder= new ViewHolder();
            holder.tvFolder = (TextView)view.findViewById(io.appery.tester.R.id.tv_folder_row);
            view.setTag(holder);

            if (i==mDefaultFolderID){
                selected = i;
                selectedView=view;
            }
            if (mDefaultFolderID==-1&&selected==-1&&i==0){
                selected=0;
                selectedView=view;
            }

        }
        ViewHolder holder = (ViewHolder)view.getTag();
        holder.tvFolder.setText(mFolders.get(i));

        if (i==selected)
            view.setBackgroundColor(mSelectedColor);
        else
            view.setBackgroundColor(R.color.transparent);
        return view;
    }


    public void setSelected(int pos , View v){
        if (selected==pos) return;
        unselect();
        selected=pos;
        selectedView = v;
        if (v!=null){
            selectedView.setBackgroundColor(mSelectedColor);
        }
    }
    public int getSelected(){
        return selected;
    }

    private void unselect() {
        if (selectedView!=null)    {
            selectedView.setBackgroundColor(Color.TRANSPARENT);
        }
    }
    public void resetSelection(){
        unselect();
        selected=-1;
    }

    public void setFolders(List<String> mFolders) {
        this.mFolders = mFolders;
    }


}
