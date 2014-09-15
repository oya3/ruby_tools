# coding: cp932

require 'cairo'
require 'pango'
require 'stringio'
require 'win32/clipboard'

Encoding.default_external = 'cp932'
Encoding.default_internal = 'cp932' # ����Ȃ��ƕ��������i�����R�[�h�\���j�ɂȂ�B

class Signature
    #�N���X�萔
    #PI2 = Math::PI*2 # 360�x�p
    DEFAULT_SIZE = 200
    def initialize( param = nil)
        @inparam = createInitialParameter() # �f�t�H���g�l�ݒ�
        setParameter(@inparam,param)
        @surface = createSignatureImage(@inparam) #  ���q�摜�� Cairo::ImageSurface ���쐬
    end
    
    # �����p�����[�^�𐶐�����
    def createInitialParameter()
        param = {}
        param[:format] = Cairo::FORMAT_ARGB32
        param[:size] = DEFAULT_SIZE
        param[:line_angle] = 20
        param[:back_color] = 0xffffffff # ��
        param[:font_color] = 0xffff0000 # ��
        param[:circle_type] = 'double' # or single
        param[:rotate_degrees] = 0 # 0-360
        #param[:special_mode] = 0 #
        
        param[:top_font] = 'HGSeikaishotaiPRO'
        param[:mid_font] = 'Arial'
        param[:btm_font] = 'HGSeikaishotaiPRO'
        
        param[:top_string] = '�f�l'
        param[:mid_string] = '\'13.10.02'
        param[:btm_string] = '����'
        
        param[:tx] = 0
        param[:ty] = 0
        return param
    end
    
    # �p�����[�^��ݒ肷��
    def setParameter(param,args)
        # �w�肳�ꂽ�p�����[�^�ōX�V����
        if ( args ) then
            args.each do | (key , value ) |
                param[key] = value
            end
        end
        #param[:size] = 500
        
        # �v���Z�X���Ԃ���K���Ƀ����_���L�[����
        param[:seed] = Time.new().usec
        random = nil
        
        # �w�肪����΂��̒l�Ń����_���L�[�Ƃ���
        if( param[:special_mode] ) then 
            if( param[:special_mode].to_i != 0 ) then
                param[:seed] = param[:special_mode].to_i
            end
            random = Random.new(param[:seed])
        end
        
        # calc image size paramter
        param[:diameter_big] =  param[:size] * 80 / 100 # ��g�͑S�̂�80% # �c��20%���s�ړ��ʕ��ɂƂ��Ă����B�����ڂ������̂ŁB
        param[:diameter] =  param[:size] * 72 / 100 # ���g�͑S�̂�72%
        param[:line_size] = param[:diameter] / 45 # ���̑����͓K��
        param[:date_font_size] = param[:diameter] / 7 # ���t�t�H���g�T�C�Y���K��
        param[:font_size] = param[:diameter] / 5 # �t�H���g�T�C�Y���K��
        
        param[:width] = param[:size]
        param[:height] = param[:size]
        param[:center_x] = param[:width] / 2
        param[:center_y] = param[:height] / 2
        param[:radius_big] = param[:diameter_big] / 2 # �O���̔��a
        param[:radius] = param[:diameter] / 2 # �����̔��a
        
        # set background color.
        param[:back_color_red] = getRed(param[:back_color])
        param[:back_color_green] = getGreen(param[:back_color])
        param[:back_color_blue] = getBlue(param[:back_color])
        param[:back_color_alpha] =  getAlpha(param[:back_color])
        # set font color.
        param[:font_color_red] = getRed(param[:font_color])
        param[:font_color_green] = getGreen(param[:font_color])
        param[:font_color_blue] = getBlue(param[:font_color])
        param[:font_color_alpha] = getAlpha(param[:font_color])
        
        # font size ( �������͍ő�P�O�����܂łƂ��Ȃ�Ƃ����܂����B���j�A�Ɍv�Z����Ɣ��q�炵���Ȃ�Ȃ��B�B�B�j
        param[:scale] = param[:size].to_f / DEFAULT_SIZE.to_f
        param[:top_string_info] = createStringInfo(param[:top_font], param[:top_string], param[:font_color], param[:scale], random)
        param[:btm_string_info] = createStringInfo(param[:btm_font], param[:btm_string], param[:font_color], param[:scale], random)
        param[:mid_string_info] = createStringInfo(param[:mid_font], param[:mid_string], param[:font_color], param[:scale], random)
        #param[:top_string_font_size] = param[:font_size]
        #param[:mid_string_font_size] = param[:date_font_size]
        #param[:btm_string_font_size] = param[:font_size]
        
        if( random ) then 
            # ���ꏈ���F�p�x+���s�ړ��l����
            param[:rotate_degrees] = random.rand(30) - 15 # -15 �` 15�x
            param[:tx] = random.rand( param[:center_x]/4) - (param[:center_x]/8)
            param[:ty] = random.rand( param[:center_y]/4) - (param[:center_y]/8)
        end
        param[:random] = random
    end
    
    # �\����������𐶐�
    def createStringInfo(font, string, font_color,scale,random)
        #                            0,  1,  2,  3,  4,  5,  6,  7,  8,  9
        font_size_table         = [ 28, 28, 26, 23, 19, 17, 15, 13, 12, 11 ]
        font_size_table_xoffset = [  0,  0,  3,  4,  4,  3,  3,  2,  2,  3 ]
        
        stringInfo = Hash.new
        stringInfo[:length] = string.length > 10 ? 10: string.length
        stringInfo[:font] = font
        stringInfo[:string] = string
        stringInfo[:string_yoffset] = Array.new(string.length,0) # �[������
        if( random ) then
            range = (4 * scale).to_i
            string.length.to_i.times do |index|
                stringInfo[:string_yoffset][index] = random.rand(range)-(range/2)
            end
        end
        stringInfo[:font_color_red]   = getRed(font_color)
        stringInfo[:font_color_green] = getGreen(font_color)
        stringInfo[:font_color_blue]  = getBlue(font_color)
        stringInfo[:font_color_alpha] = getAlpha(font_color)
        if( stringInfo[:string] =~ /^[ -~�-�]*$/ ) then
            # �S�����p�̏ꍇ�́A1.7�{���Ă���
            stringInfo[:font_size] = ((font_size_table[stringInfo[:length]-1] * scale) * 1.7).to_i
            stringInfo[:xoffset]   = ((font_size_table_xoffset[stringInfo[:length]-1] * scale) * 1.0).to_i
            if( stringInfo[:string] =~ /^[0-9'.,]*$/ ) then
                # ���t�����ۂ���͕\���ʒu�����I�t�Z�b�g�͐ݒ肵�Ȃ�
                stringInfo[:xoffset] = 0
            end
        else
            stringInfo[:font_size] = (font_size_table[stringInfo[:length]-1] * scale).to_i
            stringInfo[:xoffset] = (font_size_table_xoffset[stringInfo[:length]-1] * scale).to_i
        end
        return stringInfo
    end
    
    # �A���t�@�̗v�f�擾
    def getAlpha(argb)
        return ((argb & 0xff000000) >> 24).to_f / 255.0
    end
    
    # �Ԃ̗v�f�擾
    def getRed(argb)
        return ((argb & 0x00ff0000) >> 16).to_f / 255.0
    end
    
    # �΂̗v�f�擾
    def getGreen(argb)
        return ((argb & 0x0000ff00) >> 8).to_f / 255.0
    end
    
    # �̗v�f�擾
    def getBlue(argb)
        return (argb & 0x000000ff).to_f / 255.0
    end
    
    def getPos(angle, radius)
        x = Math.cos(Math::PI*angle/180) * radius
        y = Math.sin(Math::PI*angle/180) * radius
        return x, y
    end
    
    def drawBackground(context, param)
        # �w�i
        context.set_source_rgba( param[:back_color_red], param[:back_color_green], param[:back_color_blue], param[:back_color_alpha] )
        # ��]�����l�����ė]��������ɓh��ׂ��Ă����i���[�g�Q(1.41...)�ł����͂��j
        context.rectangle(0-param[:center_x], 0-param[:center_y], param[:width]+(param[:center_x]*2), param[:height]+(param[:center_y]*2))
        context.fill
    end
    
    # ���q�g��`��
    def drawCircle(context, param)
        # ���
        if( param[:circle_type] == 'double' ) then
            context.set_source_rgba(param[:font_color_red], param[:font_color_green], param[:font_color_blue], param[:font_color_alpha] )
            context.move_to( param[:center_x] + param[:radius_big], param[:center_y]) # �~�����o���ʒu���w��i���ꂪ�Ȃ��ƑO��̈ʒu���璼�����`�悳���
            context.arc(param[:center_x], param[:center_y], param[:radius_big], 0, 2 * Math::PI)
            context.stroke # ����h��
        end
        
        # ��
        context.set_source_rgba(param[:font_color_red], param[:font_color_green], param[:font_color_blue], param[:font_color_alpha])
        context.move_to( param[:center_x] + param[:radius], param[:center_y]) # �~�����o���ʒu���w��i���ꂪ�Ȃ��ƑO��̈ʒu���璼�����`�悳���
        context.arc(param[:center_x], param[:center_y], param[:radius], 0, 2 * Math::PI)
        context.stroke # ����h��
    end
    
    # ������`��(�m�[�}��)
    def drawString(context, stringInfo, x, y, type='down')
        context.set_source_rgba(stringInfo[:font_color_red], stringInfo[:font_color_green], stringInfo[:font_color_blue], stringInfo[:font_color_alpha] )
        layout = context.create_pango_layout
        layout.set_font_description(Pango::FontDescription.new("#{stringInfo[:font]} #{stringInfo[:font_size]}"))
        layout.text = stringInfo[:string].encode('utf-8')
        *psize = layout.pixel_size
        toX = 0
        stringInfo[:string].gsub(/[��]/){ toX += stringInfo[:xoffset] } # ���p�̏ꍇ�̓��ʏ���
        sx = x - (psize[0]/2) + ( ((stringInfo[:xoffset] * (stringInfo[:length]-1))) / 2 ) + toX
        sy = y
        if( type == 'up' ) then
            sy -= psize[1]
        elsif( type == 'center' ) then
            sy -= (psize[1]/2)
        end
        stringInfo[:string].each_char.with_index do |str,index|
            layout = context.create_pango_layout
            layout.set_font_description(Pango::FontDescription.new("#{stringInfo[:font]} #{stringInfo[:font_size]}"))
            layout.text = str.encode('utf-8')
            *psize = layout.pixel_size
            context.move_to(sx, sy)
            sx += psize[0] - stringInfo[:xoffset]
            str.sub(/[��]/){ sx -= stringInfo[:xoffset] } # [��] �͂���Ɋ񂹂�
            next if( str =~ /\s/ )
            context.show_pango_layout(layout)
        end
    end
    
    # ������`��(���t������炵���`�悷��)
    def drawStringForDate(context, stringInfo, x, y, type='down')
        context.set_source_rgba(stringInfo[:font_color_red], stringInfo[:font_color_green], stringInfo[:font_color_blue], stringInfo[:font_color_alpha] )
        layout = context.create_pango_layout
        layout.set_font_description(Pango::FontDescription.new("#{stringInfo[:font]} #{stringInfo[:font_size]}"))
        layout.text = stringInfo[:string].tr("\s","0").encode('utf-8') # �X�y�[�X�͐��l�̔��p�[���Ƃ��ĕ����v�Z���Ă���
        *psize = layout.pixel_size
        toX = 0
        stringInfo[:string].gsub(/[��]/){ toX += stringInfo[:xoffset] } # ���p�̏ꍇ�̓��ʏ���
        sx = x - (psize[0]/2) + ( ((stringInfo[:xoffset] * (stringInfo[:length]-1))) / 2 ) + toX
        sy = y
        if( type == 'up' ) then
            sy -= psize[1]
        elsif( type == 'center' ) then
            sy -= (psize[1]/2)
        end
        spaceOffset = 0
        stringInfo[:string].each_char.with_index do |str,index|
            layout = context.create_pango_layout
            layout.set_font_description(Pango::FontDescription.new("#{stringInfo[:font]} #{stringInfo[:font_size]}"))
            layout.text = str.tr("\s","0").encode('utf-8') # �X�y�[�X�͐��l�̃[���Ƃ��ĕ����v�Z���Ă���
            *psize = layout.pixel_size
            context.move_to(sx, sy + stringInfo[:string_yoffset][index])
            nx = psize[0]
            if( str =~ /\s/ ) then
                nx = (psize[0]/2) # �X�y�[�X�Ȃ�ړ��ʂ𔼕��ɂ���
                spaceOffset += nx # �ςݎc������ێ�
            else
                sx += spaceOffset # �X�y�[�X�łȂ��Ȃ�����ςݎc�����𔽉f�����̈ʒu�֖߂�
                spaceOffset = 0
            end
            sx += nx - stringInfo[:xoffset]
            str.sub(/[��]/){ sx -= stringInfo[:xoffset] } # [��] �͂���Ɋ񂹂�
            next if( str =~ /\s/ ) # �X�y�[�X�͕`�悷��K�v���Ȃ�
            context.show_pango_layout(layout)
        end
    end
    
#     # ���t��\��
#     def drawDate(context, param)
#         context.set_source_rgba(param[:font_color_red], param[:font_color_green], param[:font_color_blue], param[:font_color_alpha] )
#         layout = context.create_pango_layout
#         layout.set_font_description(Pango::FontDescription.new("#{param[:mid_font]} #{param[:date_font_size]}"))
#         layout.text = param[:mid_string].encode('utf-8')
#         *psize = layout.pixel_size # �Z���^�[�ʒu������o���p
#         sx = param[:center_x] - psize[0]/2
#         sy = param[:center_y] - psize[1]/2
#         
#         range = (4 * param[:scale]).to_i
#         param[:mid_string].each_char.with_index do |str,index|
#             layout = context.create_pango_layout
#             layout.set_font_description(Pango::FontDescription.new("#{param[:mid_font]} #{param[:date_font_size]}"))
#             layout.text = str.encode('utf-8')
#             *psize = layout.pixel_size
#             context.move_to(sx, sy+param[:random].rand(range)-(range/2)) # �{����random���Ă͂����Ȃ��B�B�B�Q�x�ڂ�drawDate�ňႤ�Ƃ���ɕ`�悵�Ă��܂��B�B�B
#             sx += psize[0]
#             context.show_pango_layout(layout)
#         end
#     end
    
    # ���q��`�悷��
    def drawSignature( context, param)
        # ���̑�����ݒ�
        context.set_line_width (param[:line_size]);
        
        # ���q�~��`��
        drawCircle(context, param)
        
        # top, bottom ��
        top_sx,top_sy = getPos(    -param[:line_angle], param[:radius])
        top_ex,top_ey = getPos( 180+param[:line_angle], param[:radius])
        btm_sx,btm_sy = getPos(     param[:line_angle], param[:radius])
        btm_ex,btm_ey = getPos( 180-param[:line_angle], param[:radius])
        context.set_source_rgba(param[:font_color_red], param[:font_color_green], param[:font_color_blue], param[:font_color_alpha] )
        # top ��
        context.move_to(param[:center_x] + top_sx,param[:center_y] + top_sy)
        context.line_to(param[:center_x] + top_ex,param[:center_y] + top_ey)
        context.stroke
        # bottom ��
        context.move_to(param[:center_x] + btm_sx,param[:center_y] + btm_sy)
        context.line_to(param[:center_x] + btm_ex,param[:center_y] + btm_ey)
        context.stroke
        
        # top string
        drawString(context,param[:top_string_info], param[:center_x], param[:center_y] + top_sy, 'up')
        # btm string
        drawString(context,param[:btm_string_info], param[:center_x], param[:center_y] + btm_sy, 'down')
        # mid string
        drawStringForDate(context,param[:mid_string_info], param[:center_x], param[:center_y], 'center')
        #drawDate(context, param)
    end
    
    # ��]�}�g���N�X�ݒ�
    def setMatrix( context, param)
        context.translate( param[:center_x], param[:center_y] ) # ��]���S�_���ړ�
        context.rotate( param[:rotate_degrees] * Math::PI / 180 ) # ���S�_�����]
        context.translate( -param[:center_x]+param[:tx], -param[:center_y]+param[:ty] ) # ��]���S�_�����ɖ߂�
    end
    
    # ��ʑS�̂����H����
    def drawEffect( context, param, random)
        if( (param[:seed] & 0x1) == 1 ) then 
            #pat = Cairo::LinearPattern.new(0, 0, param[:width], param[:height]) # ���ォ��E���փt�B���^���H
            #pat = Cairo::LinearPattern.new(0-param[:center_x], 0-param[:center_y], param[:width]+(param[:center_x]*2), param[:height]+(param[:center_y]*2))
            
            # ����t�߂���E���܂ł����j�A�ɓ��߂����� # ����
            #pat = Cairo::LinearPattern.new(param[:center_x]/3, param[:center_y]/3, param[:width], param[:height]) # ���ォ��E���փt�B���^���H
            pat = Cairo::LinearPattern.new( random.rand(param[:width]), param[:center_y]/3, random.rand(param[:width]), param[:height]) # �ォ�牺�����փt�B���^
            pat.add_color_stop_rgba(0.0, param[:back_color_red], param[:back_color_green], param[:back_color_blue], 0.0)
            pat.add_color_stop_rgba(1.0, param[:back_color_red], param[:back_color_green], param[:back_color_blue], 0.75) # param[:back_color_alpha])
            context.rectangle(0-param[:center_x], 0-param[:center_y], param[:width]+(param[:center_x]*2), param[:height]+(param[:center_y]*2))
            context.set_source(pat)
            context.fill
        end

        # x1,y1 = getPos( random.rand(360), param[:center_x]+(param[:center_x]/4)+random.rand(param[:center_x]/3))
        x1,y1 = getPos( random.rand(360), param[:radius] + random.rand(param[:radius]) - (param[:radius]/2))
        # �ǂ����𒆐S�ɉ~�`�ɓ��߂�����
        pat2 = Cairo::RadialPattern.new( param[:center_x]+x1, param[:center_y]+y1, param[:radius]/5, # �������~
                                         param[:center_x]+x1, param[:center_y]+y1, param[:radius]) # �傫���~
        pat2.add_color_stop_rgba( 0, param[:back_color_red], param[:back_color_green], param[:back_color_blue], 0.6+random.rand(0.4)) # �������~
        pat2.add_color_stop_rgba( 1, param[:back_color_red], param[:back_color_green], param[:back_color_blue], 0.0) # �傫���~
        # �O���[���O���f�[�V�����ŕ`����e���m�F�������ꍇ�͏�L�Q�R�[�h�Ɖ��L�Q�R�[�h�����ւ���
        #pat2.add_color_stop_rgba( 0, 0, 1, 0, 0.6+random.rand(0.4) )
        #pat2.add_color_stop_rgba( 1, 0, 1, 0, 0.0)
        context.rectangle(0-param[:center_x], 0-param[:center_y], param[:width]+(param[:center_x]*2), param[:height]+(param[:center_y]*2))
        context.set_source(pat2)
        context.fill
    end
    
    # ���q�C���[�W�𐶐�����
    def createSignatureImage(param)
        # ImageSurface ���쐬
        surface = Cairo::ImageSurface.new(param[:format], param[:width], param[:height])
        context = Cairo::Context.new(surface)
        
        setMatrix(context, param)
        drawBackground(context,param) # �w�i�`��
        drawSignature(context,param) # ���q�C���[�W�`��
        
        # �X�y�V�������[�h�Ȃ�摜������ɉ��H����B���������߂��ݒ肳��Ă���ꍇ�͐��������삵�Ȃ��I�I
        # �ォ�炷�ׂĂ��ĕ`�悵�Ă��A���t�@�l�͐��������Z���ꂽ��Ԃŕ`�悳�����ۂ��B�㏑���łȂ�
        if( param[:special_mode] ) then
            random = param[:random] # clone ����Ƃ�΂����Ȃ�ŕϐ���
            param = param.clone # �p�����[�^�R�s�[
            range = (6 * param[:scale]).to_i
            param[:center_x] += random.rand(range) - (range/2)
            param[:center_y] += random.rand(range) - (range/2)
            param[:font_color_alpha] *= 0.5
            param[:top_string_info][:font_color_alpha] *= 0.5
            param[:btm_string_info][:font_color_alpha] *= 0.5
            param[:mid_string_info][:font_color_alpha] *= 0.5
            drawCircle(context,param)
            drawSignature(context,param)
            drawEffect(context,param,random)
        end
        return surface
    end
    
    def createWindowsBitmap()
=begin
    // 14 byte
    typedef struct tagBITMAPFILEHEADER {
        unsigned short bfType; # 'BM'
        unsigned long  bfSize; # �t�@�C���T�C�Y
        unsigned short bfReserved1; # 0
        unsigned short bfReserved2; # 0
        unsigned long  bfOffBits; # �t�@�C���擪����摜�f�[�^�܂ł̃I�t�Z�b�g
    } BITMAPFILEHEADER
    // 40 byte
    typedef struct tagBITMAPINFOHEADER{
        unsigned long  biSize; # 40  
        long           biWidth; # 200
        long           biHeight; # 200
        unsigned short biPlanes; # 1
        unsigned short biBitCount; # 24 or 32
        unsigned long  biCompression; # 0: �����k
        unsigned long  biSizeImage; # 96dpi �Ȃ��3780, 0 �̏ꍇ������
        long           biXPixPerMeter; # 96dpi �Ȃ��3780, 0 �̏ꍇ������
        long           biYPixPerMeter; # 96dpi �Ȃ��3780, 0 �̏ꍇ������
        unsigned long  biClrUsed; # 0 
        unsigned long  biClrImporant; # 0
    } BITMAPINFOHEADER;
=end
        
        data = @surface.data
        w = @surface.width
        h = @surface.height
        
        # �Q�l�T�C�g�F http://www.kk.iij4u.or.jp/~kondo/bmp/#INFOHEADER
        depath = 4; # ARGB8888=32bit
        mBITMAPFILEHEADER = {
            :bfType => 'BM',
            :bfSize => ((w * h * depath) + 54), # 0x01d4f6, # 120054 # �t�@�C���T�C�Y
            :bfReserved1 => 0, # 0
            :bfReserved2 => 0, # 0
            :bfOffBits => 0x36, # �t�@�C���擪����摜�f�[�^�܂ł̃I�t�Z�b�g
        } # 14 byte
        
        mBITMAPINFOHEADER = {
            :biSize => 0x28, # 40
            :biWidth => w, # 200
            :biHeight => -h, # 200
            :biPlanes => 1, # 1
            :biBitCount => 0x20, # 24 or 32
            :biCompression => 0, # 0: �����k
            :biSizeImage => (w * h * depath), #0x0001d4c0, #120000, # 96dpi �Ȃ��3780, 0 �̏ꍇ������
            :biXPixPerMeter => 0x00000ec4, #3780, # 96dpi �Ȃ��3780, 0 �̏ꍇ������
            :biYPixPerMeter => 0x00000ec4, #3780, # 96dpi �Ȃ��3780, 0 �̏ꍇ������
            :biClrUsed => 0,# 0 
            :biClrImporant => 0, # 0
        } # 40 byte
        # s!: signed short
        # S!: unsigned short
        # i!: signed int
        # I!: unsigned int
        # l!: signed long
        # L!: unsigned long
        # q!: signed long long
        # Q!: unsigned long long
        
        membuffer = StringIO.new("", 'wb+')
        #// 14 byte
        #typedef struct tagBITMAPFILEHEADER {
        membuffer.write( [mBITMAPFILEHEADER[:bfType]].pack('a2') ) 
        membuffer.write( [mBITMAPFILEHEADER[:bfSize]].pack('L!') )
        membuffer.write( [mBITMAPFILEHEADER[:bfReserved1]].pack('S!') )
        membuffer.write( [mBITMAPFILEHEADER[:bfReserved2]].pack('S!') )
        membuffer.write( [mBITMAPFILEHEADER[:bfOffBits]].pack('L!') )
        
        #// 40 byte
        #typedef struct tagBITMAPINFOHEADER{
        membuffer.write( [mBITMAPINFOHEADER[:biSize]].pack('L!') )
        membuffer.write( [mBITMAPINFOHEADER[:biWidth]].pack('l') )
        membuffer.write( [mBITMAPINFOHEADER[:biHeight]].pack('l!') )
        membuffer.write( [mBITMAPINFOHEADER[:biPlanes]].pack('S!') )
        membuffer.write( [mBITMAPINFOHEADER[:biBitCount]].pack('S!') )
        membuffer.write( [mBITMAPINFOHEADER[:biCompression]].pack('L!') )
        membuffer.write( [mBITMAPINFOHEADER[:biSizeImage]].pack('L!') )
        membuffer.write( [mBITMAPINFOHEADER[:biXPixPerMeter]].pack('l!') )
        membuffer.write( [mBITMAPINFOHEADER[:biYPixPerMeter]].pack('l!') )
        membuffer.write( [mBITMAPINFOHEADER[:biClrUsed]].pack('L!') )
        membuffer.write( [mBITMAPINFOHEADER[:biClrImporant]].pack('L!') )
        #// image
        membuffer.write( data )
        membuffer.rewind
        buf = membuffer.read
        return buf
    end
    
    def export_to_png(fileName)
        
#         data = @surface.data
#         w = @surface.width
#         h = @surface.height
        #bitmapImageArray = data.unpack("h*") # ARGB8888 x width x height
        # data[0,4] = "\xff\x00\x00\x00"
#         binding.pry
#         for y in 0..(h-1) do
#             for x in 0..(w-1) do
#                 buf = data[((y*w)+x)*4,4].unpack("C*")
#             end
#         end
        
        @surface.write_to_png(fileName)
    end
    
    def getBitmapImage
        return @surface.data, @surface.width, @surface.height
    end
    
end
