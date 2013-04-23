package io.appery.tester.utils;

import io.appery.tester.data.Project;

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

    /**
     * Parse list of projects from JSon;<BR/>
     * Response Examples <BR/>
     * Multi:
     * <code>{"projects":[{"name":"Mercury","link":"http://localhost/17/mercury.apk"},{"name":"Venus","link":"http://localhost/18/venus.apk"},{"name":"Earth","link":"http://localhost/18/earth.apk"}]}</code>
     * <BR/>
     * Single: <code>{"projects":[{"name":"Mercury","link":"http://localhost/17/mercury.apk"}]}</code>
     * 
     * @param response
     * @return
     */
    public static List<Project> getProjects(String response) {
        List<Object> objList = parseListResponse(response, "projects");

        List<Project> projects = new ArrayList<Project>();

        for (Object obj : objList) {
            projects.add((Project) obj);
        }

        return projects;
    }

    private static final List<Object> parseListResponse(String response, String name) {
        List<Object> objList = new ArrayList<Object>();

        try {
            JSONObject json = new JSONObject(response);
            objList = getListFromJson(json, name);
        } catch (JSONException e) {
            Log.e("JsonParser", "Can't parse list responce", e);
        }

        return objList;
    }

    private static List<Object> getListFromJson(JSONObject json, String name) throws JSONException {
        List<Object> objList = new ArrayList<Object>();

        if (json.has(name)) {
            JSONArray jsonArr = getArrayOrObject(json, name); // Set JSON Array even if it is single object

            for (int i = 0; i < jsonArr.length(); i++) {
                JSONObject obj = (JSONObject) jsonArr.get(i);

                // Just for project
                objList.add(new Project(obj));
            }
        }

        return objList;
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
