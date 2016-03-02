package io.appery.tester.db.entity;

import android.content.ContentResolver;
import android.net.Uri;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.field.ForeignCollectionField;
import com.j256.ormlite.table.DatabaseTable;
import com.tojc.ormlite.android.annotation.AdditionalAnnotation;

import java.util.ArrayList;
import java.util.Collection;

import io.appery.tester.db.Contract;

/**
 * Created by Alexandr.Salin on 12/8/15.
 */
@DatabaseTable(tableName = ProjectsCollection.TABLENAME)
@AdditionalAnnotation.DefaultContentUri(authority = Contract.AUTHORITY, path = ProjectsCollection.CONTENT_URI_PATH)
@AdditionalAnnotation.DefaultContentMimeTypeVnd(name = ProjectsCollection.MIMETYPE_NAME, type = ProjectsCollection.MIMETYPE_TYPE)
public class ProjectsCollection extends ArrayList<Project> implements Entity, SpiceCollection {
    public static final String TABLENAME = "ProjectsCollection";
    public static final String CONTENT_URI_PATH = TABLENAME;
    public static final String MIMETYPE_TYPE = TABLENAME;
    public static final String MIMETYPE_NAME = Contract.AUTHORITY + ".provider";
    public static final int CONTENT_URI_PATTERN_MANY = 4071;
    public static final int CONTENT_URI_PATTERN_ONE = 4072;
    public static final Uri contentUri = new Uri.Builder().scheme(ContentResolver.SCHEME_CONTENT).authority(Contract.AUTHORITY).appendPath(CONTENT_URI_PATH).build();
    //Fields
    public static final String COLLECTION_FIELD = "media_response_collection";

    @DatabaseField(columnName = ProjectsCollection._ID, allowGeneratedIdInsert = true, generatedId = true)
    private int _id;

    @ForeignCollectionField(eager = true, columnName = COLLECTION_FIELD)
    private Collection<Project> items = this;

    public Collection<Project> getItems() {
        return items;
    }

    public void setItems(Collection<Project> result) {
        if (result != null) {
            this.clear();
            this.addAll(result);
        }
    }

    public ProjectsCollection() {
    }

    @Override
    public void initList() {
        addAll(items);
    }

    @Override
    public String toString() {
        return "List{" +
                "id=" + _id +
                '}';
    }
}
