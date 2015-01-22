# -*- coding: utf-8 -*-

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'Qt4'
require 'qtuitools'

# projects dialog
class CreateProjectDialog < Qt::Dialog

    def initialize(parent = nil, parameters)
        super parent
        @parameters = parameters # 親の作業エリア。これでいいかは不明。。。
        
        # 画面構成読み込み＆設定
        @widget = nil
        Qt::File.new("projects.ui") do |file|
            loader = Qt::UiLoader.new
            file.open(Qt::File::ReadOnly)
            @widget = loader.load(file, self)
        end
        self.windowTitle = "プロジェクト生成"
        setMinimumSize(320,240)
        setMaximumSize(320,240)
        
        @ui = getUI()
        Qt::MetaObject.connectSlotsByName(self) # イベント接続
    end
    
    def getUI()
        ui = Hash.new
        # 画面構成
        ui['screenTileSize'] = findChild(Qt::ComboBox, "screenTileSize")
        ui['tilteSize'] = findChild(Qt::ComboBox, "tileSize")
        ui['screensWidth'] = findChild(Qt::SpinBox, "screensWidth")
        ui['screensHeight'] = findChild(Qt::SpinBox, "screensHeight")
        # テクスチャ
        ui['selectFileButton'] = findChild(Qt::PushButton, "selectFileButton")
        ui['textureFile'] = findChild(Qt::LineEdit, "textureFile")
        # ui['textureWidth'] = findChild(Qt::LineEdit, "textureWidth")
        # ui['textureHeight'] = findChild(Qt::LineEdit, "textureHeight")
        # プロジェクト生成
        ui['createProjectButton'] = findChild(Qt::PushButton, "createProjectButton")
        return ui
    end

    # ファイル選択ボタン押下イベント
    slots 'on_selectFileButton_clicked()'
    def on_selectFileButton_clicked
        # 保存先選択しpng保存
        file = Qt::FileDialog::getOpenFileName(self, "open file", ".", "PNG File(*.png)")
        if( file ) then
            @parameters['textureFile'] = file
            @ui['textureFile'].text = file
        end
    end

    # プロジェクト生成ボタン押下イベント
    slots 'on_createProjectButton_clicked()'
    def on_createProjectButton_clicked
        if @parameters['textureFile'] == nil then
            # errorMessageDialog = Qt::ErrorMessage.new(self)
            # errorMessageDialog.setWindowTitle("アホか？")
            # errorMessageDialog.showMessage("テクスチャ選べよ！！")
            messageBox = Qt::MessageBox.new(self)
            messageBox.setWindowTitle("アホか？")
            messageBox.setText("テクスチャ選べよ！！")
            messageBox.exec()
            
            return
        end
        # プロジェクト生成用パラメータ保持
        
        # 画面構成
        @parameters['screenTileSize'] = @ui['screenTileSize'].currentText
        @parameters['screenTileWidth'] = (@parameters['screenTileSize'].gsub(/(\d+)x(\d+)/){$1}).to_i
        @parameters['screenTileHeight'] = (@parameters['screenTileSize'].gsub(/(\d+)x(\d+)/){$2}).to_i
        
        @parameters['tileSize'] =  @ui['tilteSize'].currentText
        @parameters['tileWidth'] = (@parameters['tileSize'].gsub(/(\d+)x(\d+)/){$1}).to_i
        @parameters['tileHeight'] = (@parameters['tileSize'].gsub(/(\d+)x(\d+)/){$2}).to_i
        
        @parameters['screensWidth'] = @ui['screensWidth'].value.to_i
        @parameters['screensHeight'] = @ui['screensHeight'].value.to_i

        @parameters['screenWidth'] = @parameters['screenTileWidth'] * @parameters['tileWidth'];
        @parameters['screenHeight'] = @parameters['screenTileHeight'] * @parameters['tileHeight'];
        @parameters['worldWidth'] = @parameters['screenWidth'] * @parameters['screensWidth'];
        @parameters['worldHeight'] = @parameters['screenHeight'] * @parameters['screensHeight'];
        
        # テクスチャ
        @parameters['textureFile'] = @ui['textureFile'].text
        # サイズは読み込まないとわからないので
        #ui['textureWidth'] = findChild(Qt::LineEdit, "textureWidth")
        #ui['textureHeight'] = findChild(Qt::LineEdit, "textureHeight")
        accept() # 生成しない場合は、reject()
    end
end

