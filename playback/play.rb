require 'optparse'
require 'fileutils'

TMP_DIR = File.join('/tmp', 'ktv_playback')

SILENCE_OUTPUT = ' 2>&1 >/dev/null'
EXTRACT_AUDIO_CMD = 'mplayer "%s" -ao pcm:fast:file=%s -vo null -vc null -aid 1' + SILENCE_OUTPUT
TRANSPOSE_CMD = 'rubberband -p%d "%s" "%s"' + SILENCE_OUTPUT
PLAYBACK_SEPARATE_CMD = 'mplayer "%s" -audiofile "%s" -delay -0.5' + SILENCE_OUTPUT
TMP_AUDIO_FILE = File.join(TMP_DIR, 'audio.wav')
TMP_TRANSPOSED_AUDIO_FILE = File.join(TMP_DIR, 'transposed_audio.wav')

FileUtils.mkdir_p(TMP_DIR)

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

options[:transpose] = options[:transpose_up] if options[:transpose_up]
options[:transpose] = -options[:transpose_down] if options[:transpose_down]

if options[:transpose]
  puts 'Extracing audio...'
  `#{EXTRACT_AUDIO_CMD % [file, TMP_AUDIO_FILE]}`
  puts 'Transposing audio...'
  `#{TRANSPOSE_CMD % [options[:transpose], TMP_AUDIO_FILE, TMP_TRANSPOSED_AUDIO_FILE]}`
  puts 'Playing...'
  `#{PLAYBACK_SEPARATE_CMD % [file, TMP_TRANSPOSED_AUDIO_FILE]}`
end
