package io.appery.tester;

/**
 * @author Daniel Lukashevich
 */
public interface Constants {

    public static final String EMPTY_STRING = "";

    interface Loader {
        int PROJECT_LOADER = 0x0001;
    }

    interface RequestCode {
        int PPERMISSION_REQUEST_CODE = 123;
    }

    interface Direction {
        public static final String ASC = "ASC";
        public static final String DESC = "DESC";
    }

    public interface API {
        public static final String LOGIN = "/idp/doLogin";
        public static final String SAML_ENDPOINT = "/app/";

        public static final String GET_PROJECTLIST = "/app/rest/projects";

        public static final String GET_PROJECT_RESOURCE = "/app/project/%s/export/sources/web_resources/";

        public static final String GET_PROJECT_RESOURCE_BY_CODE = "/app/rest/project/shared/%s/export/sources/WEB_RESOURCES";

        public static final String LOGOUT = "/idp/doLogout";

    }

    public interface PREFERENCES {
        public static final String BASE_URL = "base_url";

        public static final String USERNAME = "username";

        public static final String PASSWORD = "password";

        public static final String SAML_KEY = "saml_key";
    }

    public interface EXTRAS {
        public static final String SORT_BY = "SORT_BY";
    }

    public interface PARAMS {
        public static final String USERNAME_PARAM = "cn";
        public static final String PASSWORD_PARAM = "pwd";
        public static final String TARGET_PARAM = "target";
        public static final String SAML_RESPONSE_PARAM = "SAMLResponse";
    }

    public static final String FILENAME_ZIP = "project.zip";

}
