require_relative '../lib/final_schedule_import'

fsi = FinalScheduleImporter.new("http://ec2-54-153-1-235.us-west-1.compute.amazonaws.com")
date = Date.today.prev_day
fsi.import(1, "%04d-%02d-%02d" % [date.year, date.month, date.day])

