require 'optparse'
require 'fileutils'

require_relative 'player'
require_relative 'preprocessors/transposer'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: play.rb <video_file> [options]"

  opts.on("-u", "--transpose-up [SEMITONES]", Integer, "Transpose the audio up by the number of semitones specified. ") do |t|
    options[:transpose_up] = t
  end

  opts.on("-d", "--transpose-down [SEMITONES]", Integer, "Transpose the audio down by the number of semitones specified. ") do |t|
    options[:transpose_down] = t
  end
end.parse!

file = ARGV[0]
player = KTV::Playback::Player.new(file)

options[:transpose] = options[:transpose_up] if options[:transpose_up]
options[:transpose] = -options[:transpose_down] if options[:transpose_down]

if options[:transpose]
  player.add_preprocessor(KTV::Playback::Preprocessors::Transposer.new(options[:transpose]))
end

player.preprocess
player.play
player.cleanup
