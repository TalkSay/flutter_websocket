package io.talksay.flutter_websocket

import org.java_websocket.WebSocket
import org.java_websocket.client.WebSocketClient
import org.java_websocket.drafts.Draft_6455
import org.java_websocket.framing.Framedata
import org.java_websocket.handshake.ServerHandshake
import java.lang.Exception
import java.net.URI

open class JWebSocketClient(serverUri: URI?) : WebSocketClient(serverUri, Draft_6455()) {

    override fun onOpen(handshakedata: ServerHandshake?) {
    }

    override fun onWebsocketPong(conn: WebSocket?, f: Framedata?) {
        super.onWebsocketPong(conn, f)
    }


    override fun onMessage(message: String?) {
        if (message != null) {
        }
    }

    override fun onClose(code: Int, reason: String?, remote: Boolean) {
    }

    override fun onError(ex: Exception?) {
    }
}