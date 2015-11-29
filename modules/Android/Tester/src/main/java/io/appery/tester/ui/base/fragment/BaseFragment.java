package io.appery.tester.ui.base.fragment;

import android.content.Context;

import com.octo.android.robospice.SpiceManager;

import io.appery.tester.rest.SpiceHolder;
import io.appery.tester.ui.base.activity.SpiceActivity;

/**
 * Created by Alexandr.Salin on 11/28/15.
 */
public abstract class BaseFragment extends ButterKnifeFragment implements SpiceHolder {

    protected SpiceManager spiceManager;

    @Override
    public SpiceManager getSpiceManager() {
        return spiceManager;
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        spiceManager = ((SpiceActivity) context).getSpiceManager();
    }

    @Override
    public void onDetach() {
        super.onDetach();
        spiceManager = null;
    }
}
