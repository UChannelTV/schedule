require_relative '../lib/telvue_parser'
require_relative '../lib/video_import'


vi = VideoImport.new(ARGV[0])
tp = TelVueParser.new

files = []
1.upto(11) do |n|
  files << ("Html/%02d.html" % [n])
end

videos = tp.getFromFiles(files)
puts videos.size

vi.importTelVueVideos(videos)


