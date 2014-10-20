package io.appery.tester.data;

import org.apache.http.cookie.Cookie;

import java.io.Serializable;

public class SerializedCookie implements Serializable {

    private static final long serialVersionUID = 5327445113190674523L;

    private String name;
    private String value;
    private String domain;
    private String path;

    public SerializedCookie(Cookie cookie){
        this.name = cookie.getName();
        this.value = cookie.getValue();
        this.domain = cookie.getDomain();
        this.path = cookie.getPath();
    }

    public String getName(){
        return name;
    }

    public String getValue(){
        return value;
    }

    public String getDomain(){
        return domain;
    }

    public String getPath(){
        return path;
    }
}
