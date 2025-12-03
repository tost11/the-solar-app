import 'dart:async';

import '../../models/devices/device_base.dart';

abstract class BaseDeviceService {

    bool autoReconnect = false;
    Timer? _updateTimer;
    late DeviceBase device;
    bool _timmerRunning = false;
    int LastTimeTick = 0;
    Duration ? _timeToFetch;

    BaseDeviceService(Duration ? updateTime,DeviceBase baseDevice){
      device = baseDevice;
      _timeToFetch = updateTime;
      if(updateTime != null && updateTime.inMicroseconds > 0){
        _updateTimer = Timer.periodic(new Duration(milliseconds: 100),(t){_update(t);});
      }
    }

    void dispose(){
      final timer = this._updateTimer;
      if(timer != null){
        timer.cancel();
      }
    }

    bool isConnected();

    Future<void> disconnect();

    Future<void> connect();

    bool isInitialized();

    //Future<void> sendCommand(String command, Map<String, dynamic> params);
    void fetchData();

    void resetTimer(){
      LastTimeTick = DateTime.now().millisecondsSinceEpoch;
    }

    void _update(Timer timer) {
      if( DateTime.now().millisecondsSinceEpoch - _timeToFetch!.inMilliseconds < LastTimeTick){
        return;
      }
      LastTimeTick = DateTime.now().millisecondsSinceEpoch;
      if(_timmerRunning == true){
        return;
      }
      _timmerRunning = true;
      try {
        if (this.isConnected()) {
          if (this.isInitialized()) {
            this.fetchData();
          }
        } else {
          connect();
        }
      }catch(e){
        _timmerRunning = false;
        rethrow;
      }
      _timmerRunning = false;
    }
}