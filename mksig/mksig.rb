# coding: cp932

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) # スクリプトがあるパスをLOAD_PATHに登録する
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__))+'/../common_modules/')

require 'pp'
require 'optparse' # オプション解析
require 'signature_stamper'

Encoding.default_external = 'cp932'
Encoding.default_internal = 'cp932' # これないと文字化け（文字コード表示）になる。

options = Hash.new # オプション情報保持用
opt = OptionParser.new
# オプション初期値
options[:back_color] = 0xffffffff # 白
options[:font_color] = 0xffff0000 # 赤
options[:circle_type] = 'double' # ダブル
options[:rotate_degrees] = 0 #
options[:outfilepath] = 'tmp.png'
opt.on('-o VAL', '--outfile VAL') {|val| options[:outfilepath] = val }
opt.on('-b VAL', '--back_color VAL') {|val| options[:back_color] = val.hex }
opt.on('-f VAL', '--font_color VAL') {|val| options[:font_color] = val.hex }
opt.on('-c VAL', '--circle_type VAL') {|val| options[:circle_type] = val }
opt.on('-r VAL', '--rotate_degrees VAL') {|val| options[:rotate_degrees] = val }
opt.on('-s VAL', '--special_mode VAL') {|val| options[:special_mode] = val }
argv = opt.parse(ARGV)

puts "mksig version 0.2014.0903.1315"
if argv.length != 3 then
    puts "usage: mksig [options] <top string> <middle string> <bottom string>"
    puts " [options] -o [--outfile]        : output file name."
    puts "           -f [--font_color]     : font color(argb 32bit). default is 0xffffffff."
    puts "           -b [--back_color]     : back color(argb 32bit). default is 0xffff0000."
    puts "           -c [--circle_type]    : circle type('double' or 'single'). default is 'dobule'"
    puts "           -r [--rotate_degrees] : rotate degrees(0-360). default is 0."
    exit
end

$inparam = Hash.new
$inparam[:top_string] = argv[0]
$inparam[:mid_string] = argv[1]
$inparam[:btm_string] = argv[2]

options.each do |(key,value)|
    if( key == :outfilepath ) then
        next
    end
    $inparam[key] = options[key]
end

# 内容確認
pp $inparam

# ハンコ作成
signatureStamper = SignatureStamper::new($inparam)
signatureStamper.export_to_png(options[:outfilepath])

puts 'complete.'
