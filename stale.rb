require 'json'
require 'date'
require 'set'

database = JSON.parse `coffee main.coffee`

ignore_project_names = JSON.parse(File.read('.ignore.json'))['projects_that_are_not_stale']
ignored_project_ids = database['projects'].select{|pr| ignore_project_names.include?(pr['name'])}.map{|pr| pr['id']}

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

def stale_items(database, ignored_project_ids, date_field)
  (database.values + database['projects'].map{|p| p['todos']}).flatten.
    reject{|item| item['completionDate']}.
    reject{|item| ignored_project_ids.include? item['project']}.
    reject{|item| database['trash'].find{|tr| tr['id'] == item['id'] || tr['id'] == item['project']}}.
    reject{|item| item['class'] == 'project' || item['class'] == 'area' }.
    uniq{|item| item['id']}.map do |item|
      date = Date.parse(item[date_field])
      staleness = (Date.today - date).to_i
      if staleness > 7
        [staleness, item]
      else
        nil
      end
    end.compact.sort_by{|(staleness, _item)| staleness}.reverse
end

stale_not_touched = stale_items(database, ignored_project_ids, 'modificationDate')
stale_touched = stale_items(database, ignored_project_ids, 'creationDate').
  reject{|(_, i)| stale_not_touched.find{|(_,si)| i['id']==si['id']}}

puts "## Stale and not even touched\n\n"

stale_not_touched.each do |(staleness, item)|
  puts "* " + item_text(database, item) + " - **#{staleness} days**"
end

puts "\n\n## Stale but shuffled around\n\n"

stale_touched.each do |(staleness, item)|
  puts "* " + item_text(database, item) + " - **#{staleness} days**"
end
