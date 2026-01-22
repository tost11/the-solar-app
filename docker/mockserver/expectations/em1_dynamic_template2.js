var hour = new Date().getHours();
var consumed = 1000 + (Math.random() - 0.5) * 400;
var solarFactor = Math.max(0, Math.sin((hour - 6) * Math.PI / 12));
var solar = solarFactor * 600;
var voltage = 230 + (Math.random() - 0.5) * 10;
var netPower = consumed - solar;
var current = netPower / voltage;
var minutesSinceEpoch = Math.floor(Date.now() / 60000);

return {
  statusCode: 200,
  headers: {
    'Content-Type': ['application/json']
  },
  body: JSON.stringify({
    ble: {},
    cloud: { connected: false },
    'em1:0': {
      id: 0,
      current: 0.020,
      voltage: 224.6,
      act_power: 0.0,
      aprt_power: 4.6,
      pf: 0.00,
      freq: 50.0,
      calibration: 'factory'
    },
    'em1:1': {
      id: 1,
      current: parseFloat(current.toFixed(3)),
      voltage: parseFloat(voltage.toFixed(1)),
      act_power: Math.floor(netPower),
      aprt_power: Math.floor(netPower * 1.01),
      pf: 0.99,
      freq: 50.0,
      calibration: 'factory'
    },
    'em1data:0': {
      id: 0,
      total_act_energy: 0.00,
      total_act_ret_energy: 0.00
    },
    'em1data:1': {
      id: 1,
      total_act_energy: minutesSinceEpoch * 1.0,
      total_act_ret_energy: minutesSinceEpoch * 0.3
    },
    eth: { ip: null },
    modbus: {},
    mqtt: { connected: true },
    'switch:0': {
      id: 0,
      source: 'HTTP_in',
      output: true,
      temperature: { tC: 29.4, tF: 85.0 }
    },
    sys: {
      mac: '001122334455',
      restart_required: false,
      time: new Date().toTimeString().substring(0, 5),
      unixtime: Math.floor(Date.now() / 1000),
      uptime: Math.floor(Math.random() * 86400) + 3600,
      ram_size: 241940,
      ram_free: Math.floor(Math.random() * 20000) + 107332,
      fs_size: 524288,
      fs_free: Math.floor(Math.random() * 10000) + 198896,
      cfg_rev: 20,
      kvs_rev: 0,
      schedule_rev: 0,
      webhook_rev: 0,
      available_updates: { stable: { version: '1.2.0' } },
      reset_reason: 3
    },
    wifi: {
      sta_ip: '192.168.1.100',
      status: 'got ip',
      ssid: 'MyNetwork',
      rssi: -60
    },
    ws: { connected: false }
  })
};
