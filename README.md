# Get This

Implements date picker for booking a media item

## Setting up Get This for development

Clone the repo

```
git clone git@github.com:mlibrary/get-this.git
cd get-this
```

run the `init.sh` script. 
```bash
./init.sh
```

edit .env with the appropriate environment variables 

start containers

```bash
docker compose up -d
```

## Updating `institution_hours_exceptions.json`

`config/institution_hours_exceptions.json` is a static file that needs to be updated yearly.

### Steps

1. Verify that you are using a production Alma API Key.

2. Run the script

```
docker compose run --rm web ruby bin/update_alma_config.rb
```

The file `config/institution_hours_exceptions.json` will get replaced with the latest information.

3. Commit the file and go through the app release process. 
