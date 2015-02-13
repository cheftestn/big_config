# Setting up Zookeeper 

Setting up on `AHMD-HBASE-RS01`,`AHMD-HBASE-RS02`,`AHMD-HBASE-RS03`

Do the below process in all the slave nodes as we will be running zookeeper on these machines.
Thumb rule for `zookeeper` is the have odd number of `zookeeper` in a cluster, so that its easier to elect a leader.
	
	AHMD-HBASE-RS01
	AHMD-HBASE-RS02
	AHMD-HBASE-RS03

### Initial setup on all `zookeeper` servers.

Extracting `zookeeper`
	
	tar xvzf zookeeper-3.4.5-cdh5.1.2.tar.gz -C /opt/
	ln -s /opt/zookeeper-3.4.5-cdh5.1.2 /opt/zookeeper


Create a directory for zookeeper.

	mkdir -p /data/zookeeper

Setting Configuration for zookeeper `zoo.cfg`
	
	cp /opt/zookeeper/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg

Change the path in `zoo.cfg` for `dataDir`.

	sed -i -- 's/tmp\/zookeeper/data\/zookeeper/g' /opt/zookeeper/conf/zoo.cfg

Next we Add the `zookeeper` cluster nodes.  
	
	echo "server.1=AHMD-HBASE-RS01:2888:3888" >> /opt/zookeeper/conf/zoo.cfg
	echo "server.2=AHMD-HBASE-RS02:2888:3888" >> /opt/zookeeper/conf/zoo.cfg
	echo "server.3=AHMD-HBASE-RS03:2888:3888" >> /opt/zookeeper/conf/zoo.cfg

In the above line `server.1` where `1` is the id for server `AHMD-HBASE-RS01` and
`2` for `AHMD-HBASE-RS02` and `3` for `AHMD-HBASE-RS03`. 

So to assign an `id` to server we need to create a `myid` file `dataDir` path, which is currently set to `/data/zookeeper`

### Assigning `id`s to `zookeeper` nodes.

So in Server `AHMD-HBASE-RS01` which has an `id` of `1`, use the below command.

	echo "1" > /data/zookeeper/myid

`AHMD-HBASE-RS02` which has an `id` of `2`, use the below command.

	echo "2" > /data/zookeeper/myid

`AHMD-HBASE-RS03` which has an `id` of `3`, use the below command.

	echo "3" > /data/zookeeper/myid
 
### Starting up `zookeeper` server 

Use below command on all `zookeeper` servers.

	/opt/zookeeper/bin/zkServer.sh start 

Log `zookeeper.out` of the startup will in the directory were the above command was executed.


### Testing `zookeeper`

`zookeeper` by default will run on port `2181`. To verify of the service is running on this port, use `telnet` to verify. if you get the `^]` char then we are all good. 

Do this to connect to all the `zookeeper` nodes.

	root@AHMD-HBASE-RS01:~# telnet AHMD-HBASE-RS02 2181
	Trying 16.114.26.94...
	Connected to AHMD-HBASE-RS02.
	Escape character is '^]'.
	^CConnection closed by foreign host.
	root@AHMD-HBASE-RS01:~#