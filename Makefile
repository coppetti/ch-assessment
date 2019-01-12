
help:
	@echo "Usage:"
	@echo "1 - Start your db instance. At the time of the 1st run, it will download the docker image"
	@echo "make start-db"
	@echo ""
	@echo "2 - Load Instances. It will return 2 empty arrays, as no query was made to retrieve data from db"
	@echo "make load-instances"
	@echo ""
	@echo "3 - Load Events. It will return 2 empty arrays, as no query was made to retrieve data from db"
	@echo "make load-events"
	@echo ""
	@echo "4 - Get the list of uninstalled apps"
	@echo "make get-uninstalls"
	@echo ""
	@echo "5 - Kill db"
	@echo "make kill-db"
	@echo ""

start-db:
	@sudo docker run -d -p 7474:7474 -p 7687:7687 --name="db-app" coppetti/db-app
	@echo "Your db is being started, check when its ready accessing: http://localhost:7474. It could take a few seconds"
	@echo "user/pass: neo4j/password"

load-instances:
	@curl -X POST http://localhost:7474/db/data/cypher -H 'Authorization: Basic bmVvNGo6cGFzc3dvcmQ=' -H 'Content-Type: application/json' -H 'Postman-Token: b37d4a3c-23f3-442b-b51b-49f6f1b5dd56' -H 'cache-control: no-cache' -d '{"query" : "with {Jan:\"01\",Feb:\"02\",Mar:\"03\",Apr:\"04\",May:\"05\",Jun:\"06\",Jul:\"07\",Aug:\"08\",Sep:\"09\",Oct:\"10\",Nov:\"11\",Dec:\"12\"} as months, {_1:\"01\",_2:\"02\",_3:\"03\",_4:\"04\",_5:\"05\",_6:\"06\",_7:\"07\",_8:\"08\",_9:\"09\",_10:\"10\",_11:\"11\",_12:\"12\",_13:\"13\",_14:\"14\",_15:\"15\",_16:\"16\",_17:\"17\",_18:\"18\",_19:\"19\",_20:\"20\",_21:\"21\",_22:\"22\",_23:\"23\",_24:\"24\",_25:\"25\",_26:\"26\",_27:\"27\",_28:\"28\",_29:\"29\",_30:\"30\",_31:\"31\"} as days load csv with headers from \"https://raw.githubusercontent.com/chamatheapp/chama-data-engineer-assignment/master/Instances.csv\" as row with row,days,months, split(row.InstanceFirstSeenDateTime,'\'' '\'') as date merge (device:Device{id:row.DeviceId}) merge (datetime:EventDate{date:date[2]+'\''-'\''+months[date[0]]+'\''-'\''+days['\''_'\''+replace(date[1],'\'','\'','\'''\'')]}) merge (device)-[:HAS_EVENT{instance:row.Instance,eventType:\"Install\",datetime:date[2]+'\''-'\''+months[date[0]]+'\''-'\''+days['\''_'\''+replace(date[1],'\'','\'','\'''\'')]+'\'' '\''+date[3]}]->(datetime)","params" : { }}'
load-events:
	@curl -X POST http://localhost:7474/db/data/cypher -H 'Authorization: Basic bmVvNGo6cGFzc3dvcmQ=' -H 'Content-Type: application/json' -H 'Postman-Token: 416f959f-e2f8-4ca1-94b9-a84f0a9a1fc0' -H 'cache-control: no-cache' -d '{"query" : "with {Jan:\"01\",Feb:\"02\",Mar:\"03\",Apr:\"04\",May:\"05\",Jun:\"06\",Jul:\"07\",Aug:\"08\",Sep:\"09\",Oct:\"10\",Nov:\"11\",Dec:\"12\"} as months,{_1:\"01\",_2:\"02\",_3:\"03\",_4:\"04\",_5:\"05\",_6:\"06\",_7:\"07\",_8:\"08\",_9:\"09\",_10:\"10\",_11:\"11\",_12:\"12\",_13:\"13\",_14:\"14\",_15:\"15\",_16:\"16\",_17:\"17\",_18:\"18\",_19:\"19\",_20:\"20\",_21:\"21\",_22:\"22\",_23:\"23\",_24:\"24\",_25:\"25\",_26:\"26\",_27:\"27\",_28:\"28\",_29:\"29\",_30:\"30\",_31:\"31\"} as days load csv with headers from \"https://raw.githubusercontent.com/chamatheapp/chama-data-engineer-assignment/master/UninstallEvents.csv\" as row with row,days,months, split(row.EventDateTime,'\'' '\'') as date merge (device:Device{id:row.DeviceId}) merge (datetime:EventDate{date:date[2]+'\''-'\''+months[date[0]]+'\''-'\''+days['\''_'\''+replace(date[1],'\'','\'','\'''\'')]}) merge (device)-[:HAS_EVENT{eventType:\"Uninstall\",datetime:date[2]+'\''-'\''+months[date[0]]+'\''-'\''+days['\''_'\''+replace(date[1],'\'','\'','\'''\'')]+'\'' '\''+date[3]}]->(datetime)","params" : { }}'

get-uninstalls:
	@curl -X POST http://localhost:7474/db/data/cypher -H 'Authorization: Basic bmVvNGo6cGFzc3dvcmQ=' -H 'Content-Type: application/json' -H 'Postman-Token: d8216575-8369-48b6-9085-43e31324ccd3' -H 'cache-control: no-cache' -d '{"query" : "match (du:Device)-[eu:HAS_EVENT{eventType:\"Uninstall\"}]->(edu:EventDate) with du.id as device,edu.date as uninstallDate, eu.datetime as uninstallDateTime optional match (di:Device{id:device})-[ei:HAS_EVENT]->(:EventDate)  where uninstallDateTime > ei.datetime  with device,uninstallDateTime,collect(ei) as instance return instance[0].instance as Instance, device as Device,\"uninstall\" as Event, instance[0].datetime as InstanceFirstSeenDateTime, uninstallDateTime as EventDateTime","params" : { }}'

kill-db:
	@sudo docker stop db-app; docker rm db-app