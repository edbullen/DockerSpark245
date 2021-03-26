
# Simple Zookeeper setup for Windows 10 desktop #

Based on instructions here:
https://towardsdatascience.com/running-zookeeper-kafka-on-windows-10-14fc70dcc771

# Set the log-location - relative path #
Edit `./conf/zoo.cfg`

```
#dataDir=/tmp/zookeeper
dataDir=./../logs
```

# Change the Admin web-server port #

Edit `./conf/zoo.cfg`
```
# Set the Admin Port to non-default value
admin.serverPort=9876
```

# Start in a Windows CMD Window #

*cd to install location*

```
zkserver
```

Look for line similar to
```
...
...

2020-12-02 11:29:38,221 [myid:] - INFO  [main:NIOServerCnxnFactory@686] - binding to port 0.0.0.0/0.0.0.0:2181
...
```



# Check Status via the Admin Server #

http://localhost:9876/commands/stat



