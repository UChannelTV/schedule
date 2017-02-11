require_relative '../lib/final_schedule_import'

fsi = FinalScheduleImporter.new(ARGV[0])
fsi.import(ARGV[1], ARGV[2])

