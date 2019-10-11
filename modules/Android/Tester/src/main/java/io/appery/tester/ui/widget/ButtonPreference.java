package io.appery.tester.ui.widget;

import android.content.Context;
import android.preference.Preference;
import android.util.AttributeSet;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;

import io.appery.tester.R;

/**
 * Button custom preference.
 * 
 * @author ayakovenko
 * 
 */
public class ButtonPreference extends Preference {

    public ButtonPreference(Context context) {
        super(context);
    }

    public ButtonPreference(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public ButtonPreference(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    @Override
    protected View onCreateView(ViewGroup parent) {
        View layout = super.onCreateView(parent);

        View ll = layout.findViewById(android.R.id.widget_frame);
        if (ll instanceof LinearLayout) {
            Button btn = new Button(getContext());
            btn.setText(R.string.clear_credentials_btn);
            btn.setOnClickListener(new OnClickListener() {

                @Override
                public void onClick(View view) {
                    callChangeListener(null);
                }
            });
            ((LinearLayout) ll).addView(btn);
        }

        return layout;
    }

}
