package io.appery.tester.utils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

import org.jivesoftware.smack.XMPPException;

import android.util.Log;

/**
 * 
 * This class providing functionality for reading system Android logs and sending to xmpp server
 * 
 * @author Dmitry Tereshenko
 * 
 */

public class LogReader extends Thread {

    private final String[] LOGCAT_CMD = new String[] { "logcat", "io.appery.tester" };

    public static final String[] LOGCAT_CLEAR_CMD = new String[] { "logcat", "-c" };

    private final int BUFFER_SIZE = 1024;

    private Process mLogcatProc = null;

    private BufferedReader reader = null;

    private XMPPSender sender = null;

    public LogReader() {

    }

    @Override
    public void run() {

        try {
            mLogcatProc = Runtime.getRuntime().exec(LOGCAT_CMD);
        } catch (IOException e) {
            Log.i("LogReader", "Logcat process failed. " + e.getMessage());
            return;
        }

        try {

            readLog();

        } catch (IOException e) {
            Log.i("LogReader", "Logcat process error. " + e.getMessage());
        } catch (XMPPException e) {
            Log.i("LogReader", "Logcat process error. " + e.getMessage());
        } finally {

            if (sender.isConnected()) {
                sender.disconnect();
            }

            if (reader != null) {
                Log.i("LogReader", "reader.close()");
                try {
                    reader.close();
                } catch (IOException e) {
                }
            }
        }
    }

    public XMPPSender getSender() {
        return this.sender;
    }

    public void setXMPPConnection(String XMPPServer, int XMPPPort, Long userId, int projectId, String username)
            throws XMPPException {
        sender = new XMPPSender(XMPPServer, XMPPPort, userId, username);
        sender.login();
    }

    public void readLog() throws XMPPException, IOException {

        reader = new BufferedReader(new InputStreamReader(mLogcatProc.getInputStream()), BUFFER_SIZE);

        String line;
        while (!Thread.currentThread().isInterrupted() && (line = reader.readLine()) != null) {
            if (line.contains("AndroidXMPPMessaging") || line.contains("PhoneGapLog") || line.contains("Web Console")) {
                if (sender.isConnected()) {
                    sender.sendMessageToRoom(line);
                }
            }
        }
    }

    public void stopCollect() {
        Log.i("LogReader", "stopCollect");
        if (sender != null) {
            Log.i("LogReader", "Sender disconnect()");
            sender.disconnect();
        }

        if (mLogcatProc != null) {
            Log.i("LogReader", "mLogcatProc destroy()");
            mLogcatProc.destroy();
            mLogcatProc = null;
        }

        return;
    }

}
