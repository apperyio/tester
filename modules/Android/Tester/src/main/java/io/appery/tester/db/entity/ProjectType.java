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
    MOBILE(1),
    METRO(6),
    ANGULAR(7),
    ANGULAR_IONIC(8);

    private final int id;

    ProjectType(int id) {
        this.id = id;
    }

    public int getId() {
        return id;
    }

    public static ProjectType get(int value) {
        ProjectType result = MOBILE;
        switch (value) {
            case 8: {
                result = ANGULAR_IONIC;
                break;
            }
            case 7: {
                result = ANGULAR;
                break;
            }
            case 6: {
                result = METRO;
                break;
            }
            case 1:
            default:
                result = MOBILE;
        }
        return result;
    }
}
