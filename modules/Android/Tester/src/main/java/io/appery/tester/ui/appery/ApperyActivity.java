package io.appery.tester.ui.appery;

import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;

import org.apache.cordova.CordovaActivity;
import org.apache.cordova.CordovaWebViewEngine;
import org.apache.cordova.engine.SystemWebViewEngine;

import io.appery.tester.R;
import io.appery.tester.db.entity.ProjectType;
import io.appery.tester.utils.CommonUtil;

/**
 * @author Daniel Lukashevich
 */
public class ApperyActivity extends CordovaActivity {

    private static final String TAG = "ApperyActivity";

    @Override
    public void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        loadUrl(launchUrl);
        if (this.getIntent().hasExtra("project_type")) {
            ProjectType projectType = ProjectType.get(this.getIntent().getIntExtra("project_type", ProjectType.JQM.getId()));
            if (projectType == ProjectType.IONIC4) {
                CommonUtil.showMessage(this.getBaseContext(), this.getBaseContext().getString(R.string.stop_an_app_toast));
            }
        }
    }

    @Override
    protected void init() {
        super.init();

        // Workaround for https://bugs.chromium.org/p/chromium/issues/detail?id=541145
        CordovaWebViewEngine engine = appView.getEngine();
        if (engine instanceof SystemWebViewEngine) {
            ((SystemWebViewEngine) engine).getView().setLayerType(View.LAYER_TYPE_SOFTWARE, null);
        }
        // End of workaround
    }

    @Override
    public void onReceivedError(int errorCode, String description, String failingUrl) {
        Log.e(TAG, "An error received: \"" + description + "\" at '" + failingUrl + "'");
    }

    /* (non-Javadoc)
     * @see org.apache.cordova.CordovaActivity#onKeyUp(int, android.view.KeyEvent)
     */
    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        boolean result = super.onKeyUp(keyCode, event);
        // End activity if return to projects list
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            Log.d(TAG, "Finish activity");
            finish();
        }
        return result;
    }

}
