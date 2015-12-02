package io.appery.tester.utils;

/**
 * @author Daniel Lukashevich
 */
public interface Constants {

    public static final String EMPTY_STRING = "";

    public interface API {
        public static final String LOGIN = "/idp/doLogin";

        public static final String SAML = "SAML";

        public static final String GET_PROJECTLIST = "/app/rest/projects";

        public static final String GET_PROJECT_RESOURCE = "/app/project/%s/export/sources/web_resources/";

        public static final String GET_PROJECT_RESOURCE_BY_CODE = "/app/rest/project/shared/%s/export/sources/WEB_RESOURCES";

        public static final String LOGOUT = "/idp/doLogout";

        public static final String GET_USER_ID = "/app/rest/user/user-id";

        public static final String LOGIN_TARGET = "/app/";
    }

    public interface DIALOGS {

        public static final int PROGRESS = 1;

        public static final int SIGN_IN = 2;

        public static final int COMPLETE_ACTION = 3;

        public static final int PROJECT_ACTION = 4;

        public static final int SORT = 6;
    }

    public interface PREFERENCES {
        public static final String BASE_URL = "base_url";

        public static final String USERNAME = "username";

        public static final String PASSWORD = "password";

        public static final String SAML_KEY = "saml_key";
    }

    public interface EXTRAS {
        public static final String SORT_BY = "SORT_BY";

        public static final String PROJECTS_LIST = "PROJECTS_LIST";

        public static final String SELECTED_PROJECT = "SELECTED_PROJECT";

        public static final String USER_ID = "USER_ID";

    }

    public interface PARAMS {
        public static final String USERNAME_PARAM = "cn";
        public static final String PASSWORD_PARAM = "pwd";
        public static final String TARGET_PARAM = "target";
        public static final String SAML_RESPONSE_PARAM = "SAMLResponse";
    }

    public static final String FILENAME_APK = "app.apk";

    public static final String FILENAME_ZIP = "project.zip";

}
