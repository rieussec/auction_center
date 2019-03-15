start:
	docker-compose up -d

stop:
	docker-compose stop

build:
	docker-compose up -d --build --remove-orphans

setup:
	docker exec -it auction bundle exec rake db:setup RAILS_ENV=production 

destroy:
	docker rm $(docker ps -a -q)

log:
	docker-compose logs -f	
