# A script to generate the
require "alma_rest_client"
require "json"
require "tempfile"

alma_client = AlmaRestClient.client

hours_response = alma_client.get("/conf/open-hours")

exit if hours_response.status != 200

File.write("/app/config/institution_hours_exceptions.json", JSON.pretty_generate(hours_response.body))
