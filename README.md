# Get This

Implements date picker for booking a media item

## Setting up Get This for development

Clone the repo

```
git clone git@github.com:mlibrary/get-this.git
cd get-this
```

copy .env-example to .env

```
cp .env-example .env
```

edit .env with the following environment variables.

```ruby
#.env
ALMA_API_KEY='YOURAPIKEY'
ALMA_API_HOST='https://api-na.hosted.exlibrisgroup.com'
```

build container

```
docker-compose build
```

bundle install

```
docker-compose run --rm web bundle install
```

npm install

```
docker-compose run --rm npm install
```

build css

```
docker-compose run --rm npm run build
```

start containers

```
docker-compose up -d
```

run npm scriptss directly

```
docker compose run --rm web bash
...
$ npm run build
...
exit
```
