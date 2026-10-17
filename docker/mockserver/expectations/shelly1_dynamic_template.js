// Helper function to generate dynamic Shelly 1 PM (Gen1) /status response
var hour = new Date().getHours();
var relayOn = true;
var solarFactor = Math.max(0, Math.sin((hour - 6) * Math.PI / 12));
var power = Math.round((250 + solarFactor * 500 + (Math.random() - 0.5) * 100) * 10) / 10;
var minutesSinceEpoch = Math.floor(Date.now() / 60000);
var tempC = parseFloat((30 + Math.random() * 8).toFixed(2));
var tempF = parseFloat((tempC * 1.8 + 32).toFixed(2));

return {
  statusCode: 200,
  headers: {
    'Content-Type': ['application/json']
  },
  body: JSON.stringify({
    wifi_sta: {
      connected: true,
      ssid: 'MyNetwork',
      ip: '192.168.1.110',
      rssi: -55
    },
    cloud: { enabled: false, connected: false },
    mqtt: { connected: false },
    time: new Date().toTimeString().substring(0, 5),
    unixtime: Math.floor(Date.now() / 1000),
    serial: 1,
    has_update: false,
    mac: 'CCDDEEFF1122',
    update: { status: 'idle', has_update: false },
    ram_total: 24576,
    ram_free: 13992,
    ram_lwm: 10240,
    fs_size: 262144,
    fs_free: 131072,
    uptime: Math.floor(Math.random() * 86400) + 3600,
    relays: [
      {
        ison: relayOn,
        has_timer: false,
        timer_started: 0,
        timer_duration: 0,
        timer_remaining: 0,
        overpower: false,
        source: 'http'
      }
    ],
    meters: [
      {
        power: relayOn ? power : 0,
        overpower: 2000,
        is_valid: true,
        timestamp: minutesSinceEpoch * 60,
        counters: [
          parseFloat(((minutesSinceEpoch - 2) * 2.5).toFixed(1)),
          parseFloat(((minutesSinceEpoch - 1) * 2.5).toFixed(1)),
          parseFloat((minutesSinceEpoch * 2.5).toFixed(1))
        ],
        total: relayOn ? parseFloat((minutesSinceEpoch * 2.5).toFixed(1)) : 0
      }
    ],
    inputs: [
      { input: 0, event: '', event_cnt: 0 }
    ],
    ext_sensors: {},
    temperature: tempC,
    overtemperature: false,
    tmp: { tC: tempC, tF: tempF, is_valid: true },
    temperature_status: 'Normal',
    ext_switch: {}
  })
};
