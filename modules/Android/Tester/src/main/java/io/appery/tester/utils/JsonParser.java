package io.appery.tester.utils;

import io.appery.tester.db.entity.Project;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;

/**
 * @author Daniel Lukashevich
 */
public class JsonParser {

    public static List<Project> getProjects(String response) {
        List<Project> projects = new ArrayList<Project>();
        return projects;
    }

    private static JSONArray getArrayOrObject(JSONObject parent, String name) {
        // checking array
        JSONArray results = parent.optJSONArray(name);
        if (results == null) {
            // create empty array
            results = new JSONArray();
            // checking object
            JSONObject object = parent.optJSONObject(name);
            if (object != null) {
                // add object to the array
                results.put(object);
            }
        }
        // return array
        return results;
    }

}
