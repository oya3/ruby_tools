# -*- coding: utf-8 -*-

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'Qt4'
require 'screen_window'
require 'event_list_widget'
require 'event_label'
require 'event_label_manager'

class ProjectSession < Qt::Object
    slots 'selectedGrid(const QString&)'
    slots 'eventAction(const QString&)'

    def initialize(parentWidget = nil, mdiArea = nil, parameters)
        super parentWidget
        @parameters = parameters
        @mdiArea = mdiArea
        createProjectWindow(parentWidget)
    end

    def createProjectWindow(parentWidget)
        @parameters['textureImage'] = Qt::Pixmap.new(@parameters['textureFile'])
        @parameters['textureTileWidth'] = (@parameters['textureImage'].width / @parameters["tileWidth"]).to_i
        @parameters['textureTileHeight'] = (@parameters['textureImage'].height / @parameters["tileHeight"]).to_i
        @parameters["worldTileWidth"] = @parameters["worldWidth"] / @parameters["tileWidth"];
        @parameters["worldTileHeight"] = @parameters["worldHeight"] / @parameters["tileHeight"];
        if @parameters["screenData"] == nil then
            @parameters["screenData"] = Array.new(@parameters["worldTileWidth"] * @parameters["worldTileHeight"],0)
        end
        
        @selectedScreen = ScreenPoint.new
        @selectedTexture = ScreenPoint.new
        # 配置画面
        @screen = ScreenWindow.new(parentWidget,
            @parameters['screenWidth'], @parameters['screenHeight'],
            @parameters['worldWidth'], @parameters['worldHeight'],
            @parameters['tileWidth'], @parameters['tileHeight'], true)
        @screen.setWindowTitle("スクリーン")
        @mdiArea.addSubWindow(@screen)
        setScreenData(@screen,@parameters)

        # テクスチャ画面
        @texture = ScreenWindow.new(parentWidget,
            @parameters['textureImage'].width,  @parameters['textureImage'].height,
            @parameters['textureImage'].width,  @parameters['textureImage'].height,
            @parameters['tileWidth'], @parameters['tileHeight'], false)
        
        @texture.setWindowTitle("テクスチャ")
        @texture.drawPixmap(@parameters['textureImage'], 0, 0)
        @mdiArea.addSubWindow(@texture)
        
        # イベント画面
        @eventList = EventListWidget.new(parentWidget, @parameters) # ['events'])
        # @eventList.setWindowTitle("イベント")
        @mdiArea.addSubWindow(@eventList)

        # イベント配置よりも前に接続しておく
        connect(@screen, SIGNAL('selectedGrid(const QString&)'), self, SLOT('selectedGrid(const QString&)'))
        connect(@screen, SIGNAL('eventAction(const QString&)'), self, SLOT('eventAction(const QString&)'))
        connect(@texture, SIGNAL('selectedGrid(const QString&)'), self, SLOT('selectedGrid(const QString&)'))

        
        # イベントラベル配置
        @eventManager = EventLabelManager.new(parentWidget)
        eventList = EventLabelManager.getEventData(@parameters)
        eventList.each do |hash|
            @screen.createEventLabel( hash[:id], hash[:name], hash[:pos])
        end
        
        # 表示開始
        @screen.show
        @texture.show
        @eventList.show

        @parameters['ui']['messageListWidget'].addItems([] << "project生成" ) # ログの実験。これを通知でやりたい。。。
    end

    def setScreenData(screen,parameters)
        tempPixmap = Qt::Pixmap.new( parameters["worldWidth"], parameters["worldHeight"] )
        painter = Qt::Painter.new(tempPixmap)
        
        parameters["screenData"].each.with_index(0) do |data,index|
            next if data == 0
            data -= 1
            x = (index % parameters["worldTileWidth"]).to_i
            y = (index / parameters["worldTileWidth"]).to_i
            tx = (data % parameters["textureTileWidth"]).to_i
            ty = (data / parameters["textureTileWidth"]).to_i
            clipPixmap = parameters['textureImage'].copy(
                tx * parameters['tileWidth'], ty * parameters['tileHeight'],
                parameters['tileWidth'], parameters['tileHeight'])
            painter.drawPixmap(x*parameters['tileWidth'],y*parameters['tileHeight'],clipPixmap)
            # print "pos[#{index}] [#{x}:#{y}] [#{parameters['worldTileWidth']}:#{parameters['worldTileHeight']}]\n"
        end
        painter.end
        screen.drawPixmap(tempPixmap,0,0);
    end


    def selectedGrid(obj_id) # (pos,gpos,index,id)
        screenPoint = ObjectSpace._id2ref(obj_id.to_i)
        # 状態によって実施するべき内容がかわるはず。（配置、イベント、当たり）
        if @texture.object_id == screenPoint.id then
            # テクスチャの選択イベント
            @selectedTexture  = screenPoint
            @selectedTexture.index += 1
        elsif @screen.object_id == screenPoint.id then
            # スクリーンの選択イベント
            return if @selectedTexture.index == 0
            @selectedScreen = screenPoint
            clipPixmap = @parameters['textureImage'].copy(
                @selectedTexture.gx * @parameters['tileWidth'], @selectedTexture.gy * @parameters['tileHeight'],
                @parameters['tileWidth'], @parameters['tileHeight'])
            @screen.drawPixmap(clipPixmap,
                @selectedScreen.gx * @parameters['tileWidth'],
                @selectedScreen.gy * @parameters['tileHeight'])
            @parameters["screenData"][@selectedScreen.index] = @selectedTexture.index
        end
    end

    def eventAction(obj_id)
        eventLabelAction = ObjectSpace._id2ref(obj_id.to_i)
        puts "ProjectSession::eventAction type[#{eventLabelAction.type}] obj_id[#{eventLabelAction.obj_id}] id[#{eventLabelAction.id}]"
        if eventLabelAction.type == 'create' then
            @eventManager.add(eventLabelAction.obj_id, eventLabelAction.id, eventLabelAction.pos)
        end
        if eventLabelAction.type == 'delete' then
            @eventManager.del(eventLabelAction.obj_id)
        end
    end
    
    def getSortEventList(direction='x', oder_by='asc')
        return @eventManager.getSortEventList(direction,oder_by)
    end
    
end

