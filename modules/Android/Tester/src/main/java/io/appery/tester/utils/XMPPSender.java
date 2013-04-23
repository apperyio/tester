package io.appery.tester.utils;

import io.appery.tester.utils.Base64;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.IOException;

import org.jivesoftware.smack.ConnectionConfiguration;
import org.jivesoftware.smack.XMPPConnection;
import org.jivesoftware.smack.XMPPException;
import org.jivesoftware.smackx.muc.MultiUserChat;

import android.util.Log;

/**
 * 
 * This class provide XMPP conversation functionality
 * 
 * @author Dmitry Tereshenko
 * 
 */

public class XMPPSender {

    private XMPPConnection connection = null;

    private MultiUserChat muc = null;

    private String login;

    private String password;

    private String server;

    private String username;

    private boolean joined = false;

    public XMPPSender(String server, int port, Long userId, String username) throws XMPPException {

        this.login = "tiggruser_" + userId;
        this.password = "pass" + userId;
        this.server = server;
        this.username = username;

        ConnectionConfiguration config = new ConnectionConfiguration(server, port);
        connection = new XMPPConnection(config);
        connection.connect();
        Log.i("AndroidXMPPMessaging", "Connection established");
    }

    /**
     * Login at xmpp server
     * 
     * @throws XMPPException
     */
    public void login() throws XMPPException {

        connection.login(login, password);

    }

    /**
     * Disconnect from xmpp server
     */
    public void disconnect() {

        // leave room before disconnecting
        leaveRoom();
        connection.disconnect();

        // Patch for valid reusing XMPPConnection
        XMPPConnection.removeConnectionCreationListeners();

        connection = null;
    }

    /**
     * Join to the project room
     * 
     * @param projectId
     *            Id of the opened project
     * @throws XMPPException
     */
    public void joinToRoom(int projectId) throws XMPPException {

        // Open project room
        String room = "tiggrproject_" + projectId + "@conference." + server;
        muc = new MultiUserChat(connection, room);

        // replace all '@' with \40 symbol ( According to XMPP protocol )
        username = username.replaceAll("(.+)@(.+)", "$1\\\\40$2");
        String nickname = "Android\\20Device\\20\\20" + username + "\\20";

        // Join to project room
        muc.join(nickname, password);
        joined = true;
        Log.i("AndroidXMPPMessaging", "Join to room " + nickname);
    }

    /**
     * Checks is the user joined to the room
     * 
     * @return true if user is joined to room
     */
    public boolean isJoined() {
        return this.joined;
    }

    /**
     * Send message to project room
     * 
     * @param message
     *            - body of message for sending
     * @throws XMPPException
     * @throws IOException
     */
    public void sendMessageToRoom(String message) throws XMPPException, IOException {

        ByteArrayOutputStream ba = new ByteArrayOutputStream();
        DataOutputStream dos = new DataOutputStream(ba);

        // Write type of the message ( 3 = DEBUG_MESSAGE )
        dos.writeInt(3);
        byte[] byteMessage = message.getBytes("UTF8");

        // Write length of the message
        dos.writeInt(byteMessage.length);
        dos.write(byteMessage);
        dos.flush();

        String base64str = new String(Base64.encodeBytes(ba.toByteArray()));
        muc.sendMessage(base64str);

        dos.close();
        ba.close();

    }

    public boolean isConnected() {
        if (connection != null && connection.isConnected()) {
            return true;
        }

        return false;
    }

    /**
     * Leave project room
     */
    public void leaveRoom() {
        Log.i("AndroidXMPPMessaging", "Leave room");
        try {
            muc.leave();
            this.joined = false;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
