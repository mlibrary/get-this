require 'listen'
require 'byebug'

listener = Listen.to('css') do |modified, added, removed|
  puts(modified: modified, added: added, removed: removed)
  puts "copying css/get-this.css to public/bundles/get-this.css"
  `cp css/get-this.css public/bundles/get-this.css`
  puts "\n"
  puts "\n"
  
end
listener.start
sleep
