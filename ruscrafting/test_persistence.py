#!/usr/bin/env python3
"""Compile the real repository with minimal platform stubs; no server or database required."""
from pathlib import Path
import argparse, subprocess, tempfile

ROOT = Path(__file__).resolve().parents[1]
PACKAGE = 'com/magmaguy/elitemobs/playerdata/database'
p = argparse.ArgumentParser()
p.add_argument('--source-root', type=Path, default=ROOT)
a = p.parse_args()
with tempfile.TemporaryDirectory(prefix='elitemobs-lock-test-') as directory:
    work = Path(directory)
    files = {
      PACKAGE + '/PlayerDataRepository.java': (a.source_root / 'src/main/java' / PACKAGE / 'PlayerDataRepository.java').read_text(),
      PACKAGE + '/PlayerData.java': '''package com.magmaguy.elitemobs.playerdata.database;
public class PlayerData { static String getDATABASE_NAME(){return "test.db";} static String getPLAYER_DATA_TABLE_NAME(){return "PlayerData";}
record ScoreRank(int rank,int size){static ScoreRank unavailable(){return new ScoreRank(0,0);}} }''',
      'com/magmaguy/elitemobs/MetadataHandler.java': '''package com.magmaguy.elitemobs;
public class MetadataHandler { public static final Plugin PLUGIN=new Plugin(); public static class Plugin { public boolean isEnabled(){return true;} public java.io.File getDataFolder(){return new java.io.File(".");} }}''',
      'com/magmaguy/elitemobs/config/DatabaseConfig.java': '''package com.magmaguy.elitemobs.config;
public class DatabaseConfig { public static boolean isUseMySQL(){return false;} public static String getMysqlHost(){return "";} public static int getMysqlPort(){return 0;} public static String mysqlDatabaseName=""; public static boolean useSSL=false; public static String getMysqlUsername(){return "";} public static String getMysqlPassword(){return "";} }''',
      'com/magmaguy/magmacore/util/Logger.java': '''package com.magmaguy.magmacore.util; public class Logger {public static void warn(String s){throw new AssertionError(s);} public static void info(String s){} }''',
      'org/bukkit/Bukkit.java': '''package org.bukkit;
public class Bukkit { public static final Scheduler SCHEDULER=new Scheduler(); public static Scheduler getScheduler(){return SCHEDULER;}
public static class Scheduler { public final java.util.concurrent.BlockingQueue<Runnable> tasks=new java.util.concurrent.LinkedBlockingQueue<>(); public void runTaskAsynchronously(Object plugin,Runnable task){tasks.add(task);} }}''',
      PACKAGE + '/PersistenceConcurrencyTest.java': '''package com.magmaguy.elitemobs.playerdata.database;
import java.lang.reflect.*; import java.sql.*; import java.util.*; import java.util.concurrent.*; import org.bukkit.Bukkit;
public class PersistenceConcurrencyTest {
 static final CountDownLatch entered=new CountDownLatch(1), release=new CountDownLatch(1);
 static final List<Object> written=new CopyOnWriteArrayList<>(); static boolean closed;
 static Object primitive(Class<?> t){ if(t==boolean.class)return false; if(t==int.class)return 0; if(t==long.class)return 0L; return null; }
 static Connection connection(){return (Connection)Proxy.newProxyInstance(PersistenceConcurrencyTest.class.getClassLoader(),new Class[]{Connection.class},(o,m,a)->{
  if(m.getName().equals("prepareStatement")){Object[] value={null};return Proxy.newProxyInstance(PersistenceConcurrencyTest.class.getClassLoader(),new Class[]{PreparedStatement.class},(s,n,b)->{
   if(n.getName().equals("setObject")){value[0]=b[1];return null;}
   if(n.getName().equals("executeUpdate")){if(written.isEmpty()){entered.countDown();if(!release.await(5,TimeUnit.SECONDS))throw new AssertionError("fixture timeout");} written.add(value[0]);return 1;}
   return primitive(n.getReturnType());});}
  if(m.getName().equals("close"))closed=true; return primitive(m.getReturnType());});}
 static void require(boolean condition,String message){if(!condition)throw new AssertionError(message);}
 public static void main(String[] args)throws Exception{
  Field field=PlayerDataRepository.class.getDeclaredField("connection");field.setAccessible(true);field.set(null,connection());
  UUID uuid=UUID.randomUUID();PlayerDataRepository.enqueueUpdate(uuid,"Kills",1);
  ExecutorService executor=Executors.newFixedThreadPool(3);
  Future<?> drain=executor.submit(Bukkit.SCHEDULER.tasks.remove());
  try {
   require(entered.await(2,TimeUnit.SECONDS),"JDBC did not start");
   Future<?> enqueue=executor.submit(()->PlayerDataRepository.enqueueUpdate(uuid,"Kills",2));
   enqueue.get(500,TimeUnit.MILLISECONDS);
   Future<?> state=executor.submit(()->{synchronized(PlayerDataRepository.monitor()) {}});
   state.get(500,TimeUnit.MILLISECONDS);
   require(Bukkit.SCHEDULER.tasks.isEmpty(),"more than one drainer scheduled");
   System.out.println("PASS enqueue and player-state monitor remain available during blocked JDBC");
  } finally {release.countDown();executor.shutdown();}
  drain.get(2,TimeUnit.SECONDS); require(written.equals(List.of(1,2)),"FIFO lost updates: "+written);
  PlayerDataRepository.enqueueUpdate(uuid,"Kills",3); require(Bukkit.SCHEDULER.tasks.size()==1,"idle drainer did not reschedule");
  Bukkit.SCHEDULER.tasks.remove().run(); require(written.equals(List.of(1,2,3)),"rescheduled update missing");
  PlayerDataRepository.enqueueUpdate(uuid,"Kills",4); PlayerDataRepository.close();
  require(written.equals(List.of(1,2,3,4))&&closed,"shutdown did not flush queued update before close");
  try{PlayerDataRepository.enqueueUpdate(uuid,"Kills; DROP",0);throw new AssertionError("invalid column accepted");}catch(IllegalArgumentException expected){}
  System.out.println("PASS FIFO, one worker, rescheduling, shutdown drain and invalid-column rejection");
 }
}''',
    }
    for name, text in files.items():
        target=work/name; target.parent.mkdir(parents=True,exist_ok=True); target.write_text(text)
    subprocess.run(['javac','--release','21','-d',str(work/'classes')]+[str(work/n) for n in files],check=True)
    subprocess.run(['java','-cp',str(work/'classes'),'com.magmaguy.elitemobs.playerdata.database.PersistenceConcurrencyTest'],check=True,timeout=15)
