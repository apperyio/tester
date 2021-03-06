package io.appery.tester.db.entity;

import android.content.ContentResolver;
import android.net.Uri;

import com.google.gson.annotations.SerializedName;
import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;
import com.tojc.ormlite.android.annotation.AdditionalAnnotation;

import java.util.Date;
import java.util.Locale;

import io.appery.tester.Constants;
import io.appery.tester.db.Contract;

@DatabaseTable(tableName = Project.TABLENAME)
@AdditionalAnnotation.DefaultContentUri(authority = Contract.AUTHORITY, path = Project.CONTENT_URI_PATH)
@AdditionalAnnotation.DefaultContentMimeTypeVnd(name = Project.MIMETYPE_NAME, type = Project.MIMETYPE_TYPE)
public class Project implements Entity {
    public static final String TABLENAME = "Project";
    public static final String CONTENT_URI_PATH = TABLENAME;
    public static final String MIMETYPE_TYPE = TABLENAME;
    public static final String MIMETYPE_NAME = Contract.AUTHORITY + ".provider";
    public static final int CONTENT_URI_PATTERN_MANY = 1001;
    public static final int CONTENT_URI_PATTERN_ONE = 1002;
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
    public static final String TYPE_FIELD = "type";
    public static final String DISABLED_FIELD = "disabled";
    public static final String PARENT_LIST_FIELD = "parent_list";

    public static final String[] PROJECT_LIST_FRAGMENT_PROJECTION = new String[]{Project._ID,
            GUID_FIELD, NAME_FIELD, OWNER_FIELD, LAST_EDIT_DATE_FIELD, DISABLED_FIELD, TYPE_FIELD
    };
    public static final String PROJECT_LIST_FRAGMENT_WHERE = DISABLED_FIELD + " = 0 ";

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

    @SerializedName(TYPE_FIELD)
    @DatabaseField(columnName = TYPE_FIELD)
    private int type;

    @SerializedName(DISABLED_FIELD)
    @DatabaseField(columnName = DISABLED_FIELD)
    private boolean disabled;

    @DatabaseField(foreign = true, columnName = PARENT_LIST_FIELD)
    private ProjectsCollection parentList;

    public Project() {
    }

    public Project(String name, String guid) {
        this.name = name;
        this.guid = guid;
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
        return String.format(Constants.API.GET_PROJECT_RESOURCE, guid);
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
                ", owner='" + owner + '\'' +
                '}';
    }

    public static String getSortOrder(SortType type) {
        String column = NAME_FIELD;
        String sortOrder = Constants.Direction.ASC;
        switch (type) {
            case BY_NAME:
                break;
            case BY_CREATION_DATE: {
                column = CREATED_DATE_FIELD;
                sortOrder = Constants.Direction.DESC;
                break;
            }
            case BY_MODIFY_DATE: {
                column = LAST_EDIT_DATE_FIELD;
                sortOrder = Constants.Direction.DESC;
                break;
            }
        }
        return String.format(Locale.US, "%s %s", column, sortOrder);
    }
}
