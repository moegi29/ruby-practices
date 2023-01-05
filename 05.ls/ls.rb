# frozen_string_literal: true

COLUMN_COUNT = 3

def main
  files = Dir.glob('*')

  transposed_files = make_transposed_files(files)

  max_file_size = files.map(&:size).max
  output_files(transposed_files, max_file_size)
end

def make_transposed_files(files)
  row_count = (files.size.to_f / COLUMN_COUNT).ceil
  nested_files = files.each_slice(row_count).to_a
  nested_files.each do |file_names|
    file_names << nil while file_names.size < row_count
  end
  nested_files.transpose
end

def output_files(transposed_files, max_file_size)
  transposed_files.each do |file_names|
    file_names.each do |file_name|
      print file_name.to_s.ljust(max_file_size + 1)
    end
    print "\n"
  end
end

main