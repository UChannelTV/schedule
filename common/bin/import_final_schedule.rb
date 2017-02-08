require_relative '../lib/final_schedule_import'

fsi = FinalScheduleImporter.new(ARGV[0])
fsi.import(false, ARGV[1], 1, ARGV[2])

