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
ALMA_API_KEY='YOUR-ALMA-API-KEY'
ALMA_API_HOST='https://api-na.hosted.exlibrisgroup.com'
RACK_COOKIE_SECRET='rack_cookie_secret'
GET_THIS_BASE_URL='http://localhost:4567'
WEBLOGIN_SECRET='YOUR-WEBLOGIN-SECRET'
WEBLOGIN_ID='YOUR-WEBLOGIN-ID'
WEBLOGIN_ON='false'
ACCOUNT_URL='https://account.lib.umich.edu'
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
docker-compose run --rm web npm install
```

build css

```
docker-compose run --rm web npm run build
```

start containers

```
docker-compose up -d
```

run npm scripts directly

```
docker compose run --rm web bash
...
$ npm run build
...
exit
```
