# coding: cp932

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) # �X�N���v�g������p�X��LOAD_PATH�ɓo�^����
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__))+'/../common_modules/')

require 'pp'
require 'optparse' # �I�v�V�������
require 'signature_stamper'

Encoding.default_external = 'cp932'
Encoding.default_internal = 'cp932' # ����Ȃ��ƕ��������i�����R�[�h�\���j�ɂȂ�B

options = Hash.new # �I�v�V�������ێ��p
opt = OptionParser.new
# �I�v�V���������l
options[:back_color] = 0xffffffff # ��
options[:font_color] = 0xffff0000 # ��
options[:circle_type] = 'double' # �_�u��
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

# ���e�m�F
pp $inparam

# �n���R�쐬
signatureStamper = SignatureStamper::new($inparam)
signatureStamper.export_to_png(options[:outfilepath])

puts 'complete.'
