# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) # スクリプトがあるパスをLOAD_PATHに登録する
# $LOAD_PATH.push(File.expand_path(File.dirname(__FILE__))+'/../common_modules/')

require 'pry'
require 'optparse' # オプション解析

puts "update_timestamp version 0.2021.0506"

options = Hash.new # オプション情報保持用
opt = OptionParser.new
# オプション初期値
options[:extension] = "avi"
opt.on('-e VAL', '--extension VAL') {|val| options[:extension] = val }
argv = opt.parse(ARGV)

if argv.length != 1 then
  puts "usage: update_timestamp [options] <target path>"
  puts " [options] -e [--extension]        : file extension. default is 'avi'"
  exit
end

$inparam = Hash.new
$inparam[:target_path] = argv[0].gsub(/\\/,'/')

targets = Array.new
# Dir.glob('./in/*.txt').each do |fn|
Dir.glob("#{$inparam[:target_path]}/**/*.#{options[:extension]}") do |file|
  targets << file
end

targets.each do |file|
  # ".2002-03-30_14-24.00.avi"
  if file =~ /(\d{4})\-(\d{2})-(\d{2})_(\d{2})\-(\d{2})/
    timestamp = "#{$1}/#{$2}/#{$3} #{$4}:#{$4}:00"
    # Set-ItemProperty "C:\hoge.txt" -Name LastWriteTime -Value "2015/01/01 10:20:30"
    # Set-ItemProperty "C:\hoge.txt" -Name LastWriteTime -Value "2015/01/01 10:20:30"
    puts `powershell -Command \"Set-ItemProperty '#{file}' -Name LastWriteTime -Value '#{timestamp}'\"`
    puts `powershell -Command \"Set-ItemProperty '#{file}' -Name CreationTime  -Value '#{timestamp}'\"`
    
    puts "powershell -Command \"Set-ItemProperty '#{file}' -Name LastWriteTime -Value '#{timestamp}'\""
    puts "powershell -Command \"Set-ItemProperty '#{file}' -Name CreationTime  -Value '#{timestamp}'\""
  end
end

puts 'complete.'
