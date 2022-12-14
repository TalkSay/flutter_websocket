package io.talksay.flutter_websocket


import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import org.java_websocket.handshake.ServerHandshake
import java.net.URI

/// socket Long connection service
class JWebSocketService : Service() {


    var client: JWebSocketClient? = null

    //gray keep alive
    class GrayInnerService : Service() {
        override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
            startForeground(1001, Notification())
            stopForeground(true)
            stopSelf()
            return super.onStartCommand(intent, flags, startId)
        }

        override fun onBind(intent: Intent): IBinder? {
            return null
        }
    }


    override fun onCreate() {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel("myService", "Version Update Service Notice", NotificationManager.IMPORTANCE_DEFAULT)
            manager.createNotificationChannel(channel)
        }
        val intent = Intent(this, FlutterWebsocketPlugin::class.java)
        val pi = PendingIntent.getActivity(this, 0, intent, 0)
        val notification = NotificationCompat.Builder(this, "myService")
            .setContentTitle("hi")
            .setContentText("hello")
            .setContentIntent(pi)
            .setAutoCancel(false)
            .build()
        startForeground(1001, notification)
        super.onCreate()
    }


    override fun onBind(p0: Intent?): IBinder {
        return JWebSocketClientBinder()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(JWebSocketService::class.java.simpleName, "service started:onStartCommand")
        return START_STICKY
    }

    override fun onDestroy() {
        Log.d(JWebSocketService::class.java.simpleName, "service process was killed")
        super.onDestroy()
    }

    /**
     * Initialize the websocket connection
     */
    fun initSocketClient(url: String,
                         success: (url: String) -> Unit,
                         close: (code: Int, reason: String?, remote: Boolean) -> Unit,
                         error: (message: String) -> Unit,
                         doMessage: (message: String) -> Unit) {
        Log.d("FlutterWebsocketPlugin","Whether the client is empty:${client==null}")
        if(client!=null){
            if(client!!.isOpen){
                Log.d(FlutterWebsocketPlugin::class.java.simpleName, "Already connected, if you need to reconnect, please disconnect first")
                return
            }
        }
        Log.d(FlutterWebsocketPlugin::class.java.simpleName, "connecting...")
        val uri = URI.create(url)
        client = object : JWebSocketClient(uri) {
            override fun onMessage(message: String?) {
                if (message != null) {
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
    private val sendTime = (30 * 1000).toLong()

    // thread
    private val mHandler: Handler = Handler(Looper.getMainLooper()) // TODO PATRICK -> check this out

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