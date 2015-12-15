package io.appery.tester.utils;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;

/**
 * Impelementation for check and ask permissions in runtime for using in Android 6 (Marshmallow)
 * Created by Alexandr.Salin on 12/15/15.
 */
public class PermissionsUtil {

    public static boolean checkTesterHasAllNeededPermissions(Context context) {
        List<String> permissions = null;
        try {
            permissions = new ArrayList<String>(Arrays.asList(context.getPackageManager().getPackageInfo(context.getPackageName(), PackageManager.GET_PERMISSIONS).requestedPermissions));
        } catch (Exception ignore) {
        }
        return hasGroupPermission(context, permissions);
    }

    public static void askTesterHasAllNeededPermissions(PermissionRequestHandler handler) {
        List<String> permissions = null;
        try {
            permissions = new ArrayList<String>(Arrays.asList(handler
                    .getTargetActivity()
                    .getPackageManager()
                    .getPackageInfo(handler.getTargetActivity().getPackageName(), PackageManager.GET_PERMISSIONS).requestedPermissions));
        } catch (Exception ignore) {
        }
        checkAndAskPermissionsIfNeed(handler, permissions);
    }

    public static boolean hasMarshMallow() {
        return Build.VERSION.SDK_INT >= 23;
    }

    static public boolean hasSinglePermission(Context context, String permission) {
        boolean result = true;
        if (hasMarshMallow()) {
            int hasWriteContactsPermission = context.checkSelfPermission(permission);
            return hasWriteContactsPermission == PackageManager.PERMISSION_GRANTED;
        } else {
            return result;
        }
    }

    static public boolean hasGroupPermission(Context context, Collection<String> permissions) {
        if (!hasMarshMallow()) {
            return true;
        }
        boolean result = true;
        for (String perm : permissions) {
            if (!(result = hasSinglePermission(context, perm))) {
                break;
            }
        }
        return result;
    }

    static public void checkAndAskPermissionsIfNeed(PermissionRequestHandler holder, Collection<String> permissions) {
        if (!hasMarshMallow() || permissions == null || permissions.size() == 0) {
            return;
        }
        Collection<String> permissionsNedded = new ArrayList<>();
        for (String perm : permissions) {
            if (!hasSinglePermission(holder.getTargetActivity(), perm)) {
                permissionsNedded.add(perm);
            }
        }
        if (permissionsNedded.size() > 0) {
            ActivityCompat.requestPermissions(holder.getTargetActivity(), permissionsNedded.toArray(new String[permissionsNedded.size()]),
                    holder.getRequestCode());
        }

    }

    public interface PermissionRequestHandler {

        Activity getTargetActivity();

        int getRequestCode();

        void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults);

    }
}
