var hour = new Date().getHours();
var minutesSinceEpoch = Math.floor(Date.now() / 60000);

// Single-phase power calculation
var consumed = 1000 + (Math.random() - 0.5) * 400;
var solarFactor = Math.max(0, Math.sin((hour - 6) * Math.PI / 12));
var solar = solarFactor * 600;
var netPower = consumed - solar;
var voltage = 230 + (Math.random() - 0.5) * 10;
var current = netPower / voltage;

return {
  statusCode: 200,
  headers: { 'Content-Type': ['application/json'] },
  body: JSON.stringify({
    id: 1768255378,
    src: 'shellypmg3-ddeeff112233',
    dst: 'flutter_app',
    result: {
      ble: {},
      bthome: {
        errors: ['bluetooth_disabled']
      },
      cloud: { connected: true },
      mqtt: { connected: false },
      'pm1:0': {
        id: 0,
        voltage: parseFloat(voltage.toFixed(1)),
        current: parseFloat(current.toFixed(3)),
        apower: parseFloat(netPower.toFixed(1)),
        freq: 50.0,
        aenergy: {
          total: parseFloat((minutesSinceEpoch * 60.0).toFixed(3)),
          by_minute: [
            parseFloat(((minutesSinceEpoch - 2) * 60.0).toFixed(3)),
            parseFloat(((minutesSinceEpoch - 1) * 60.0).toFixed(3)),
            parseFloat((minutesSinceEpoch * 60.0).toFixed(3))
          ],
          minute_ts: Math.floor(Date.now() / 1000)
        },
        ret_aenergy: {
          total: parseFloat((minutesSinceEpoch * 20.0).toFixed(3)),
          by_minute: [
            parseFloat(((minutesSinceEpoch - 2) * 20.0).toFixed(3)),
            parseFloat(((minutesSinceEpoch - 1) * 20.0).toFixed(3)),
            parseFloat((minutesSinceEpoch * 20.0).toFixed(3))
          ],
          minute_ts: Math.floor(Date.now() / 1000)
        }
      },
      'script:1': {
        id: 1,
        running: false,
        mem_free: 25200,
        cpu: 0
      },
      sys: {
        mac: 'DDEEFF112233',
        restart_required: false,
        time: new Date().toTimeString().substring(0, 5),
        unixtime: Math.floor(Date.now() / 1000),
        last_sync_ts: Math.floor(Date.now() / 1000) - 900,
        uptime: Math.floor(Math.random() * 86400) + 3600,
        ram_size: 268460,
        ram_free: Math.floor(Math.random() * 30000) + 110000,
        ram_min_free: 110896,
        fs_size: 1048576,
        fs_free: Math.floor(Math.random() * 10000) + 620000,
        cfg_rev: 47,
        kvs_rev: 0,
        schedule_rev: 2,
        webhook_rev: 0,
        btrelay_rev: 2,
        available_updates: {
          beta: { version: '1.7.4-beta2' }
        },
        reset_reason: 3,
        utc_offset: 3600
      },
      wifi: {
        sta_ip: '192.168.1.104',
        status: 'got ip',
        ssid: 'MyNetwork',
        bssid: 'dd:ee:ff:11:22:33',
        rssi: Math.floor(Math.random() * 20) - 90,
        sta_ip6: ['fe80::1234:5678:abcd:ef04']
      },
      ws: { connected: false }
    }
  })
};
