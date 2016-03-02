package io.appery.tester.rest;

import com.octo.android.robospice.SpiceManager;
import com.octo.android.robospice.SpiceService;

/**
 * Created by Alexandr.Salin on 11/28/15.
 */
public class TesterSpiceManager extends SpiceManager {
    /**
     * Creates a {@link SpiceManager}. Typically this occurs in the construction
     * of an Activity or Fragment. This method will check if the service to bind
     * to has been properly declared in AndroidManifest.
     *
     * @param spiceServiceClass the service class to bind to.
     */
    public TesterSpiceManager(Class<? extends SpiceService> spiceServiceClass) {
        super(spiceServiceClass);
    }
}
