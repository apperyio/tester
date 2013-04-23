package io.appery.tester.data;

import io.appery.tester.utils.Constants;

import java.io.Serializable;
import java.util.Date;

import org.json.JSONException;
import org.json.JSONObject;

import android.text.TextUtils;
import android.util.Log;

/**
 * @author Daniel Lukashevich
 */
public class Project implements Serializable {

    private static final long serialVersionUID = 6953819465393717984L;

    private int id;

    private String name;

    private String lastEditor = "";

    private Date lastEditDate = null;

    private String link;

    private String resourcesLink;

    /**
     * Create Project from Json Object <BR/>
     * Example: <code>{"name":"Mercury","link":"http://localhost/17/mercury.apk"}</code>
     * 
     * @param json
     * @return
     * @throws JSONException
     */
    public Project(JSONObject json) throws JSONException {
        if (json != null) {
            if (json.has("name")) {
                name = json.getString("name");
            }
            if (json.has("link")) {
                link = json.getString("link");

                // building resources link
                try {
                    String[] urlParts = TextUtils.split(link, "/");
                    id = Integer.parseInt(urlParts[urlParts.length - 2]);
                    resourcesLink = String.format(Constants.API.GET_PROJECT_RESOURCE, id);
                } catch (Exception e) {
                    Log.e("Project", e.getMessage());
                }
            }
            if (json.has("lasteditor")) {
                lastEditor = json.getString("lasteditor");
            }
            if (json.has("lastedited")) {
                try {
                    lastEditDate = new Date(json.getLong("lastedited"));
                } catch (Exception e) {
                    /* do nothing. */
                }
            }
        }

        Log.d("Project", toString());
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getId() {
        return this.id;
    }

    public String getLink() {
        return link;
    }

    public void setLink(String link) {
        this.link = link;
    }

    public String getResourcesLink() {
        return resourcesLink;
    }

    public void setResourcesLink(String link) {
        this.resourcesLink = link;
    }

    @Override
    public String toString() {
        return "Name: " + name + ", Link: " + link + ", Resources: " + resourcesLink;
    }

    /**
     * @return the lastEditor
     */
    public String getLastEditor() {
        return lastEditor;
    }

    /**
     * @param lastEditor
     *            the lastEditor to set
     */
    public void setLastEditor(String lastEditor) {
        this.lastEditor = lastEditor;
    }

    /**
     * @return the lastEditDate
     */
    public Date getLastEditDate() {
        return lastEditDate;
    }

    /**
     * @param lastEditDate
     *            the lastEditDate to set
     */
    public void setLastEditDate(Date lastEditDate) {
        this.lastEditDate = lastEditDate;
    }

}
