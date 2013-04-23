package io.appery.tester.comparators;

import io.appery.tester.data.Project;

import java.util.Comparator;

public class ProjectComparator implements Comparator<Project> {

    public static final int ASC = 1;

    public static final int DESC = -1;

    public static final int BY_NAME = 1;

    public static final int BY_DATE = 2;

    private int sortBy = BY_NAME;

    private int direction = ASC;

    public ProjectComparator(int sortBy, int direction) {
        this.sortBy = sortBy;
        this.direction = direction;
    }

    private int doCompare(Project p1, Project p2) {

        if ((p1 == null) && (p2 == null)) {
            return 0;
        }

        if ((p1 == null) && (p2 != null)) {
            return -1;
        }

        if ((p1 != null) && (p2 == null)) {
            return 1;
        }

        if (sortBy == BY_NAME) {

            if ((p1.getName() == null) && (p2.getName() == null)) {
                return 0;
            }

            if (p1.getName() == null) {
                return -1;
            }

            return p1.getName().compareToIgnoreCase(p2.getName());

        } else if (sortBy == BY_DATE) {

            if ((p1.getLastEditDate() == null) && (p2.getLastEditDate() == null)) {
                return 0;
            }

            if (p1.getLastEditDate() == null) {
                return -1;
            }

            return p1.getLastEditDate().compareTo(p2.getLastEditDate());

        }

        return 0;
    }

    @Override
    public int compare(Project p1, Project p2) {
        return doCompare(p1, p2) * direction;
    }

}
