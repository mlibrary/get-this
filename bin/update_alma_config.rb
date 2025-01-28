# A script to generate the
require "alma_rest_client"
require "json"
require "tempfile"

config_path = File.absolute_path(File.join(__dir__, "../", "/config", "/institution_hours_exceptions.json"))
alma_client = AlmaRestClient.client

hours_response = alma_client.get("/conf/open-hours")

exit if hours_response.status != 200

File.write(config_path, JSON.pretty_generate(hours_response.body))
