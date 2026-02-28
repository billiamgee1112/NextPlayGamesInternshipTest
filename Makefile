.PHONY: install test lint build docker

install:
	python -m pip install -r services/python_app/requirements.txt; cd services/node_app; npm install

test:
	pytest -q; cd services/node_app; npm test

build:
	cd services/node_app; npm run build

docker:
	docker-compose -f docker-compose.yml up --build
