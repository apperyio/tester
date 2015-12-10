package io.appery.tester;

import com.tojc.ormlite.android.OrmLiteSimpleContentProvider;
import com.tojc.ormlite.android.framework.MatcherController;
import com.tojc.ormlite.android.framework.MimeTypeVnd;

import io.appery.tester.db.DatabaseHelper;
import io.appery.tester.db.entity.Project;
import io.appery.tester.db.entity.ProjectsCollection;

/**
 * Created by Alexandr.Salin on 12/10/15.
 */
public class DatabaseProvider extends OrmLiteSimpleContentProvider<DatabaseHelper> {
    @Override
    protected Class<DatabaseHelper> getHelperClass() {
        return DatabaseHelper.class;
    }

    protected MatcherController matcherController;

    @Override
    public boolean onCreate() {
        matcherController = new MatcherController();
        initGeneral(matcherController);
        initCollection(matcherController);
        setMatcherController(matcherController.initialize());
        return true;
    }

    protected void initGeneral(MatcherController matcherController) {
        matcherController
                .add(Project.class, MimeTypeVnd.SubType.DIRECTORY, "", Project.CONTENT_URI_PATTERN_MANY)
                .add(Project.class, MimeTypeVnd.SubType.ITEM, "#", Project.CONTENT_URI_PATTERN_ONE);
    }

    protected void initCollection(MatcherController controller) {
        controller
                .add(ProjectsCollection.class, MimeTypeVnd.SubType.DIRECTORY, "", ProjectsCollection.CONTENT_URI_PATTERN_MANY)
                .add(ProjectsCollection.class, MimeTypeVnd.SubType.ITEM, "#", ProjectsCollection.CONTENT_URI_PATTERN_ONE);

    }
}

