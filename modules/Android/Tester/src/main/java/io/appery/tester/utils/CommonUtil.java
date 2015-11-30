package io.appery.tester.utils;

import android.content.Context;
import android.view.Gravity;
import android.widget.TextView;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import io.appery.tester.TesterApplication;
import retrofit.client.Header;

/**
 * Created by Maxim Balyaba on 14.07.2015.
 */
public class CommonUtil {

    public static void showMessage(Context context, String message) {
        Toast toast = Toast.makeText(context, message, Toast.LENGTH_LONG);
        TextView v = (TextView) toast.getView().findViewById(android.R.id.message);
        if (v != null) v.setGravity(Gravity.CENTER);
        toast.show();
    }

    public static void showToast(String text, int duration) {
        Toast.makeText(TesterApplication.getInstance(), text, duration).show();
    }

    public static void showToast(int resId, int duration) {
        Toast.makeText(TesterApplication.getInstance(), resId, duration).show();
    }

    public static void showToast(String text) {
        showToast(text, Toast.LENGTH_SHORT);
    }

    public static void showToast(int resId) {
        showToast(resId, Toast.LENGTH_SHORT);
    }

    public static boolean isEmpty(Collection<?> collection) {
        boolean result = false;
        if (collection == null || collection.isEmpty()) {
            result = true;
        }
        return result;
    }

    public static <T> Class<T> getGenericClass(Collection<T> collection) {
        if (isEmpty(collection)) {
            throw new IllegalArgumentException("add() " + ((collection == null) ? "null" : "empty") + " collection");
        }
        return (Class<T>) collection.iterator().next().getClass();

    }

    public static <T> List<T> getNewArrayList() {
        return new ArrayList<T>();
    }

    static public Header getHeaderByName(List<Header> headersList, String name) {
        Header result = null;
        for (Header temp : headersList) {
            if (temp.getName().equals(name)) {
                result = temp;
                break;
            }
        }
        return result;
    }
}
