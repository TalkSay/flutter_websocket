package io.talksay.flutter_websocket


import android.os.Handler
import android.os.Looper
import android.util.Log
import org.java_websocket.handshake.ServerHandshake
import java.net.URI

/// socket Long connection service
object JWebSocketService {

    var client: JWebSocketClient? = null

    /**
     * Initialize the websocket connection
     */
    fun initSocketClient(
        url: String,
        success: (url: String) -> Unit,
        close: (code: Int, reason: String?, remote: Boolean) -> Unit,
        error: (message: String) -> Unit,
        doMessage: (message: String) -> Unit
    ) {
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

        }
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
    private val sendTime = (5 * 100).toLong()

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

}