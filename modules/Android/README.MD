install android ыsdk

cd sdk/platforms/android-17
mvn install:install-file -Dfile=android.jar -DgroupId=com.google.android -DartifactId=android -Dversion=4.2.2_r3 -Dpackaging=jar
