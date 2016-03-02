package io.appery.tester.ui.projects.callback;

import io.appery.tester.db.entity.SortType;

/**
 * Created by Alexandr.Salin on 12/6/15.
 */
public interface SlaveCallback {
    void refresh();

    void updateSortList(SortType sortType);
}
