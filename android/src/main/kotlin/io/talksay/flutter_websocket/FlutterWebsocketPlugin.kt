package io.talksay.flutter_websocket

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.google.gson.Gson

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterWebsocketPlugin */
class FlutterWebsocketPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var context: Context
    private lateinit var activity: Activity
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel

    // gson instant
    private val gson: Gson = Gson()

    // global variables
    private val methodChannelName = "flutter_websocket_method"
    private val eventChannelName = "flutter_websocket_event"
    private lateinit var sinks: EventChannel.EventSink
    private val sinksThread: Handler = Handler(Looper.getMainLooper())

    // web-socket related instances
    private var service: JWebSocketService? = null

    //    private lateinit var binder: JWebSocketClientBinder
//    private lateinit var serviceConnect: ServiceConnection
    private lateinit var client: JWebSocketClient


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, methodChannelName)
        channel.setMethodCallHandler(this)
        // initialize context
        context = flutterPluginBinding.applicationContext
        // set event channel and add stream handler
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, eventChannelName)
        eventChannel.setStreamHandler(eventStream)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "connect" -> {
                val url = call.argument<String>("url")
                val connectionTimeout = call.argument<Int>("connectionTimeout")
                if (url != null && connectionTimeout != null) {
                    Log.d(
                        FlutterWebsocketPlugin::class.java.simpleName,
                        "Initialize connection:$url"
                    )
                    service = JWebSocketService;
                    connect(url, connectionTimeout)
//                    onStartConnectService(url)
                }
            }
            "sendPing" -> {
                service?.sendPing()
            }
            "closeConnect" -> {
                service?.closeConnect()
            }
            "openHeart" -> {
                if (service != null) {
                    if (isOpen()) {
                        service!!.openHeart()
                    } else {
                        Log.d(
                            FlutterWebsocketPlugin::class.java.simpleName,
                            "please connect first socket"
                        )
                    }
                } else {
                    Log.d(
                        FlutterWebsocketPlugin::class.java.simpleName,
                        "please connect first socket"
                    )
                }

            }
            "closeHeart" -> {
                if (service != null) {
                    if (isOpen()) {
                        Log.d("11111111111", "disconnect heartbeat");
                        service!!.closeHeart()
                    }
                }
            }
            "send" -> {
                val message = call.argument<String>("message")
                if (message != null) {
                    service?.send(message)
                } else {
                    Log.d(FlutterWebsocketPlugin::class.java.simpleName, "The message is null");
                }
            }
            "isOpen" -> {
                result.success(isOpen())
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    // Is it already connected
    private fun isOpen(): Boolean {
        var res = false
        if (service != null) {
            if (service!!.client != null) {
                res = service!!.client!!.isOpen
            }
        }
        return res
    }

    // start service
//    private fun onStartConnectService(url: String) {
//        try {
//            service = JWebSocketService;
//            connect(url)
////            serviceConnect = object : ServiceConnection {
////                override fun onServiceConnected(p0: ComponentName?, p1: IBinder?) {
////                    Log.d(
////                        FlutterWebsocketPlugin::class.java.simpleName,
////                        "on service connected triggered"
////                    );
////                    // Plugin and service binding
////                    if (p1 != null) {
////                        binder = p1 as JWebSocketClientBinder
////                        service = binder.getService()
////                        connect(url)
////                    } else {
////                        Log.d(FlutterWebsocketPlugin::class.java.simpleName, "IBinder is null");
////                    }
////                }
////
////                override fun onServiceDisconnected(p0: ComponentName?) {
////                    // destroy
////                }
////
////            }
//
////            bindService()
//        } catch (e: Exception) {
//            Log.d(FlutterWebsocketPlugin::class.java.simpleName, e.toString())
//        }
//    }

    // connect
    private fun connect(socketUrl: String, connectionTimeout: Int) {
        service?.initSocketClient(
            socketUrl,
            connectionTimeout,
            { url -> connectSuccess(url) },
            { code, reason, remote -> connectClose(code, reason, remote) },
            { message: String -> connectError(message) }) { message: String ->
            connectMessage(message)
        }
        client = service?.client!!
    }


    // socket connection success event
    private fun connectSuccess(url: String) {
        val result = SinksResult("connectSuccess", url)
        sendToFlutter(gson.toJson(result))
    }

    // socket connection closed event
    private fun connectClose(code: Int, reason: String?, remote: Boolean) {
        var msg = "unknown reason"
        if (reason != null) {
            msg = reason
        }
        val errorResult = SinksResultWithConnectError(code, msg, remote)
        val errorStr = gson.toJson(errorResult)
        val result = SinksResult("connectClose", errorStr)
        sendToFlutter(gson.toJson(result))
    }

    // socket connection failure event
    private fun connectError(message: String) {
        val result = SinksResult("connectError", message)
        sendToFlutter(gson.toJson(result))
    }

    // socket message event received
    private fun connectMessage(message: String) {
        val result = SinksResult("connectMessage", message)
        sendToFlutter(gson.toJson(result))
    }

    // Binding service
//    private fun bindService() {
//        try {
//            context.bindService(
//                Intent(context, JWebSocketService::class.java),
//                serviceConnect,
//                Service.BIND_AUTO_CREATE
//            )
//        } catch (e: Exception) {
//            Log.d(FlutterWebsocketPlugin::class.java.simpleName, e.toString())
//        }
//    }

    // Send data back to flutter as json String
    private fun sendToFlutter(json: String) {
        sinksThread.post {
            sinks.success(json)
        }
    }

    private val eventStream: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            if (events != null) {
                sinks = events
            }
        }

        override fun onCancel(arguments: Any?) {
            // channel is destroyed
        }

    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        // TODO reattach
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {

    }
}
