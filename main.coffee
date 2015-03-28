osascript = require('node-osascript')
_ = require('underscore')
moment = require('moment')
jQuery = require('jquery-deferred')

dateFormat = 'dddd, MMMM DD, YYYY at HH:mm:ss'

things =
  inbox: 'to do of list "Inbox"'
  today: 'to do of list "Today"'
  next: 'to do of list "Next"'
  scheduled: 'to do of list "Scheduled"'
  someday: 'to do of list "Someday"'
  projects: 'project'
  areas: 'area'
  logbook: 'to do of list "Logbook"'
  trash: 'to do of list "Trash"'

cleanupItems = (items) ->
  _.map items, (item) ->
    newItem = {}
    _.each _.keys(item), (key) ->
      value = item[key]
      newKey = key.replace(/\s[a-z]/, (match) -> match[1].toUpperCase())
      if value == 'missing value'
        newItem[newKey] = null
      else if key.match " date$"
        newItem[newKey] = moment(value, dateFormat).format(moment.ISO8601)
      else if key == 'project' || key == 'area'
        newItem[newKey] = value.split('"', 3)[1]
      else
        newItem[newKey] = value
    newItem

getThings = (thing, name) ->
  ((deferred) ->
    command = "tell application \"Things\"\n
               return properties of every #{thing}\n
               end tell"
    osascript.execute command, (err, result, raw) ->
      if err
        deferred.reject(err)
      else
        obj = {}
        obj[name] = cleanupItems(result)
        deferred.resolve(obj)
    return deferred.promise()
  )(jQuery.Deferred())

jQuery.when.apply(null, _.map(things, getThings)).done () ->
  database = _.reduce(arguments, (all, one) ->
    _.extend(all, one)
  , {})

  jQuery.when.apply(null, _.map(database.projects, (project) ->
    getThings("to do of project id \"#{project.id}\"", 'projectTodos').done (result) ->
      project.todos = result.projectTodos
  )).done () ->
    process.stdout.write JSON.stringify database

# crazy date parsing stuff
# to iso8601 for aDate
#   set {year:y, month:m, day:d, hours:h, minutes:mm, seconds:s} to aDate
#   tell ((y * 10000 + m * 100 + d) as string) & ((h * 10000 + mm * 100 + s) as string) to text 1 thru 4 & "." & text 5 thru 6 & "." & text 7 thru 8 & " " & text 9 thru 10 & ":" & text 11 thru 12 & ":" & text 13 thru 14

# end iso8601

# tell application "Things"
#   set pp to properties of every to do
#   repeat with p in pp
#     copy p to x
#     set d to cancellation date of x
#     if d is not equal to missing value then
#       set cd to iso8601 for d
#     end if
#   end repeat
#   return pp
# end tell
