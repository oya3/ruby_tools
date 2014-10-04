# -*- coding: utf-8 -*-

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__))+'/../common_modules/')

require 'Qt4'
require 'qtuitools'
require 'signature_stamper'
require 'win32ole-ext'
require 'yaml'
require 'pp'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class SignatureWidgt < Qt::Widget
    NAME = "mksig for gui."
    VERSION = "ver.0.2014.09.16.1500"
    def initialize(parent = nil)
        super(parent)
        
        # 画面構成読み込み＆設定
        @formWidget = nil
        Qt::File.new("signature_widget2.ui") do |file|
            loader = Qt::UiLoader.new
            file.open(Qt::File::ReadOnly)
            @formWidget = loader.load(file, self)
        end
        
        # 画面構成に対応する設定情報読み込み＆設定
        @parameter = getParameter('parameter.yml') # エラーハンドリング無視。。。
        @ui = setParameter(@parameter)
        
        # 判子イメージ保持用エリア
        @signatureStamper = nil # 判子生成オブジェクト
        @signatureSize = Qt::Size.new(@ui['label_signature'].rect.width, @ui['label_signature'].rect.height)
        @signatureImage = Qt::Image.new(@signatureSize, Qt::Image::Format_ARGB32_Premultiplied)
        @colorImage = Qt::Image.new( Qt::Size.new(@ui['label_color'].rect.width, @ui['label_color'].rect.height), Qt::Image::Format_ARGB32_Premultiplied) # color パレット
        
        Qt::MetaObject.connectSlotsByName(self) # イベント接続
        
        # SignatureWidgt に 読み込んだ widget を追加(縦方向)
        layout = Qt::VBoxLayout.new
        layout.addWidget(@formWidget)
        setLayout(layout)
        
        self.windowTitle = NAME + VERSION
    end
    
    def setParameter(parameter)
        # この情報もymlに記述するべき？
        ui = Hash.new
        ui['comboBox_top'] = findChild(Qt::ComboBox, "comboBox_top")
        ui['lineEdit_mid'] = findChild(Qt::LineEdit, "lineEdit_mid")
        ui['calendarWidget'] = findChild(Qt::CalendarWidget, "calendarWidget")
        ui['comboBox_btm'] = findChild(Qt::ComboBox, "comboBox_btm")
        ui['comboBox_color'] = findChild(Qt::ComboBox, "comboBox_color")
        ui['label_signature'] = findChild(Qt::Label, "label_signature")
        ui['checkBox_double'] = findChild(Qt::CheckBox, "checkBox_double")
        ui['checkBox_special'] = findChild(Qt::CheckBox, "checkBox_special")
        
        ui['lineEdit_r'] = findChild(Qt::LineEdit, "lineEdit_r")
        ui['lineEdit_g'] = findChild(Qt::LineEdit, "lineEdit_g")
        ui['lineEdit_b'] = findChild(Qt::LineEdit, "lineEdit_b")
        ui['horizontalSlider_r'] = findChild(Qt::Slider, "horizontalSlider_r")
        ui['horizontalSlider_g'] = findChild(Qt::Slider, "horizontalSlider_g")
        ui['horizontalSlider_b'] = findChild(Qt::Slider, "horizontalSlider_b")
        ui['label_color'] = findChild(Qt::Label, "label_color")
        
        ui['pushButton_create'] = findChild(Qt::PushButton, "pushButton_create")
        ui['pushButton_save'] = findChild(Qt::PushButton, "pushButton_save")
        
        # 初期値設定
        parameter['contents']['default_values'].each do |param|
            # QcomboBox のみ対応。T.B.D Strategy 構造に修正する。
            if( param['type'] == 'QComboBox' ) then
                param['values'].each do |value|
                    ui[param['name']].addItem(value)
                end
            end
        end
        
        # on_calendarWidget_selectionChanged()
        dateText = "'" + ui['calendarWidget'].selectedDate.toString('yy.MM.dd')
        ui['lineEdit_mid'].text = dateText.gsub(/0(\d)/){" "+$1}
        
        ui['lineEdit_r'].text = ui['horizontalSlider_r'].value
        ui['lineEdit_g'].text = ui['horizontalSlider_g'].value
        ui['lineEdit_b'].text = ui['horizontalSlider_b'].value
        
        return ui
    end
    
    
    # 画面設定のパラメータを取得
    def getParameter(filepath)
        buffer = nil #Hash.new
        File.open(filepath) do |file|
            buffer = file.read
        end
        if( buffer ) then
            return YAML.load(buffer)
        end
        return nil
    end

    # カレンダ選択イベント
    slots 'on_calendarWidget_selectionChanged()'
    def on_calendarWidget_selectionChanged()
        dateText = "'" + @ui['calendarWidget'].selectedDate.toString('yy.MM.dd')
        @ui['lineEdit_mid'].text = dateText.gsub(/0(\d)/){" "+$1}
    end
    
    # 保存ボタン押下イベント
    slots 'on_pushButton_save_clicked()'
    def on_pushButton_save_clicked
        if( @signatureStamper == nil ) then
            # 未生成なので警告だして終了
            msgBox = Qt::MessageBox.new(self)
            msgBox.setText( "判子が生成されとらんわ！！" )
            msgBox.exec
            return
        end
        # 保存先選択しpng保存
        file = Qt::FileDialog::getSaveFileName(self,tr("Save file"),".",tr("Text File(*.png)"))
        if( file ) then
            file = file.force_encoding('utf-8').encode('cp932')
            @signatureStamper.export_to_png(file)
        end
    end
    
    # カラーパレット設定
    def setColor(name,value)
        @ui[name].text = value
        colorString = sprintf("0xff%02x%02x%02x", @ui['lineEdit_r'].text.to_i, @ui['lineEdit_g'].text.to_i, @ui['lineEdit_b'].text.to_i)
        @ui['comboBox_color'].lineEdit.text = colorString
        painter = Qt::Painter.new(@colorImage)
        painter.fillRect(@colorImage.rect, Qt::Color.new(@ui['lineEdit_r'].text.to_i, @ui['lineEdit_g'].text.to_i, @ui['lineEdit_b'].text.to_i, 255))
        painter.end
        @ui['label_color'].pixmap = Qt::Pixmap.fromImage(@colorImage)
        update
    end
    
    slots 'on_horizontalSlider_r_valueChanged(int)'
    def on_horizontalSlider_r_valueChanged(value)
        setColor('lineEdit_r',value)
    end
    
    slots 'on_horizontalSlider_g_valueChanged(int)'
    def on_horizontalSlider_g_valueChanged(value)
        setColor('lineEdit_g',value)
    end
    
    slots 'on_horizontalSlider_b_valueChanged(int)'
    def on_horizontalSlider_b_valueChanged(value)
        setColor('lineEdit_b',value)
    end
    
    def setSlider(name,str)
        @ui['horizontalSlider_'+name].value = str.to_i
    end
    
    slots 'on_lineEdit_r_editingFinished()'
    def on_lineEdit_r_editingFinished()
        setSlider('r', @ui['lineEdit_r'].text)
    end
    
    slots 'on_lineEdit_g_editingFinished()'
    def on_lineEdit_g_editingFinished()
        setSlider('g', @ui['lineEdit_g'].text)
    end
    
    slots 'on_lineEdit_b_editingFinished()'
    def on_lineEdit_b_editingFinished()
        setSlider('b', @ui['lineEdit_b'].text)
    end
    
    # 生成ボタン押下イベント
    slots 'on_pushButton_create_clicked()'
    def on_pushButton_create_clicked
        # 処理中ダイアログ表示。T.B.D これは駄目。描画と処理が混ざって最悪。あるべき姿に修正する
        progressDialog = Qt::ProgressDialog.new(self) do |p|
            p.cancelButtonText = "中止"
            p.range = 0..@ui['label_signature'].rect.height # 200
            p.windowTitle = "処理中"
        end
        painter = nil
        @formWidget.setEnabled(false) # 操作禁止
        begin
            progressDialog.show
            $qApp.processEvents() # ExcludeUserInputEvents 指定したいけどできない。。。
            if progressDialog.wasCanceled
                progressDialog.dispose
                ::Kernel::raise "user stop"
            end
            
            # utf-8 に強制
            top = @ui['comboBox_top'].currentText ? @ui['comboBox_top'].currentText.force_encoding('utf-8'): ''
            mid = @ui['lineEdit_mid'].text ? @ui['lineEdit_mid'].text.force_encoding('utf-8'): ''
            btm = @ui['comboBox_btm'].currentText ? @ui['comboBox_btm'].currentText.force_encoding('utf-8'): ''
            color = @ui['comboBox_color'].currentText ? @ui['comboBox_color'].currentText.force_encoding('utf-8').sub(/(0x[0-9a-fA-F]+?)/){$1}: ''
            
            # 判子イメージ生成
            inparam = Hash.new
            inparam[:top_string] = top.encode('cp932')
            inparam[:mid_string] = mid.encode('cp932')
            inparam[:btm_string] = btm.encode('cp932')
            # 色(デフォルト：赤)
            inparam[:back_color] = 0xffffffff # 白
            inparam[:font_color] = 0xffff0000 # 赤
            if( color != '' ) then
                inparam[:font_color] = color.hex
            end
        
            # 枠の種類を設定
            inparam[:circle_type] = 'single'
            if( @ui['checkBox_double'].checked ) then
                inparam[:circle_type] = 'double'
            end
            # おまかせモードにするかどうか設定
            if( @ui['checkBox_special'].checked ) then
                inparam[:special_mode] = 0
            end
            @signatureStamper = SignatureStamper.new(inparam) # 判子イメージ生成
            
            $qApp.processEvents()
            if progressDialog.wasCanceled # 中止確認
                progressDialog.dispose
                ::Kernel::raise "user stop"
            end
            
            bitmapImage, w, h = @signatureStamper.getBitmapImage()
            # Qt の Label に描画(描画先を Qt にすれば以下の処理は不要。ruby での実装方法不明）
            painter = Qt::Painter.new(@signatureImage)
            for y in 0..(h-1)
                $qApp.processEvents()
                progressDialog.value = y
                if progressDialog.wasCanceled # 中止確認
                    progressDialog.dispose
                    ::Kernel::raise "user stop"
                end
                for x in 0..(w-1)
                    buf = bitmapImage[((y*w)+x)*4,4].unpack("C*")
                    color = Qt::Color.new( buf[2], buf[1], buf[0], buf[3])
                    painter.setPen(color)
                    painter.drawPoint(x, y) # どうもこれを大量に呼び出すと落ちる？
                end
            end
            @ui['label_signature'].pixmap = Qt::Pixmap.fromImage(@signatureImage)
            update
            # クリップボードにも貼り付けておく(word 用, excel は失敗。clip 指定が必要っぽい。 )
            Win32::Clipboard.set_data(@signatureStamper.createWindowsBitmap(), Win32::Clipboard::DIB)
            progressDialog.dispose
        rescue => ex
            puts ex
            #puts "中止"
            pp $!
            pp $@
        ensure
            if( painter ) then
                painter.end
            end
        end
        @formWidget.setEnabled(true) # 操作禁止解除
    end
end
