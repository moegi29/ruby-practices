# frozen_string_literal: true

require 'optparse'
require 'etc'

COLUMN_COUNT = 3

FILE_TYPE = {
  'file' => '-',
  'link' => 'l',
  'directory' => 'd'
}.freeze

PERMISSION_TYPE = {
  '0' => '---',
  '1' => '--x',
  '2' => '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze

def main
  options = ARGV.getopts('arl')
  files = options['a'] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
  sorted_files = options['r'] ? files.reverse : files
  options['l'] ? output_for_long_format(sorted_files) : output_for_short_format(sorted_files)
end

def output_for_long_format(files)
  output_total_block_count(files)
  output_long_formatted_files(files)
end

def output_for_short_format(files)
  transposed_files = build_transposed_files(files)
  max_file_size = files.map(&:size).max
  output_short_formatted_files(transposed_files, max_file_size)
end

def build_transposed_files(files)
  row_count = (files.size.to_f / COLUMN_COUNT).ceil
  nested_files = files.each_slice(row_count).to_a
  nested_files.each do |file_names|
    file_names << nil while file_names.size < row_count
  end
  nested_files.transpose
end

def output_short_formatted_files(transposed_files, max_file_size)
  transposed_files.each do |file_names|
    file_names.each do |file_name|
      print file_name.to_s.ljust(max_file_size + 1)
    end
    print "\n"
  end
end

def output_total_block_count(files)
  total_block_count = files.sum { |file_count| File.lstat(file_count).blocks }
  puts "total #{total_block_count}"
end

def build_permission(stat_file)
  permission_value = stat_file.mode.to_s(8).slice(-3, 3)
  permission_types = permission_value.each_char.map do |file_count|
    PERMISSION_TYPE[file_count]
  end
  permission_types.join('')
end

def output_long_formatted_files(files)
  files.each do |file|
    stat_file = File.stat(file)
    output_data = [
      FILE_TYPE[stat_file.ftype] + build_permission(stat_file),
      stat_file.nlink,
      Etc.getpwuid(stat_file.uid).name,
      Etc.getgrgid(stat_file.gid).name,
      stat_file.size.to_s.rjust(4),
      stat_file.mtime.strftime('%b %d %H:%M'),
      file
    ]
    puts output_data.join(' ')
  end
end

main
