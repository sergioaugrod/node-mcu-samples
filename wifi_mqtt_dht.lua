-- WiFi Configs
WIFI_USER = "INSERT_YOUR_WIFI_USER"
WIFI_PASSWORD = "INSERT_YOUR_WIFI_PASSWORD"

-- MQTT Configs
MQTT_CLIENT_ID = "NODE_MCU"
MQTT_USER = ""
MQTT_PASSWORD = ""
MQTT_HOST = "localhost"
MQTT_PORT = 1883

-- WiFi Connection
wifi.setmode(wifi.STATION)
-- After WiFi connection connect to MQTT
wifi.sta.eventMonReg(wifi.STA_GOTIP, connect_mqtt)
wifi.sta.eventMonStart()
wifi.sta.config(WIFI_USER, WIFI_PASSWORD)

function publish_temperature_humidity()
  status, temperature, humidity = dht.read(1)
  mqtt:publish("temperature", temperature, 0, 0)
  mqtt:publish("humidity", humidity, 0, 0)
end

function publish_luminosity()
  luminosity = 1
  mqtt:publish("luminosity", luminosity, 0, 0)
end

function publish_sensors_data()
  publish_temperature_humidity()
  publish_luminosity()
end

function subscribe_topics()
  mqtt:subscribe("power", 0)
  mqtt:on("message", function(client, topic, data)
    if data ~= nil then
      print(data)
    end
  end)
end

function connect_mqtt()
  mqtt = mqtt.Client(MQTT_CLIENT_ID, 120, MQTT_USER, MQTT_PASSWORD)
  mqtt:connect(MQTT_HOST, MQTT_PORT, 0, function(conn)
    subscribe_topics()
    tmr.alarm(0, 2000, 1, publish_sensors_data)
  end)
end
