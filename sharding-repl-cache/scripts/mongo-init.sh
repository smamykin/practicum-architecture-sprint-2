#!/bin/bash -ex

###
# Инициализируем бд
###

#docker compose exec -T mongodb1 mongosh <<EOF
#use somedb
#for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})
#EOF

#---

#docker exec -it configSrv mongosh --port 27017

#> rs.initiate(
#  {
#    _id : "config_server",
#       configsvr: true,
#    members: [
#      { _id : 0, host : "configSrv:27017" }
#    ]
#  }
#);
#> exit();



docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
EOF

#docker exec -it shard1 mongosh --port 27018

#> rs.initiate(
#    {
#      _id : "shard1",
#      members: [
#        { _id : 0, host : "shard1:27018" },
#       // { _id : 1, host : "shard2:27019" }
#      ]
#    }
#);
#> exit();

#docker exec -it shard2 mongosh --port 27019
#
#> rs.initiate(
#    {
#      _id : "shard2",
#      members: [
#       // { _id : 0, host : "shard1:27018" },
#        { _id : 1, host : "shard2:27019" }
#      ]
#    }
#  );
#> exit();


docker compose exec -T shard1-1 mongosh --port 27018 --quiet <<EOF
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1-1:27018" },
       // { _id : 1, host : "shard2-1:27019" }
        { _id : 2, host : "shard1-2:27021" },
        { _id : 3, host : "shard1-3:27022" },
       //{ _id : 4, host : "shard2-2:27023" },
       //{ _id : 5, host : "shard2-3:27024" }
      ]
    }
);
EOF

docker compose exec -T shard2-1 mongosh --port 27019 --quiet <<EOF
rs.initiate(
    {
      _id : "shard2",
      members: [
       //{ _id : 0, host : "shard1-1:27018" },
       { _id : 1, host : "shard2-1:27019" },
       //{ _id : 2, host : "shard1-2:27021" },
       //{ _id : 3, host : "shard1-3:27022" },
       { _id : 4, host : "shard2-2:27023" },
       { _id : 5, host : "shard2-3:27024" }
      ]
    }
);
EOF

#docker exec -it mongos_router mongosh --port 27020
#
#> sh.addShard( "shard1/shard1:27018");
#> sh.addShard( "shard2/shard2:27019");
#
#> sh.enableSharding("somedb");
#> sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
#
#> use somedb
#
#> for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
#
#> db.helloDoc.countDocuments() 
#> exit();


sleep 4s

docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
sh.addShard( "shard1/shard1-1:27018");
sh.addShard( "shard2/shard2-1:27019");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )

use somedb

for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})

db.helloDoc.countDocuments() 
EOF
