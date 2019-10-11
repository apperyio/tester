package io.appery.tester.db;

import android.net.Uri;

import java.util.HashMap;
import java.util.Map;

import io.appery.tester.db.entity.Project;
import io.appery.tester.db.entity.ProjectsCollection;

/**
 * Created by Alexandr.Salin on 12/6/15.
 */
public final class Contract {
    public static final String DATABASE_NAME = "tester.db";

    public static final int DATABASE_VERSION_CR1 = 1;
    public static final int DATABASE_VERSION = DATABASE_VERSION_CR1;

    public static final String AUTHORITY = "io.appery.tester";

    private static final Map<Class<?>, Uri> uriRegisterForPersisterNotification = new HashMap<>();

    static {
        /**
         * inner application entities
         */
        uriRegisterForPersisterNotification.put(Project.class, Project.contentUri);
        uriRegisterForPersisterNotification.put(ProjectsCollection.class, ProjectsCollection.contentUri);
    }

    public static Map<Class<?>, Uri> getUris() {
        return uriRegisterForPersisterNotification;
    }
}
