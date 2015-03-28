require 'json'
require 'date'
require 'set'

database = JSON.parse `coffee main.coffee`

completed_on = {}

def item_text(database, item)
  text = item['name']
  if item['project']
    project = database['projects'].find{|p| p['id'] == item['project'] }
    text += " *[#{project['name']}]*"
  end
  if item['area']
    area = database['areas'].find{|p| p['id'] == item['area'] }
    text += " *[#{area['name']}]*"
  end
  if item['class'] == 'project'
    text = "**Project: " + text + "**"
  end
  text
end

ignore_names = JSON.parse(File.read('.ignore.json'))['ignore_tasks_in_log']

(database.values + database['projects'].map{|p| p['todos']}).flatten.
  select{|item| item['completionDate']}.
  reject{|item| ignore_names.include?(item['name'])}.
each do |item|
  date = Date.parse(item['completionDate']).to_s
  completed_on[date] ||= []
  completed_on[date] << item
end

completed_on.sort.reverse.each do |date, items|
  puts "## #{date}"
  puts
  items.uniq{|item| item['id']}.each do |item|
    puts "* " + item_text(database, item)
  end
  puts
end
