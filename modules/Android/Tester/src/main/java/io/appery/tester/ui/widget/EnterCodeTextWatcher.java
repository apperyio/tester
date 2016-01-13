package io.appery.tester.ui.widget;

import android.text.Editable;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.View;
import android.widget.EditText;

/**
 * Created by ayakovenko on 05.01.16.
 */
public class EnterCodeTextWatcher implements TextWatcher {

    EditText mEditText;
    boolean mInside = false;
    boolean mWannaDeleteHyphen = false;
    boolean mKeyListenerSet = false;
    final static String MARKER = "|"; // filtered in layout not to be in the string

    public EnterCodeTextWatcher(EditText editText) {
        mEditText = editText;
    }

    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) {
        if (!mKeyListenerSet) {
            mEditText.setOnKeyListener(new View.OnKeyListener() {
                @Override
                public boolean onKey(View v, int keyCode, KeyEvent event) {
                    try {
                        mWannaDeleteHyphen = (keyCode == KeyEvent.KEYCODE_DEL
                                && mEditText.getSelectionEnd() - mEditText.getSelectionStart() <= 1
                                && mEditText.getSelectionStart() > 0
                                && mEditText.getText().toString().charAt(mEditText.getSelectionEnd() - 1) == '-');
                    } catch (IndexOutOfBoundsException e) {
                        // never to happen because of checks
                    }
                    return false;
                }
            });
            mKeyListenerSet = true;
        }
    }

    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {
        if (mInside) // to avoid recursive calls
            return;
        mInside = true;

        int currentPos = mEditText.getSelectionStart();
        String string = mEditText.getText().toString().toUpperCase();
        String newString = makePrettyString(string);

        mEditText.setText(newString);
        try {
            mEditText.setSelection(getCursorPos(string, newString, currentPos, mWannaDeleteHyphen));
        } catch (IndexOutOfBoundsException e) {
            mEditText.setSelection(mEditText.length()); // last resort never to happen
        }

        mWannaDeleteHyphen = false;
        mInside = false;
    }

    @Override
    public void afterTextChanged(Editable s) {
    }

    private String makePrettyString(String string) {
        String number = string.replaceAll("-", "");
        boolean isEndHyphen = string.endsWith("-") && (number.length() % 3 == 0);
        return number.replaceAll("(.{3}(?!$))", "$1-") + (isEndHyphen ? "-" : "");
    }

    private int getCursorPos(String oldString, String newString, int oldPos, boolean isDeleteHyphen) {
        int cursorPos = newString.length();
        if (oldPos != oldString.length()) {
            String stringWithMarker = oldString.substring(0, oldPos) + MARKER + oldString.substring(oldPos);

            cursorPos = (makePrettyString(stringWithMarker)).indexOf(MARKER);
            if (isDeleteHyphen)
                cursorPos -= 1;
        }
        return cursorPos;
    }
}
