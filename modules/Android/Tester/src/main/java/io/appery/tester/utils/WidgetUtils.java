package io.appery.tester.utils;

import android.app.Activity;
import android.view.View;
import android.widget.TextView;

/**
 * The utils class to work with widgets.
 * 
 * @author ayakovenko
 * 
 */
public class WidgetUtils {

    /**
     * Update TextView text value.
     * 
     * @param view
     *            parent view for TextView.
     * @param id
     *            the TextView ID.
     * @param value
     *            new text value.
     */
    public static void setText(View view, int id, String value) {
        TextView tv = (TextView) view.findViewById(id);
        if (tv != null) {
            tv.setText(value);
        }
    }

    /**
     * Update TextView text value.
     * 
     * @param activity
     *            parent view for TextView.
     * @param id
     *            the TextView ID.
     * @param value
     *            new text value.
     */
    public static void setText(Activity activity, int id, String value) {
        TextView tv = (TextView) activity.findViewById(id);
        if (tv != null) {
            tv.setText(value);
        }
    }

    /**
     * Get text of TextView by id.
     * 
     * @param view
     *            parent view for TextView.
     * @param id
     *            the TextView ID.
     * @param value
     *            new text value.
     */
    public static String getText(View view, int id) {
        TextView tv = (TextView) view.findViewById(id);
        if (tv != null) {
            return getText(tv);
        }
        return null;
    }

    /**
     * Get text of TextView by id.
     * 
     * @param activity
     *            activity for TextView.
     * @param id
     *            the TextView ID.
     * @param value
     *            new text value.
     */
    public static String getText(Activity activity, int id) {
        TextView tv = (TextView) activity.findViewById(id);
        if (tv != null) {
            return getText(tv);
        }
        return null;
    }

    /**
     * Get TextView text.
     * 
     * @param view
     * @return
     */
    public static String getText(TextView view) {
        if (view == null) {
            return null;
        }
        return view.getText().toString();
    }

    /**
     * Checks is TextView empty.
     * 
     * @param view
     * @return <code>true</code> if view is null or doesn't contain text.
     */
    public static boolean isEmpty(TextView view) {
        if (view == null) {
            return true;
        }
        return view.getText().length() == 0;
    }

}
