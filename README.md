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

edit .env with actual environment variables; ask a developer if you need them

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

build the css

```
docker-compose run --rm web npm run build
```

start containers
```
docker-compose up -d
```


## Updating `institution_hours_exceptions.json`

`config/institution_hours_exceptions.json` is a static file that needs to be updated yearly.

### Steps

1. Verify that you are using a production Alma API Key.

2. Run the script

```
docker-compose run --rm web ruby bin/update_alma_config.rb
```

The file `config/institution_hours_exceptions.json` will get replaced with the latest information.

3. Commit the file and go through the app release process. 
