package io.appery.tester.data;

import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;

import io.appery.tester.utils.Constants;

/**
 * @author Daniel Lukashevich
 */
public class Project implements Serializable {

    private static final long serialVersionUID = 6953819465393717984L;

    private int id;

    private String guid;

    private String name;

    private String lastEditor = "";

    private Date lastEditDate = null;


    private String owner = "<noname>";

    private Date createdDate = null;

    private String link;

    private String resourcesLink;

    public Project() {
    }

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

            if (json.has("guid")) {
                guid = json.getString("guid");
                resourcesLink = String.format(Constants.API.GET_PROJECT_RESOURCE, guid);
            }

//            if (json.has("link")) {
//                link = json.getString("link");
//
//                // building resources link
//                try {
//                    String[] urlParts = TextUtils.split(link, "/");
//                    id = Integer.parseInt(urlParts[urlParts.length - 2]);
//                    resourcesLink = String.format(Constants.API.GET_PROJECT_RESOURCE, id);
//                } catch (Exception e) {
//                    Log.e("Project", "Can't compose a link to resources", e);
//                }
//            }
            if (json.has("lasteditor")) {
                lastEditor = json.getString("lasteditor");
            }
            if (json.has("modifiedDate")) {
                try {
                    lastEditDate = new Date(json.getLong("modifiedDate"));
                } catch (Exception e) {
                    /* do nothing. */
                }
            }
            if (json.has("creationDate")) {
                try {
                    createdDate = new Date(json.getLong("creationDate"));
                } catch (Exception e) {
                    /* do nothing. */
                }
            }
            if (json.has("creator")) {
                owner = json.getString("creator"); // TODO get rid of owner
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

    public String getGUID() {
        return this.guid;
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
     * @param lastEditor the lastEditor to set
     */
    public void setLastEditor(String lastEditor) {
        this.lastEditor = lastEditor;
    }

    public Date getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Date createdDate) {
        this.createdDate = createdDate;
    }

    /**
     * @return the lastEditDate
     */
    public Date getLastEditDate() {
        return lastEditDate;
    }

    /**
     * @param lastEditDate the lastEditDate to set
     */
    public void setLastEditDate(Date lastEditDate) {
        this.lastEditDate = lastEditDate;
    }

    public String getOwner() {
        return owner;
    }

    @SuppressWarnings("serial")
    public static class ProjectsList extends ArrayList<Project> {

    }
}
