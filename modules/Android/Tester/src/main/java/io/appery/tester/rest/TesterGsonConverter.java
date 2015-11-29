package io.appery.tester.rest;

import com.google.gson.Gson;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.lang.reflect.Type;

import retrofit.converter.ConversionException;
import retrofit.converter.GsonConverter;
import retrofit.mime.TypedInput;
import retrofit.mime.TypedOutput;

/**
 * Created by Alexandr.Salin on 11/29/15.
 */
public class TesterGsonConverter extends GsonConverter {
    private static final Logger logger = LoggerFactory.getLogger(TesterGsonConverter.class);

    public TesterGsonConverter() {
        super(new Gson());
    }

    @Override
    public Object fromBody(TypedInput body, Type type) throws ConversionException {
        logger.warn("START CONVERT FROM BODY");
        return super.fromBody(body, type);
    }

    @Override
    public TypedOutput toBody(Object object) {
        logger.warn("START CONVERT TO BODY");
        return super.toBody(object);
    }
}
