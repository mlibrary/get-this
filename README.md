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
#.env/development/web
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

start containers

```
docker-compose up -d
```
