#!/bin/bash
read -p 'enter "c" for create "d" for delete: ' IN
read -p 'enter volume: ' VOLUME
read -p 'enter dir: ' SUB 
DIR=/data/bricks/$SUB 

if [ "$IN" == "c" ]; then 
  read -p 'enter user: ' USER 
  read -p 'enter group: ' GROUP 
  for i in gfs1 gfs2 gfs3 ; do 
    ssh $i mkdir $DIR
    ssh $i chown $USER:$GROUP $DIR
    ssh $i semanage fcontext -a -t fusefs_t $DIR
    ssh $i restorecon -v $DIR
    ls -ldZ $DIR
  done
  gluster volume create $VOLUME replica 3 gfs1:$DIR gfs2:$DIR gfs3:$DIR
  gluster volume set $VOLUME auth.allow $CLIENTS_IPS
  gluster volume start $VOLUME
elif [ "$IN" == "d" ]; then
  gluster volume stop $VOLUME
  gluster volume delete $VOLUME
  for i in gfs1 gfs2 gfs3 ; do
    rm -rf $DIR
   done
else
  echo "enter \"c\" for create or \"d\" for delete "
  exit 0
fi
