
<a name="CreatingaMultinodeCassandraClusteronCentos65"></a>

# Creating a Multi-node Cassandra Cluster on Centos 6.5.


---

###Table of Contents

* <a href="#InitialServerSetup">Initial Server Setup</a>
	* <a href="#HardwareInformation">Hardware Information</a>
	* <a href="#SettingHostforcassandra">Setting Host for `cassandra`</a>
	* <a href="#Updatinghostnameonallservers">Updating `hostname` on all servers.</a>
	* <a href="#Creatingcassandrauserwithsudopermissions">Creating `cassandra` user with `sudo` permissions.</a>
	* <a href="#CreatingpasswordlessentryfromSEEDCASSANDRA01tootherservers">Creating passwordless entry from SEED (`CASSANDRA01`) to other servers.</a>
* <a href="#ExtractingFiles">Extracting Files.</a>
* <a href="#UpdatingConfigurationFile">Updating Configuration File.</a>
	* <a href="#Settinginitialtokenasbelow">Setting `initial_token` as below.</a>
	* <a href="#OnNodeCASSANDRA01">On Node `CASSANDRA01`</a>
	* <a href="#OnNodeCASSANDRA02">On Node `CASSANDRA02`</a>
	* <a href="#OnNodeCASSANDRA03">On Node `CASSANDRA03`</a>
* <a href="#Startingcassandra">Starting `cassandra`.</a>
	* <a href="#CheckingClusterInformation">Checking Cluster Information.</a>
	* <a href="#LoggingintoCQLShell">Logging into CQL Shell.</a>
	* <a href="#DataLocationonCASSANDRA01CASSANDRA02CASSANDRA03">Data Location on CASSANDRA01, CASSANDRA02, CASSANDRA03</a>
* <a href="#PerformaceTuning">Performace Tuning.</a>
	* <a href="#Updatingcassandrayamlfile">Updating `cassandra.yaml` file.</a>
	* <a href="#Updatingcassandraenvshfile">Updating `cassandra-env.sh` file.</a>
	* <a href="#Updatingcassandratopologypropertiesfile">Updating `cassandra-topology.properties` file.</a>
* <a href="#UsefulLinks">Useful Links</a>

---


This is a basic multi-node cassandra setup.


<a name="InitialServerSetup"></a>

## Initial Server Setup 


<a name="HardwareInformation"></a>

### Hardware Information

All the server were with below configuration.

    CPU : 40 Cores
    RAM : 192GB

    

<a name="SettingHostforcassandra"></a>

### Setting Host for `cassandra`

Setting up the servers and update `/etc/hosts` as below.

	#Adding CASSANDRA NODES
	10.130.18.35    CASSANDRA01 		#SEED
	10.130.18.93    CASSANDRA02 		#Worker
	10.130.18.98    CASSANDRA03 		#Worker


<a name="Updatinghostnameonallservers"></a>

### Updating `hostname` on all servers.

Update `hostname`s as required.

	sudo vim /etc/sysconfig/network

Update `hostname` as below, do the same in all servers [`CASSANDRA01`, `CASSANDRA02`,`CASSANDRA03`].	
	
	NETWORKING=yes
	HOSTNAME=CASSANDRA01

To update the `hostname` without a reboot execute below command.

	sudo hostname CASSANDRA01

NOTE : `hostname` command will keep the hostname till the next reboot. So its required that we update `/etc/sysconfig/network` file.	
	

<a name="Creatingcassandrauserwithsudopermissions"></a>

### Creating `cassandra` user with `sudo` permissions.

Have a script which will create a user on server. 
	
	wget https://raw.githubusercontent.com/zubayr/create_user_script/master/create_user_script.sh
	sh create_user_script.sh -s cassandra

This will create a `cassendra` user, with `sudo` permissions.	
	

<a name="CreatingpasswordlessentryfromSEEDCASSANDRA01tootherservers"></a>

### Creating passwordless entry from SEED (`CASSANDRA01`) to other servers.

Create a `rsa` key on `CASSANDRA01`

	ssh-keygen -t rsa
	
Create `.ssh` directory on other 2 servers.
	
	ssh cassandra@CASSANDRA02 mkdir -p .ssh
	ssh cassandra@CASSANDRA03 mkdir -p .ssh
	
Add the `id_rsa.pub` to `authorized_keys`
	
	cat ~/.ssh/id_rsa.pub | ssh cassandra@CASSANDRA02 'cat >> .ssh/authorized_keys'
	cat ~/.ssh/id_rsa.pub | ssh cassandra@CASSANDRA03 'cat >> .ssh/authorized_keys'

Make sure we have the right permissions.
	
	ssh cassandra@CASSANDRA02 chmod 744 -R .ssh 
	ssh cassandra@CASSANDRA03 chmod 744 -R .ssh 

Testing.	

	ssh cassandra@CASSANDRA02
	ssh cassandra@CASSANDRA03
	
	

<a name="ExtractingFiles"></a>

## Extracting Files.

Extracting Files to opt and creating a link.

	sudo tar xvzf apache-cassandra-2.1.3-bin.tar.gz -C /opt
	sudo ln -s /opt/apache-cassandra-2.1.3 /opt/cassandra
	sudo chown cassandra:cassandra -R /opt/cassandra
	sudo chown cassandra:cassandra -R /opt/apache-cassandra-2.1.3


Creating Required Directories.

	sudo mkdir -p /data1/cassandra/commitlog
	sudo mkdir -p /data1/cassandra/data
	sudo mkdir -p /data1/cassandra/saved_cahes


<a name="UpdatingConfigurationFile"></a>

## Updating Configuration File.


<a name="Settinginitialtokenasbelow"></a>

### Setting `initial_token` as below.

Node 0: 0
Node 1: 3074457345618258602
Node 2: 6148914691236517205



<a name="OnNodeCASSANDRA01"></a>

###On Node `CASSANDRA01`

	cluster_name: 'MyCassandraCluster'
	initial_token: 0
	seed_provider:
	  - class_name: org.apache.cassandra.locator.SimpleSeedProvider
		parameters:
			 - seeds: "10.130.18.35"
	listen_address: 10.130.18.35
	endpoint_snitch: SimpleSnitch

	data_file_directories:
		- /data1/cassandra/data

	commitlog_directory: /data1/cassandra/commitlog
	saved_caches_directory: /data1/cassandra/saved_caches



<a name="OnNodeCASSANDRA02"></a>

### On Node `CASSANDRA02`

	cluster_name: 'MyCassandraCluster'
	initial_token: 3074457345618258602
	seed_provider:
	  - class_name: org.apache.cassandra.locator.SimpleSeedProvider
		parameters:
			 - seeds: "10.130.18.35"
	listen_address: 10.130.18.93
	endpoint_snitch: SimpleSnitch

	data_file_directories:
		- /data1/cassandra/data

	commitlog_directory: /data1/cassandra/commitlog
	saved_caches_directory: /data1/cassandra/saved_caches


<a name="OnNodeCASSANDRA03"></a>

###On Node `CASSANDRA03`

	cluster_name: 'MyCassandraCluster'
	initial_token: 6148914691236517205
	seed_provider:
	  - class_name: org.apache.cassandra.locator.SimpleSeedProvider
		parameters:
			 - seeds: "10.130.18.35"
	listen_address: 10.130.18.98
	endpoint_snitch: SimpleSnitch

	data_file_directories:
		- /data1/cassandra/data

	commitlog_directory: /data1/cassandra/commitlog
	saved_caches_directory: /data1/cassandra/saved_caches



<a name="Startingcassandra"></a>

## Starting `cassandra`.

On Server `CASSANDRA01`.

	sh /opt/cassandra/bin/cassandra

Wait till the server initialize and then start rest of nodes.
	
On Server `CASSANDRA02`.

	sh /opt/cassandra/bin/cassandra

	
On Server `CASSANDRA03`.

	sh /opt/cassandra/bin/cassandra



<a name="CheckingClusterInformation"></a>

### Checking Cluster Information.	
	
	[cassandra@CASSANDRA01 bin]$ ./nodetool status
	Datacenter: datacenter1
	=======================
	Status=Up/Down
	|/ State=Normal/Leaving/Joining/Moving
	--  Address       Load       Tokens  Owns (effective)  Host ID                               Rack
	UN  10.10.18.98  72.09 KB   1       33.3%             1a5a0c77-b5e6-4057-87b4-a8e788786244  rack1
	UN  10.10.18.35  46.24 KB   1       83.3%             67de1b1f-8070-48c1-ad88-2c0d4dd7a988  rack1
	UN  10.10.18.93  55.64 KB   1       83.3%             7fba7cd0-6f99-4ce8-8194-c9a8b23488cd  rack1


<a name="LoggingintoCQLShell"></a>

### Logging into CQL Shell.

We need to `export` CQLSH_HOST 

	[cassandra@CASSANDRA01 bin]$ export CQLSH_HOST=10.10.18.35
	[cassandra@CASSANDRA01 bin]$ cqlsh
	Connected to CassandraJIOCluster at 10.10.18.35:9042.
	[cqlsh 5.0.1 | Cassandra 2.1.3 | CQL spec 3.2.0 | Native protocol v3]
	Use HELP for help.
	cqlsh>



<a name="DataLocationonCASSANDRA01CASSANDRA02CASSANDRA03"></a>

### Data Location on CASSANDRA01, CASSANDRA02, CASSANDRA03

	[cassandra@CASSANDRA01 bin]$ ls -l /data1/cassandra/
	total 12
	drwxr-xr-x 2 cassandra cassandra 4096 Mar 19 14:23 commitlog
	drwxr-xr-x 4 cassandra cassandra 4096 Mar 19 14:23 data
	drwxr-xr-x 2 cassandra cassandra 4096 Mar 19 13:18 saved_caches
	[cassandra@CASSANDRA01 bin]$


<a name="PerformaceTuning"></a>

## Performace Tuning.


<a name="Updatingcassandrayamlfile"></a>

### Updating `cassandra.yaml` file.

    # For workloads with more data than can fit in memory, Cassandra's
    # bottleneck will be reads that need to fetch data from
    # disk. "concurrent_reads" should be set to (16 * number_of_drives) in
    # order to allow the operations to enqueue low enough in the stack
    # that the OS and drives can reorder them. Same applies to
    # "concurrent_counter_writes", since counter writes read the current
    # values before incrementing and writing them back.
    #
    # On the other hand, since writes are almost never IO bound, the ideal
    # number of "concurrent_writes" is dependent on the number of cores in
    # your system; (8 * number_of_cores) is a good rule of thumb.

    #concurrent_reads: 32
    #concurrent_writes: 32

    # Change as we had a 40core machine which calculates to 240.
    concurrent_reads: 32
    concurrent_writes: 240
    concurrent_counter_writes: 32


<a name="Updatingcassandraenvshfile"></a>

### Updating `cassandra-env.sh` file.

    # Override these to set the amount of memory to allocate to the JVM at
    # start-up. For production use you may wish to adjust this for your
    # environment. MAX_HEAP_SIZE is the total amount of memory dedicated
    # to the Java heap; HEAP_NEWSIZE refers to the size of the young
    # generation. Both MAX_HEAP_SIZE and HEAP_NEWSIZE should be either set
    # or not (if you set one, set the other).
    #
    # The main trade-off for the young generation is that the larger it
    # is, the longer GC pause times will be. The shorter it is, the more
    # expensive GC will be (usually).
    #
    # The example HEAP_NEWSIZE assumes a modern 8-core+ machine for decent pause
    # times. If in doubt, and if you do not particularly want to tweak, go with
    # 100 MB per physical CPU core.
    
    # Important is the HEAP_NEWSIZE 100MB * number of Core (40 cores in our case)
    
    #MAX_HEAP_SIZE="4G"
    #HEAP_NEWSIZE="800M"
    MAX_HEAP_SIZE="15G"
    HEAP_NEWSIZE="4G"


<a name="Updatingcassandratopologypropertiesfile"></a>

### Updating `cassandra-topology.properties` file.

If the server are in Data Center which in different location then we need to update this file as well.
Also specify rack in that DC.

Cassandra 

`{{Node IP}}`=`{{Data Center}}`:`{{Rack}}`.

NOTE : This has to match with the `cassendra-rackdc.properties` file.
    
    10.130.18.35=DC1:RAC1
    10.130.18.93=DC2:RAC1
    10.130.18.98=DC2:RAC2

When using this format we need to update `cassendra-rackdc.properties` and use `endpoint_snitch:` as `GossipingPropertyFileSnitch` in the `cassandra.yaml` 


<a name="UsefulLinks"></a>

## Useful Links

	https://www.digitalocean.com/community/tutorials/how-to-configure-a-multi-node-cluster-with-cassandra-on-a-ubuntu-vps
	https://www.datastax.com/documentation/cassandra/1.2/cassandra/initialize/initializeSingleDS.html
	http://www.rackspace.com/knowledge_center/article/centos-hostname-change
	http://www.datastax.com/documentation/cassandra/2.0/cassandra/initialize/initializeSingleDS.html
	http://www.datastax.com/documentation/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html
	http://whatizee.blogspot.in/2013/12/passwordless-login-from-ahmedamd-to.html?q=passwordless
	