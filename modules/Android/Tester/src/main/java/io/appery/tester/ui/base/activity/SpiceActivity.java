package io.appery.tester.ui.base.activity;

import com.octo.android.robospice.SpiceManager;

import io.appery.tester.rest.SpiceHolder;
import io.appery.tester.rest.TesterSpiceManager;
import io.appery.tester.rest.TesterSpiceService;

/**
 * Created by Alexandr.Salin on 11/29/15.
 */
public abstract class SpiceActivity extends ButterKnifeActivity implements SpiceHolder {
    private SpiceManager spiceManager = new TesterSpiceManager(TesterSpiceService.class);

    @Override
    protected void onStart() {
        spiceManager.start(this);
        super.onStart();
    }

    @Override
    protected void onStop() {
        spiceManager.shouldStop();
        super.onStop();
    }

    public SpiceManager getSpiceManager() {
        return spiceManager;
    }
}
