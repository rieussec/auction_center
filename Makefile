start:
	docker-compose up -d

stop:
	docker-compose stop
	rm -f tmp/pids/server.pid

build:
	docker-compose up -d --build --remove-orphans

setup:
	docker exec -it auction bundle exec rake db:setup

jobs:
	docker exec -it auction bundle exec rake jobs:work

destroy:
	docker rm $(docker ps -a -q)

logs:
	docker-compose logs -f

