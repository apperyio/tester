package io.appery.tester.ui.base.fragment;

import android.os.Bundle;
import android.support.annotation.LayoutRes;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import butterknife.ButterKnife;

/**
 * Created by Alexandr.Salin on 11/28/15.
 */
public abstract class ButterKnifeFragment extends Fragment {

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(getResId(), container, false);
        ButterKnife.bind(this, view);
        afterViews(savedInstanceState);
        return view;
    }

    protected void afterViews(Bundle savedInstanceState) {}

    @LayoutRes
    abstract protected int getResId();
}
