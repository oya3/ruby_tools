# -*- coding: utf-8 -*-

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'Qt4'
require 'qtuitools'

require 'parameters_widget'
require 'project_session'
require 'create_project_dialog'

require 'json'
require 'pp'

# main
class MainWindow < Qt::MainWindow
    
    slots :createProject, :loadProject, :saveProject;

    def initialize()
        super
        @parameters = Hash.new
        @ui = Hash.new
        createMenus()
        createStatusBar()
        createDockWindows()
        @ui['mdiArea'] = Qt::MdiArea.new
        setCentralWidget(@ui['mdiArea'])
        
        setWindowTitle("Tilemap Editor")
        
        @parameters["main_window"] = self
        @parameters["ui"] = @ui
        # close ボタンの非表示の実験。以下のコードで成功。MdiAreaの場合の指定方法が不明だ。。。
        # setWindowFlags ( Qt::CustomizeWindowHint | Qt::WindowTitleHint);

    end
    
    def createProject()
        # プロジェクト生成ダイアログ
        projects = CreateProjectDialog.new(self,@parameters)
        if( projects.exec() != Qt::Dialog::Accepted ) then
            return # プロジェクト生成しない
        end

        # こっから指定された内容で各ウィンドウを生成する
        # @project = ProjectSession.new(self,@ui['mdiArea'],parameters)
        @project = ProjectSession.new(nil,@ui['mdiArea'],@parameters)

    end
    
    def loadProject()
        filePath = Qt::FileDialog.getOpenFileName(
            self, "読み込みファイル選択", ".",  "JSON (*.json)" )
        if not filePath or filePath.empty?
            return
        end
        
        path = filePath.sub(/^(.+)\/.+$/){$1}
        # puts "file[#{filePath}][#{path}]"
        # ここに読み込み処理を記載する
        # statusBar().showMessage("Load '%1'".arg("load.json"), 2000)
        
        json_data = open(filePath) do |io|
            JSON.load(io)
        end
        
        # puts json_data
        @parameters["path"] = path
        
        @parameters["screensWidth"] =  json_data["width"].to_i
        @parameters["screensHeight"] = json_data["height"].to_i
        
        tilesets = json_data["tilesets"][0]
        # puts tilesets
        @parameters["tileWidth"] = tilesets["tilewidth"].to_i
        @parameters["tileHeight"] = tilesets["tileheight"].to_i
        @parameters["textureFile"] = path + '/' + tilesets["image"]

        layers = json_data["layers"][0]
        # puts layers
        @parameters["worldTileWidth"] = layers["width"].to_i
        @parameters["worldTileHeight"] = layers["height"].to_i
        @parameters["worldWidth"] = layers["width"].to_i * @parameters["tileWidth"]
        @parameters["worldHeight"] = layers["height"].to_i * @parameters["tileHeight"]
        @parameters["screenWidth"] =  @parameters["screensWidth"]  * @parameters["tileWidth"]
        @parameters["screenHeight"] = @parameters["screensHeight"] * @parameters["tileHeight"]
        @parameters["screenData"] = layers["data"]
        @parameters["events"] = layers["events"]

        # @project = ProjectSession.new(self,@ui['mdiArea'],@parameters)
        @project = ProjectSession.new(nil,@ui['mdiArea'],@parameters)
    end

    def saveProject()
        filePath = Qt::FileDialog.getSaveFileName(
            self, "保存ファイル選択", ".",  "JSON (*.json)" )
        if not filePath or filePath.empty?
            puts "saveProject : #{@project.getSortEventList}"
            # pp @parameters
            return
        end

        # 基本
        outbuffer = Hash.new
        outbuffer['version'] = 1
        outbuffer['tileheight'] = @parameters["tileWidth"]
        outbuffer['tilewidth'] = @parameters["tileHeight"]
        outbuffer['width'] = @parameters["screensWidth"]
        outbuffer['height'] = @parameters["screensHeight"]
        outbuffer['orientation'] = "orthogonal"

        # レイヤー
        outbuffer['layers'] = Array.new
        layerData = Hash.new
        outbuffer['layers'].push(layerData)
        layerData['data'] = @parameters["screenData"]
        layerData['width'] = @parameters["worldTileWidth"]
        layerData['height'] = @parameters["worldTileHeight"]
        layerData['name'] = "World1"
        layerData['opacity'] = 1
        layerData['type'] = "tilelayer"
        layerData['visible'] = true
        layerData['x'] = 0
        layerData['y'] = 0

        # レイヤー：イベント
        eventData = Hash.new
        layerData['events'] = eventData
        eventData['file'] = @parameters['events']['file']
        eventData['direction'] = @parameters['events']['direction']
        eventData['oder_by'] = @parameters['events']['oder_by']
        evd = Array.new
        eventData['data'] = evd
        evl = @project.getSortEventList(eventData['direction'], eventData['oder_by'])
        evl.each do |key,hash|
            ev = Hash.new
            ev['id'] = hash[:id]
            ev['x'] = hash[:pos].x
            ev['y'] = hash[:pos].y
            evd.push(ev)
        end

        # テクスチャ
        outbuffer['tilesets'] = Array.new
        tileData = Hash.new
        outbuffer['tilesets'].push(tileData)
        tileData['firstgid'] = 1
        tileData['image'] = @parameters["textureFile"].sub(/^.+\/(.+?)$/){$1}
        tileData['imageheight'] = @parameters['textureImage'].height
        tileData['imagewidth'] = @parameters['textureImage'].width
        tileData['margin'] = 0
        tileData['name'] = "SuperMarioBros-World1-1"
        tileData['spacing'] = 0
        tileData['tileheight'] = @parameters["tileWidth"]
        tileData['tilewidth'] = @parameters["tileHeight"]

        open(filePath,'w') do |io|
            str = outbuffer.to_json.gsub(/([\{\}\[\],])/){|h|h+"\n"}
            io.write(str)
        end

        # ここに保存処理を記載する
        #statusBar().showMessage("Saved '%1'".arg("save.json"), 2000)
    end
    
    def createMenusActions()
        @menuActions = Hash.new
        
        @menuActions["createProject"] = Qt::Action.new(Qt::Icon.new("images/new.png"), "新規作成", self)
        @menuActions["createProject"].shortcut = Qt::KeySequence.new("Ctrl+N")
        @menuActions["createProject"].statusTip = "プロジェクトを新規作成する"
        connect(@menuActions["createProject"], SIGNAL('triggered()'), self, SLOT('createProject()'))
        
        @menuActions["loadProject"] = Qt::Action.new(Qt::Icon.new("images/open.png"), "読み込み", self)
        @menuActions["loadProject"].shortcut = Qt::KeySequence.new("Ctrl+S")
        @menuActions["loadProject"].statusTip = "既存プロジェクトを読み込む"
        connect(@menuActions["loadProject"], SIGNAL('triggered()'), self, SLOT('loadProject()'))
        
        @menuActions["saveProject"] = Qt::Action.new(Qt::Icon.new("images/save.png"), "保存", self)
        @menuActions["saveProject"].shortcut = Qt::KeySequence.new("Ctrl+S")
        @menuActions["saveProject"].statusTip = "既存プロジェクトを保存する"
        connect(@menuActions["saveProject"], SIGNAL('triggered()'), self, SLOT('saveProject()'))
        
        @menuActions["close"] = Qt::Action.new( "終了", self)
        @menuActions["close"].shortcut = Qt::KeySequence.new( "Ctrl+Q" )
        @menuActions["close"].statusTip = "終了"
        connect(@menuActions["close"], SIGNAL('triggered()'), self, SLOT('close()'))
        
    end
    
    def createMenus()
        createMenusActions()
        @menu = Hash.new
        @menu["file"] = menuBar().addMenu(tr("&File"))
        @menu["file"].addAction(@menuActions["createProject"])
        @menu["file"].addAction(@menuActions["loadProject"])
        @menu["file"].addAction(@menuActions["saveProject"])
        @menu["file"].addSeparator()
        @menu["file"].addAction(@menuActions["close"])
    end
    
    def createStatusBar()
        statusBar().showMessage("Ready")
    end
    
    def createDockWindows()
        # パラメータ ※ こいつは、project_session クラスに移動したいね。。。
        dock = Qt::DockWidget.new("parameters dock", self)
        dock.allowedAreas = Qt::LeftDockWidgetArea | Qt::RightDockWidgetArea
        @ui["parametersWidget"] = ParamtersWidget.new(dock)
        dock.widget = @ui["parametersWidget"]
        addDockWidget(Qt::RightDockWidgetArea, dock)
        
        # メッセージ
        dock = Qt::DockWidget.new("message dock", self)
        dock.allowedAreas = Qt::BottomDockWidgetArea
        @ui["messageListWidget"] = Qt::ListWidget.new(dock)# MessageListWidget.new(dock)
        @ui["messageListWidget"].addItems([] << "起動")
        dock.widget = @ui["messageListWidget"]
        addDockWidget(Qt::BottomDockWidgetArea, dock)
    end

end

