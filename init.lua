
hs.loadSpoon('SleepWatch')
spoon.SleepWatch.mqtt_host = 'localhost'
spoon.SleepWatch.mqtt_user = 'YOUR_MQTT_USER'
spoon.SleepWatch.mqtt_pass = 'YOUR_MQTT_PASS'
spoon.SleepWatch.mqtt_topic = 'YOUR_MQTT_TOPIC'
spoon.SleepWatch.mqtt_certFile = '/usr/local/etc/openssl/cert.pem'
spoon.SleepWatch:start()
