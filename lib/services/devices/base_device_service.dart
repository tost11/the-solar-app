import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../models/devices/device_base.dart';

abstract class BaseDeviceService {

    bool autoReconnect = true;  // Default true: devices auto-connect on startup and after network issues
    bool fetchDataEnabled = true;
    Timer? _updateTimer;
    late DeviceBase device;
    bool _timmerRunning = false;
    int LastTimeTick = 0;
    late Duration _fetchTime;
    Duration _initTime = Duration(seconds: 5);
    Duration _reconnectTime = Duration(seconds: 20);//TODO increase over time
    bool _wasConnected = false;
    int lastSeen = 0;  // Timestamp for time-based connection detection
    bool _isConnecting = false;
    bool isInitialized = false;

    bool isServiceInitialized(){
      return isInitialized;
    }

    BaseDeviceService(Duration ? updateTime,DeviceBase baseDevice){
      device = baseDevice;
      _updateTimer = Timer.periodic(new Duration(milliseconds: 100),(t){_update(t);});
      if(updateTime != null && updateTime.inMicroseconds > 0){
        _fetchTime = updateTime;
      }else{
        _fetchTime = Duration(seconds: 30);
      }
    }

    void dispose(){
      fetchDataEnabled = false;  // Stop data fetching during disposal
      autoReconnect = false;     // Stop reconnection attempts during disposal
      final timer = this._updateTimer;
      if(timer != null){
        timer.cancel();
      }
    }

    bool isConnected();

    /// Template method for disconnection - handles standard disconnect flow
    /// Subclasses should override internalDisconnect() for device-specific logic
    Future<void> disconnect() async {
      print('[${device.connectionType}][${device.name}] Disconnecting...');

      // Prevent auto-reconnect
      lastSeen = 0;
      autoReconnect = false;

      try {
        // Clear all device data (forces fresh data on reconnect)
        device.data.clear();

        // Run service-specific disconnect logic
        await internalDisconnect();

        isInitialized = false;
        resetTimer();

        // Emit status AFTER disconnect completes
        final isDeviceConnected = isConnected();
        if (!isDeviceConnected) {
          device.emitStatus("Getrennt");
          print('[${device.connectionType}][${device.name}] Successfully disconnected.');
        }
      } catch (e) {
        print('[${device.connectionType}][${device.name}] Error during disconnect: $e');
        device.emitStatus("Fehler beim Trennen");
        rethrow;
      }
    }

    /// Device-specific disconnection logic
    ///
    /// Override this in subclasses to:
    /// - Disconnect secondary connections (Modbus, WebSocket, TCP)
    /// - Clear caches (auth, config)
    /// - Release resources
    /// - Call lifecycle hooks
    ///
    /// Note: You do NOT need to set lastSeen=0 or autoReconnect=false
    /// as the wrapper handles that automatically.
    @protected
    Future<void> internalDisconnect() async {
      // Default implementation does nothing
      // Subclasses override to add device-specific logic
    }

    /// Template method for connection - handles standard connection flow
    /// Subclasses should override internalConnect() for device-specific logic
    Future<void> connect() async {
      //this protects for double execution //TODO make correct with mutex
      if(_isConnecting || isConnected()){
        return;
      }
      _isConnecting = true;
      autoReconnect = true;
      try {
        device.emitStatus('Verbinde...');

        // Call device-specific connection logic
        if(await internalConnect()){
          resetTimer();
        }

        // Standard post-connection setup
        device.emitStatus('Lade Initiale Daten...');
        // Set lastSeen for all services (used by time-based connection detection), before resetTimer important
        lastSeen = DateTime.now().millisecondsSinceEpoch;
        fetchDataEnabled = true;
      } catch (e) {
        debugPrint('Connection error: $e');
        device.emitErrorWithFlag('Verbindungsfehler: $e', true);
        device.emitStatus('Verbindung fehlgeschlagen');
        rethrow;
      }finally{
        _isConnecting = false;
      }
    }

    /// Device-specific connection logic
    /// Override this in subclasses to implement device-specific connection
    Future<bool> internalConnect();

    Future<void> initDevice() async {
      if(isInitialized){
        return;
      }
      device.emitStatus('Lese Geräteinfo...');
      if(await internalInitializeDevice()){
        //if true wee need to fetch data directly because other data
        resetTimer();
      }

      device.emitStatus('Lese Gerätedaten...');
      isInitialized = true;
    }

    Future<bool> internalInitializeDevice(){
      return Future.value(true);
    }

    /// Template method for data fetching - handles standard fetch flow
    /// Subclasses should override internalFetchData() for device-specific logic
    Future<void> fetchData() async {
      try {
        // Call device-specific data fetching logic
        await internalFetchData();

        // Update status to connected after successful fetch
        device.emitStatus('Verbunden');
      } catch (e) {
        debugPrint('Fetch data error: $e');
        device.emitErrorWithFlag('Datenabruf fehlgeschlagen: $e', true);
        // Don't rethrow - allow timer to retry
      }
    }

    /// Device-specific data fetching logic
    /// Override this in subclasses to implement device-specific fetching
    Future<void> internalFetchData();

    void resetTimer(){
      LastTimeTick = 0;
    }

    Future<void> _update(Timer timer) async {

      if(isConnected()){
        _wasConnected = true;
      }else{
        if(_wasConnected == true){
          debugPrint("------------------------- updated connection status ----------------------");
          device.emitData({});
          device.emitStatus("nicht Verbunden");
        }
        _wasConnected = false;
      }

      if(this.isConnected()){
        if(this.isInitialized) {
          if (DateTime
              .now()
              .millisecondsSinceEpoch - _fetchTime.inMilliseconds <
              LastTimeTick) {
            return;
          }
        }else{
          if(DateTime.now().millisecondsSinceEpoch - _initTime.inMilliseconds < LastTimeTick){
            return;
          }
        }
      }else{
        if(DateTime.now().millisecondsSinceEpoch - _reconnectTime.inMilliseconds < LastTimeTick){
          return;
        }
      }

      LastTimeTick = DateTime.now().millisecondsSinceEpoch;
      //this protects for double execution //TODO make correct with mutex
      if(_timmerRunning == true){
        return;
      }
      _timmerRunning = true;
      try {
        if (this.isConnected()) {
          if(!isInitialized){
            debugPrint("------------------------- init data ----------------------");
            await this.initDevice();
          }else if(fetchDataEnabled) {
            debugPrint("------------------------- fetch data ----------------------");
            await this.fetchData();  // Base class checks fetchDataEnabled before calling
          }
        } else if (autoReconnect) {
          await connect();  // Connection attempts controlled only by autoReconnect
        }
      }catch(e){
        debugPrint("error on reconnecting$e");
        _timmerRunning = false;
        rethrow;
      }
      _timmerRunning = false;
    }
}