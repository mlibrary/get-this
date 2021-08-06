require 'listen'
require 'byebug'

listener = Listen.to('css') do |modified, added, removed|
  puts(modified: modified, added: added, removed: removed)
  puts "copying css/index.css to public/bundles/index.css"
  `cp css/index.css public/bundles/index.css`
  puts "\n"
  puts "\n"
  
end
listener.start
sleep
