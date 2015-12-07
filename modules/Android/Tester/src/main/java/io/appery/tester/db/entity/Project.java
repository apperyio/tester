package io.appery.tester.db.entity;

import android.content.ContentResolver;
import android.net.Uri;

import com.google.gson.annotations.SerializedName;
import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;
import com.tojc.ormlite.android.annotation.AdditionalAnnotation;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;

import io.appery.tester.db.Contract;

@DatabaseTable(tableName = Project.TABLENAME)
@AdditionalAnnotation.DefaultContentUri(authority = Contract.AUTHORITY, path = Project.CONTENT_URI_PATH)
@AdditionalAnnotation.DefaultContentMimeTypeVnd(name = Project.MIMETYPE_NAME, type = Project.MIMETYPE_TYPE)
public class Project implements Entity {
    public static final String TABLENAME = "MediaSummary";
    public static final String CONTENT_URI_PATH = TABLENAME;
    public static final String MIMETYPE_TYPE = TABLENAME;
    public static final String MIMETYPE_NAME = Contract.AUTHORITY + ".provider";
    public static final int CONTENT_URI_PATTERN_MANY = 5041;
    public static final int CONTENT_URI_PATTERN_ONE = 5042;
    public static final Uri contentUri = new Uri.Builder()
            .scheme(ContentResolver.SCHEME_CONTENT)
            .authority(Contract.AUTHORITY)
            .appendPath(CONTENT_URI_PATH).build();
    private static final long serialVersionUID = 6953819465393717984L;

    public static final String GUID_FIELD = "guid";
    public static final String NAME_FIELD = "name";
    public static final String LAST_EDITOR_FIELD = "lasteditor";
    public static final String LAST_EDIT_DATE_FIELD = "modifiedDate";
    public static final String OWNER_FIELD = "creator";
    public static final String CREATED_DATE_FIELD = "creationDate";
    public static final String LINK_FIELD = "link_date";
    public static final String RESOURCES_LINK_FIELD = "resources_link_date";
    public static final String TYPE_FIELD = "type";
    public static final String DISABLED_FIELD = "disabled";

    @DatabaseField(columnName = Project._ID, generatedId = true)
    @AdditionalAnnotation.DefaultSortOrder
    private int _id;

    @SerializedName(GUID_FIELD)
    @DatabaseField(columnName = GUID_FIELD)
    private String guid;

    @SerializedName(NAME_FIELD)
    @DatabaseField(columnName = NAME_FIELD)
    private String name;

    @SerializedName(LAST_EDITOR_FIELD)
    @DatabaseField(columnName = LAST_EDITOR_FIELD)
    private String lastEditor;

    @SerializedName(LAST_EDIT_DATE_FIELD)
    @DatabaseField(columnName = LAST_EDIT_DATE_FIELD)
    private long lastEditDate;

    @SerializedName(OWNER_FIELD)
    @DatabaseField(columnName = OWNER_FIELD)
    private String owner;

    @SerializedName(CREATED_DATE_FIELD)
    @DatabaseField(columnName = CREATED_DATE_FIELD)
    private long createdDate;

    @SerializedName(LINK_FIELD)
    @DatabaseField(columnName = LINK_FIELD)
    private String link;

    @SerializedName(RESOURCES_LINK_FIELD)
    @DatabaseField(columnName = RESOURCES_LINK_FIELD)
    private String resourcesLink;

    @SerializedName(TYPE_FIELD)
    @DatabaseField(columnName = TYPE_FIELD)
    private int type;

    @SerializedName(DISABLED_FIELD)
    @DatabaseField(columnName = DISABLED_FIELD)
    private boolean disabled;

    public Project() {
    }

    public String getGuid() {
        return guid;
    }

    public void setGuid(String guid) {
        this.guid = guid;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getLastEditor() {
        return lastEditor;
    }

    public void setLastEditor(String lastEditor) {
        this.lastEditor = lastEditor;
    }

    public Date getLastEditDate() {
        return new Date(lastEditDate);
    }

    public void setLastEditDate(long lastEditDate) {
        this.lastEditDate = lastEditDate;
    }

    public String getOwner() {
        return owner;
    }

    public void setOwner(String owner) {
        this.owner = owner;
    }

    public Date getCreatedDate() {
        return new Date(createdDate);
    }

    public void setCreatedDate(long createdDate) {
        this.createdDate = createdDate;
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

    public void setResourcesLink(String resourcesLink) {
        this.resourcesLink = resourcesLink;
    }

    public ProjectType getType() {
        return ProjectType.get(type);
    }

    public boolean isDisabled() {
        return disabled;
    }

    public void setDisabled(boolean disabled) {
        this.disabled = disabled;
    }

    @Override
    public String toString() {
        return "Project{" +
                "guid='" + guid + '\'' +
                ", name='" + name + '\'' +
                ", link='" + link + '\'' +
                ", resourcesLink='" + resourcesLink + '\'' +
                ", owner='" + owner + '\'' +
                '}';
    }

    @SuppressWarnings("serial")
    public static class ProjectsList extends ArrayList<Project> {

    }
}
