import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_mmkv/flutter_mmkv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MMKV.initialize();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String rootDir = '';
  int pageSize = 0;

  var _kv = MMKV.defaultMMKV(cryptKey: "heihei");

  var _nameKv = MMKV.mmkvWithID(id: 'named');

  var key = '';
  var value = '';

  var _kvIndex = 0;

  @override
  void initState() {
    super.initState();
    initValue();
  }

  initValue() async {
    rootDir = await MMKV.rootDir;

    pageSize = await MMKV.pageSize;

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                // mmkv will exit
                MMKV.onExit();
              },
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text('rootDir'),
                subtitle: Text(rootDir ?? ''),
              ),
              ListTile(
                title: Text('pageSize'),
                subtitle: Text(pageSize.toString()),
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: RadioListTile<int>(
                      value: 0,
                      groupValue: _kvIndex,
                      onChanged: _radioChange,
                      title: Text('default'),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: RadioListTile<int>(
                      value: 1,
                      groupValue: _kvIndex,
                      onChanged: _radioChange,
                      title: Text('named'),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: TextField(
                      decoration: InputDecoration(labelText: 'key'),
                      onChanged: (v) => key = v,
                    ),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    flex: 1,
                    child: TextField(
                      decoration: InputDecoration(labelText: 'value'),
                      onChanged: (v) => value = v,
                    ),
                  )
                ],
              ),
              Wrap(
                spacing: 4,
                children: <Widget>[
                  RaisedButton(
                    child: Text('添加'),
                    onPressed: () async {
                      await kv.encodeString(key, value);
                      _getAll();
                    },
                  ),
                  RaisedButton(
                    child: Text('删除'),
                    onPressed: () async {
                      await kv.removeValueForKey(key);
                      //await kv.clearMemoryCache();
                      _getAll();
                    },
                  ),
                  RaisedButton(
                    child: Text('添加其它类型'),
                    onPressed: () async {
                      await kv.encodeBool('bool', true);
                      await kv.encodeDouble('double', math.pi);
                      await kv.encodeBytes('bytes', Uint8List.fromList([1, 2]));
                      await kv.encodeInt('int', 233);
                      await kv.encodeInt(
                          'time', DateTime.now().millisecondsSinceEpoch);
                      _getAll();
                    },
                  ),
                  RaisedButton(
                    child: Text('多key删除'),
                    onPressed: () async {
                      await kv.removeValuesForKeys(
                          ['time', 'bytes', 'int', 'bool', 'double']);
                      _getAll();
                    },
                  ),
                  RaisedButton(
                    child: Text('清空'),
                    onPressed: () async {
                      await kv.clearAll();
                      _getAll();
                    },
                  ),
                  RaisedButton(
                    child: Text('关闭'),
                    onPressed: () async {
                      await kv.close();
                    },
                  ),
                  RaisedButton(
                    child: Text('trim'),
                    onPressed: () async {
                      await kv.trim();
                    },
                  ),
                  RaisedButton(
                    child: Text('clearMemoryCache'),
                    onPressed: () async {
                      await kv.clearMemoryCache();
                    },
                  ),
                ],
              ),
              RaisedButton(
                child: Text('获取全部'),
                onPressed: _getAll,
              ),
              Text(_logText),
            ],
          ),
        ),
      ),
    );
  }

  MMKV get kv => _kvIndex == 0 ? _kv : _nameKv;

  var _logs = <String>[];

  var _logText = '';

  _getAll() async {
    _logs.clear();
    _logs.add('now: ' + DateTime.now().millisecondsSinceEpoch.toString());
    _logs.add('count: ' + (await kv.count).toString());
    var keys = await kv.allKeys;
    _logs.add('------key: value -> size - actualSize------');
    if (keys != null) {
      print(keys);
      for (var key in keys) {
        print(await kv.containsKey(key));
        _logs.add(
            '$key: ${await _getValue(key)} -> ${await kv.getValueSize(key)} - ${await kv.getValueActualSize(key)}');
      }
    }
    _logs.add('------default value test------');
    _logs.add(
        'string: ${await kv.decodeString('default value test', 'default string')}');
    _logs.add('int: ${await kv.decodeInt('default value test', 123)}');
    _logs.add('double: ${await kv.decodeDouble('default value test', 1.23)}');
    _logs.add('bool: ${await kv.decodeBool('default value test', false)}');
    var bytes = Uint8List.fromList([1, 2, 3]);
    _logs.add('bytes: ${await kv.decodeBytes('default value test', bytes)}');
    _logs.add('------other test------');
    _logs.add('containsKey(unknown): ${await kv.containsKey("unknown")}');
    _logText = _logs.join('\n');
    setState(() {});
  }

  _getValue(key) async {
    switch (key) {
      case 'bool':
        return kv.decodeBool(key);
      case 'time':
      case 'int':
        return kv.decodeInt(key);
      case 'double':
        return kv.decodeDouble(key);
      case 'bytes':
        return kv.decodeBytes(key);
      default:
        return kv.decodeString(key);
    }
  }

  _radioChange(int i) {
    _kvIndex = i;
    setState(() {});
  }
}
