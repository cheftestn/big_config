# Setting Up High Availability Hadoop Cluster Setup.

##[HA SETUP - ***** WORK IN PROGRESS *****]

Few basic to start the services. Below is the Node Setup.

    10.10.18.30        AHMD-SRV-NAMENODE    # NAMENODE
    10.10.18.31        AHMD-SRV-STANDBY-NN  # SECONDARY NAMENODE
    10.10.18.93        AHMD-SRV-RES-MANAGER # RESOURCE MANAGER / JOBHISTORY
    10.10.18.33        AHMD-SRV-DATANODE-01 # DATANODE / NODEMANAGER
    10.10.18.34        AHMD-SRV-DATANODE-02 # DATANODE / NODEMANAGER
    10.10.18.35        AHMD-SRV-DATANODE-03 # DATANODE / NODEMANAGER
   
##Steps To Setup Cluster.    
    
Init for Cluster Setup.
    
1. Setup passwordless From `AHMD-SRV-NAMENODE/STANDBY-NN/RES-MANAGER` To all the Nodes. 
2. Update `/etc/hosts` on all nodes, as it is in `etc_hosts` file.
3. Create `hadoopadmin` user on all the nodes.
4. Run `master_node_script.sh` on `AHMD-SRV-NAMENODE/STANDBY-NN/RES-MANAGER`. [Change the script based on the `/data` directory on the node].
5. Run `datanode_script.sh` on `AHMD-SRV-DATANODE-01/02/03`. [Change the script based on the `/data` directory on the node].
6. Extract `cdh5-hadoop.tgz` in `/opt`. Update owner to `hadoopadmin`, set softlink to `/opt/hadoop`
7. Copy configuration file to `$HADOOP_HOME/etc/hadoop/` on all nodes.

##Starting HDFS Service.

HDFS Setup Steps.

1. Login on the `AHMD-SRV-NAMENODE` [10.10.18.30] node as `hadoopadmin`.
2. Format Namenode. [`/opt/hadoop/bin/hadoop namenode -format`]
3. Start Namenode. [`/opt/hadoop/sbin/hadoop-daemon.sh start namenode`]
4. Start Datanodes. [`/opt/hadoop/sbin/hadoop-daemons.sh start datanode`]
5. Start Secondary Namenode on `AHMD-SRV-STANDBY-NN` [10.10.18.31]. [`/opt/hadoop/sbin/hadoop-daemon.sh start secondarynamenode`]

##Starting YARN Services.

Lets Start YARN services. 

1. Logon to `AHMD-SRV-RES-MANAGER` [10.10.18.93] node as `hadoopadmin`.
2. Start Resource Manager. [`/opt/hadoop/sbin/yarn-daemon.sh start resourcemanager`]
3. Start Node Manager. [`/opt/hadoop/sbin/yarn-daemons.sh start nodemanager`]
4. Start History Server on `AHMD-SRV-RES-MANAGER` node. [`/opt/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver`]

## GOAL TO RUN HA SERVICES AS BELOW.

Create `JournalNode` on all Masters. To Avoid `Split Brain` setup Zookeeper Cluster on Masters.

    10.10.18.30        AHMD-SRV-NAMENODE    # NAMENODE / ZOOKEEPER[01] / JOURNALNODE
    10.10.18.31        AHMD-SRV-STANDBY-NN  # STANDBY NAMENODE / ZOOKEEPER[02] / JOURNALNODE
    10.10.18.93        AHMD-SRV-RES-MANAGER # RESOURCE MANAGER / JOBHISTORY / ZOOKEEPER[03] / JOURNALNODE 
    10.10.18.33        AHMD-SRV-DATANODE-01 # DATANODE / NODEMANAGER
    10.10.18.34        AHMD-SRV-DATANODE-02 # DATANODE / NODEMANAGER
    10.10.18.35        AHMD-SRV-DATANODE-03 # DATANODE / NODEMANAGER
    
More Details Here : <http://www.cloudera.com/content/cloudera/en/documentation/core/v5-2-x/topics/cdh_hag_hdfs_ha_config.html>