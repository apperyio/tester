package io.appery.tester.utils;

/**
 * Created by Maxim Balyaba on 13.07.2015.
 */
public class NoProjectSourceException extends RuntimeException {

    private Integer errorCode;

    public NoProjectSourceException() {
    }

    public NoProjectSourceException(Integer errorCode) {
        this.errorCode = errorCode;
    }

    public NoProjectSourceException(String detailMessage) {
        super(detailMessage);
    }

    public NoProjectSourceException(String detailMessage, Throwable throwable) {
        super(detailMessage, throwable);
    }

    public NoProjectSourceException(Throwable throwable) {
        super(throwable);
    }

    public Integer getErrorCode() {
        return errorCode;
    }
}
