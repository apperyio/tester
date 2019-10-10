package io.appery.tester.db.entity;

/**
 * public static Long MOBILE_APPLICATION_ID = 1l;
 * public static Long METRO_APP = 6L;
 * public static Long ANGULAR_APP = 7L;
 * public static Long ANGULAR_IONIC_APP = 8L;
 * <p/>
 * Created by Alexandr.Salin on 12/7/15.
 */
public enum ProjectType {
    JQM(1),
    METRO(6),
    ANGULAR(7),
    ANGULAR_IONIC(8),
    IONIC3(9),
    IONIC4(10);

    private final int id;

    ProjectType(int id) {
        this.id = id;
    }

    public int getId() {
        return id;
    }

    public static ProjectType get(int value) {
        for (ProjectType projectType: ProjectType.values()) {
            if (projectType.id == value) {
                return projectType;
            }
        }
        return JQM;
    }
}
