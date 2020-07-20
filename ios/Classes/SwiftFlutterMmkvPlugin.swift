import Flutter
import UIKit
import MMKV

let DEFAULT_MMAP_ID = "mmkv.default"

public class SwiftFlutterMmkvPlugin: NSObject, FlutterPlugin {
    private var instances:[String:MMKV]=[:]
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "plugin.waibibabo.com/flutter_mmkv", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterMmkvPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            let args = call.arguments as! Dictionary<String, AnyObject>
            let rootDir = args["rootDir"] as? String
            result(MMKV.initialize(rootDir: rootDir))
        case "getRootDir":
            result(MMKV.mmkvBasePath())
        case "pageSize":
            result(0)
        case "onExit":
            MMKV.onAppTerminate()
            result(nil)
        case "encode":
            let kv = instance(call)
            let args = call.arguments as! Dictionary<String, AnyObject>
            let key = args["key"] as! String
            let value = args["value"]
            var flg = false
            switch value {
            case let v as Int32:
                flg = kv.set(v, forKey: key)
            case let v as Int64:
                flg = kv.set(v, forKey: key)
            case let v as Bool:
                flg = kv.set(v, forKey: key)
            case let v as Double:
                flg = kv.set(v, forKey: key)
            case let v as String:
                flg = kv.set(v, forKey: key)
            case let v as FlutterStandardTypedData:
                flg = kv.set(v.data,forKey: key)
            default: break
            }
            result(flg)
        case "decodeString":
            let v = decode(call) {
                (kv,key,defaultValue) -> String? in
                kv.string(forKey: key, defaultValue: defaultValue)
            }
            result(v)
        case "decodeInt":
            let v = decode(call) {
                (kv,key,defaultValue) -> Int32? in
                kv.int32(forKey: key, defaultValue: defaultValue ?? 0)
            }
            result(v)
        case "decodeDouble":
            let v = decode(call) {
                (kv,key,defaultValue) -> Double? in
                kv.double(forKey: key, defaultValue: defaultValue ?? 0.0)
            }
            result(v)
        case "decodeBool":
            let v = decode(call) {
                (kv,key,defaultValue) -> Bool? in
                kv.bool(forKey: key, defaultValue: defaultValue ?? false)
            }
            result(v)
        case "decodeBytes":
            let v = decode(call) {
                (kv,key,defaultValue) -> FlutterStandardTypedData? in
                let data = kv.data(forKey: key)
                if data == nil {
                    return defaultValue
                }
                return FlutterStandardTypedData.init(bytes: data!)
            }
            result(v)
        case "containsKey":
            result(instance(call).contains(key: getKey(call)))
        case "getValueSize","getValueActualSize":
            result(instance(call).valueSize(forKey: getKey(call)))
        case "removeValueForKey":
            instance(call).removeValue(forKey: getKey(call))
            result(nil)
        case "removeValuesForKeys":
            let args = call.arguments as! Dictionary<String, AnyObject>
            let keys = args["keys"] as! [String]
            instance(call).removeValues(forKeys: keys)
            result(nil)
        case "allKeys":
            result(instance(call).allKeys())
        case "count":
            result(instance(call).count())
        case "totalSize":
            result(instance(call).totalSize())
        case "clearAll":
            instance(call).clearAll()
            result(nil)
        case "trim":
            instance(call).trim()
            result(nil)
        case "clearMemoryCache":
            instance(call).clearMemoryCache()
            result(nil)
        case "close":
            let kv = instance(call)
            kv.close()
            let args = call.arguments as! Dictionary<String, AnyObject>
            var id = args["id"] as? String
            if id==nil { id=DEFAULT_MMAP_ID }
            instances.removeValue(forKey:id! )
            result(nil)
        default:
            result("iOS " + UIDevice.current.systemVersion)
        }
    }
    
    private func getKey(_ call:FlutterMethodCall) -> String{
        let args = call.arguments as! Dictionary<String, AnyObject>
        return args["key"] as! String
    }
    
    private func instance(_ call:FlutterMethodCall) -> MMKV{
        let args = call.arguments as! Dictionary<String, AnyObject>
        var id = args["id"] as? String
        if id==nil { id=DEFAULT_MMAP_ID }
        var kv:MMKV? = instances[id!]
        if kv != nil { return kv! }
        let cryptKey = args["cryptKey"] as? String
        var mode = args["mode"] as? Int
        if mode == nil { mode = 1}
        let m = mode==1 ? MMKVMode.singleProcess : MMKVMode.multiProcess
        kv = MMKV.init(mmapID: id!, cryptKey: cryptKey?.data(using: String.Encoding.utf8), mode: m)
        instances[id!]=kv
        return kv!
    }
    
    private func decode<T>(_ call:FlutterMethodCall,delegate:(MMKV,String,T?) -> T?) -> T?{
        let kv = instance(call)
        let args = call.arguments as! Dictionary<String, AnyObject>
        let key = args["key"] as! String
        let defaultValue = args["defaultValue"] as? T
        return delegate(kv,key,defaultValue)
    }
}
