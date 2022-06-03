require "listen"

listener = Listen.to("js") do |modified, added, removed|
  puts(modified: modified, added: added, removed: removed)
  puts "copying js/* to public/bundles/*"
  `cp js/* public/bundles/`
  puts "\n"
  puts "\n"
end
listener.start
sleep
