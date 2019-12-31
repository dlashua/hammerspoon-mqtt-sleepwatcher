
hs.loadSpoon('SleepWatch')
spoon.SleepWatch.notifications = true
spoon.SleepWatch.debug = false
spoon.SleepWatch.mqtt_host = 'YOUR_MQTT_HOST'
spoon.SleepWatch.mqtt_user = 'YOUR_MQTT_USER'
spoon.SleepWatch.mqtt_pass = 'YOUR_MQTT_PASS'
spoon.SleepWatch.mqtt_topic = 'YOUR_MQTT_TOPIC'
-- spoon.SleepWatch.mqtt_port = 'YOUR_MQTT_PORT'
-- spoon.SleepWatch.mqtt_certFile = '/usr/local/etc/openssl/cert.pem'
spoon.SleepWatch:start()
