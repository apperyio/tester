package io.appery.tester.db.entity;

/**
 * Created by Alexandr.Salin on 11/29/15.
 */

public class User {

    private String username;

    private String password;

    private String samlKey;

    public User(String username, String password) {
        this.username = username;
        this.password = password;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getSamlKey() {
        return samlKey;
    }

    public void setSamlKey(String key) {
        this.samlKey = key;
    }

}
