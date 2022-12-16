package io.talksay.flutter_websocket


import android.os.Handler
import android.os.Looper
import android.util.Log
import org.java_websocket.WebSocket
import org.java_websocket.framing.Framedata
import org.java_websocket.framing.PingFrame
import org.java_websocket.handshake.ServerHandshake
import java.net.URI
import java.nio.ByteBuffer


/// socket Long connection service
object JWebSocketService {

    var client: JWebSocketClient? = null


    /**
     * Initialize the websocket connection
     */
    fun initSocketClient(
        url: String,
        connectionTimeout: Int,
        success: (url: String) -> Unit,
        close: (code: Int, reason: String?, remote: Boolean) -> Unit,
        error: (message: String) -> Unit,
        doMessage: (message: String) -> Unit
    ) {
//        var header: HashMap<String, String> = HashMap<String, String>()
//        header["Upgrade"] = "websocket"
//        header["Sec-WebSocket-Extensions"] = "permessage-deflate; client_max_window_bits"
        Log.d("FlutterWebsocketPlugin", "Whether the client is empty:${client == null}")
        if (client != null) {
            if (client!!.isOpen) {
                Log.d(
                    FlutterWebsocketPlugin::class.java.simpleName,
                    "Already connected, if you need to reconnect, please disconnect first"
                )
                return
            }
        }
        Log.d(FlutterWebsocketPlugin::class.java.simpleName, "connecting...")
        val uri = URI.create(url)
//        client.addHeader()
//        client?.addHeader("Pragma", "no-cache")
//        client?.addHeader("Origin", " https://dev.talksay.live")
//        client?.addHeader("Accept-Encoding", "gzip, deflate, br")
//        client?.addHeader("Accept-Language", "en-US,en;q=0.8,zh-CN;q=0.6,zh;q=0.4")
//        client?.addHeader("Upgrade", "websocket")
//        client?.addHeader("Cache-Control", "no-cache");
//        client?.addHeader("Connection", "Upgrade");
//        client?.addHeader("Sec-WebSocket-Version", "13");
//        client?.addHeader("Sec-WebSocket-Extensions", "permessage-deflate; client_max_window_bits")
        client = object : JWebSocketClient(uri) {
            override fun onMessage(message: String?) {
                if (message != null) {
                    // Log.d(FlutterWebsocketPlugin::class.java.simpleName, "Message: $message")
                    doMessage(message)
                }
            }

            override fun onOpen(handshakedata: ServerHandshake?) {

                success(url)
            }

            override fun onClose(code: Int, reason: String?, remote: Boolean) {
                close(code, reason, remote)
            }

            override fun onError(ex: Exception?) {
                if (ex != null) {
                    error(ex.toString())
                } else {
                    error("Connection failed: unknown reason")
                }
            }

             override fun onPreparePing(conn: WebSocket?): PingFrame {
//                 return super.onPreparePing(conn)
                 val frame = PingFrame()
                 val pingBuffer = byteArrayOf()
                 frame.setPayload(ByteBuffer.wrap(pingBuffer))
                 return frame;
             }

            override fun onWebsocketPing(conn: WebSocket?, f: Framedata?) {
                Log.d(FlutterWebsocketPlugin::class.java.simpleName, ">>WE ARE PING<<:")
                super.onWebsocketPing(conn, f)
            }

            override fun onWebsocketPong(conn: WebSocket?, f: Framedata?) {
                f?.toString()?.let { Log.d(FlutterWebsocketPlugin::class.java.simpleName, it) }
//                val frame = PingFrame()
//                val pingBuffer = byteArrayOf()
//                frame.setPayload(ByteBuffer.wrap(pingBuffer))
//                conn?.sendFrame(frame)
//                super.onWebsocketPong(conn, f)
            }
        }
//        client.draft.
//        client.sendPing()

        client?.connectionLostTimeout = connectionTimeout;
        connect()
    }

    /**
     * connect websocket
     */
    private fun connect() {
        object : Thread() {
            override fun run() {
                try {
                    // connectBlocking has one more waiting operation, it will connect first and then send,
                    // otherwise an error will be reported if the connection is not sent
                    client?.connectBlocking()
                } catch (e: InterruptedException) {
                    e.printStackTrace()
                }
            }
        }.start()
    }

    /**
     * open heartbeat
     */
    fun openHeart() {
        Log.d("JWebSocketService", "open heartbeat.")
        mHandler.postDelayed(heartBeatRunnable, sendTime) // open heartbeat
    }

    /**
     * turn off heartbeat
     */
    fun closeHeart() {
        Log.d("JWebSocketService", "turn off heartbeat.")
        mHandler.removeCallbacks(heartBeatRunnable)
    }

    // heartbeat interval
    // TODO extract the interval time to be configurable
    private const val sendTime = (5 * 1000).toLong()

    // thread
    private val mHandler: Handler = Handler(Looper.getMainLooper())
//    private val mHandler: Handler = Handler() // TODO PATRICK -> check this out

    // perform tasks
    private val heartBeatRunnable: Runnable = object : Runnable {
        override fun run() {
            if (client != null) {
                if (client!!.isClosed) {
                    reconnectWs()
                }
//                else{
////                    client!!.sendPing();
//                }
            }
            mHandler.postDelayed(this, sendTime)
        }
    }

    /**
     * Send a message
     */

    fun send(message: String) {
        if (client != null && client!!.isOpen) {
            client!!.send(message)
        }
    }

    /**
     * enable reconnection
     */
    private fun reconnectWs() {

        mHandler.removeCallbacks(heartBeatRunnable)
        object : Thread() {
            override fun run() {
                try {
                    Log.e("JWebSocketClientService", "enable reconnection")
                    client?.reconnectBlocking()
                } catch (e: InterruptedException) {
                    e.printStackTrace()
                }
            }
        }.start()
    }

    /**
     * actively disconnect
     */
    fun closeConnect() {
        closeHeart()
        try {
            client?.close()
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            client = null
        }

    }

    fun sendPing() {
        try {
            val frame = PingFrame()
            val pingBuffer = byteArrayOf()
            frame.setPayload(ByteBuffer.wrap(pingBuffer))
            frame.toString().let { Log.d(FlutterWebsocketPlugin::class.java.simpleName, it) }
            client?.sendFrame(frame)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

}