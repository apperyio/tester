package io.appery.tester.utils;

import android.content.Context;
import android.view.Gravity;
import android.widget.TextView;
import android.widget.Toast;

/**
 * Created by Maxim Balyaba on 14.07.2015.
 */
public class ToastUtils {

    public static void showMessage(Context context,String message){
        Toast toast = Toast.makeText(context,message, Toast.LENGTH_LONG);
        TextView v = (TextView) toast.getView().findViewById(android.R.id.message);
        if( v != null) v.setGravity(Gravity.CENTER);
        toast.show();
    }
}
