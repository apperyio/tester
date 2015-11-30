package io.appery.tester.ui.base.activity;

import android.os.Bundle;
import android.support.annotation.LayoutRes;
import android.support.v7.app.AppCompatActivity;

import butterknife.ButterKnife;

/**
 * Created by Alexandr.Salin on 11/28/15.
 */
public abstract class ButterKnifeActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(getResId());
        ButterKnife.bind(this);
        afterViews(savedInstanceState);
    }

    protected void afterViews(Bundle savedInstanceState) {}

    @LayoutRes
    abstract protected int getResId();
}
