require_relative '../lib/telvue_parser'
require_relative '../lib/video_import'


vi = VideoImport.new(ARGV[0])
tp = TelVueParser.new

videos = tp.getContent
puts videos.size

vi.importTelVueVideos(videos)


