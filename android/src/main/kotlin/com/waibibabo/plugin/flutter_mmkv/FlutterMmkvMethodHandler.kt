package com.waibibabo.plugin.flutter_mmkv

import android.content.Context
import androidx.annotation.NonNull
import com.tencent.mmkv.MMKV
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.collections.HashMap

class FlutterMmkvMethodHandler(context: Context) : MethodChannel.MethodCallHandler {

    private var context: Context = context
    private var instances: HashMap<String, MMKV> = hashMapOf()
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                var rootDir = call.argument<String>("rootDir")
                rootDir = if (rootDir == null)
                    MMKV.initialize(context)
                else
                    MMKV.initialize(rootDir)
                result.success(rootDir)
            }
            "onExit" -> {
                MMKV.onExit()
                result.success(null)
            }
            "getRootDir" -> {
                result.success(MMKV.getRootDir())
            }
            "pageSize" -> {
                result.success(MMKV.pageSize())
            }
            "encode" -> {
                val kv = instance(call)
                val key = call.argument<String>("key")!!
                var flg = false
                when (val value = call.argument<Any>("value")!!) {
                    is String -> flg = kv.encode(key, value)
                    is Int -> flg = kv.encode(key, value)
                    is Long -> flg = kv.encode(key, value)
                    is Double -> flg = kv.encode(key, value)
                    is Boolean -> flg = kv.encode(key, value)
                    is ByteArray -> flg = kv.encode(key, value)
                }
                result.success(flg)
            }
            "decodeString" -> {
                val v = decode<String>(call) { kv, key, defaultValue ->
                    kv.decodeString(key, defaultValue)
                }
                result.success(v)
            }
            "decodeInt" -> {
                val v = decode<Int>(call) { kv, key, defaultValue ->
                    kv.decodeInt(key, defaultValue ?: 0)
                }
                result.success(v)
            }
            "decodeDouble" -> {
                val v = decode<Double>(call) { kv, key, defaultValue ->
                    kv.decodeDouble(key, defaultValue ?: 0.0)
                }
                result.success(v)
            }
            "decodeBool" -> {
                val v = decode<Boolean>(call) { kv, key, defaultValue ->
                    kv.decodeBool(key, defaultValue ?: false)
                }
                result.success(v)
            }
            "decodeBytes" -> {
                val v = decode<ByteArray>(call) { kv, key, defaultValue ->
                    kv.decodeBytes(key, defaultValue)
                }
                result.success(v)
            }
            "containsKey" -> {
                result.success(instance(call).containsKey(call.argument<String>("key")!!))
            }
            "getValueSize" -> {
                result.success(instance(call).getValueSize(call.argument<String>("key")!!))
            }
            "getValueActualSize" -> {
                result.success(instance(call).getValueActualSize(call.argument<String>("key")!!))
            }
            "removeValueForKey" -> {
                instance(call).removeValueForKey(call.argument<String>("key")!!)
                result.success(null)
            }
            "removeValuesForKeys" -> {
                var keys = call.argument<List<String>>("keys")!!
                instance(call).removeValuesForKeys(keys?.toTypedArray())
                result.success(null)
            }
            "allKeys" -> {
                val keys = instance(call).allKeys()
                result.success(keys?.toList<String>())
            }
            "count" -> {
                result.success(instance(call).count())
            }
            "totalSize" -> {
                result.success(instance(call).totalSize())
            }
            "clearAll" -> {
                instance(call).clearAll()
                result.success(null)
            }
            "trim" -> {
                instance(call).trim()
                result.success(null)
            }
            "close" -> {
                var kv = instance(call)
                kv.close()
                var id = call.argument<String>("id")
                if (id == null) id = "default"
                instances.remove(id)
                result.success(null)
            }
            "clearMemoryCache" -> {
                instance(call).clearMemoryCache()
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun instance(@NonNull call: MethodCall): MMKV {
        var id = call.argument<String>("id")
        if (id == null) id = "default"
        println("get mmkv id:${id} callMethod:${call.method}")
        var kv: MMKV? = instances[id]
        if (kv != null) return kv
        println("init mmkv id:${id} callMethod:${call.method}")
        var mode = call.argument<Int>("mode")
        if (mode == null) mode = 1
        val cryptKey = call.argument<String>("cryptKey")
        kv = if (id == "default")
            MMKV.defaultMMKV(mode, cryptKey)
        else MMKV.mmkvWithID(id, mode, cryptKey)
        instances[id] = kv
        return kv
    }

    private fun <T> decode(@NonNull call: MethodCall, delegate: (kv: MMKV, key: String, defaultValue: T?) -> T?): T? {
        val kv = instance(call)
        val key = call.argument<String>("key")!!
        var defaultValue = call.argument<T>("defaultValue")
        return delegate(kv, key, defaultValue)
    }
}