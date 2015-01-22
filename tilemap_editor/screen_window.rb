# -*- coding: utf-8 -*-

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'Qt4'
require 'qtuitools'
require 'canvas_widget'
require 'event_label'

class ScreenPoint
    attr_accessor :id
    attr_accessor :index
    attr_accessor :x
    attr_accessor :y
    attr_accessor :gx
    attr_accessor :gy
    def initialize
        @id = 0
        @index = 0
        @x = 0
        @y = 0
        @gx = 0
        @gy = 0
    end
end

# screen layer
class ScreenWindow < Qt::MdiSubWindow # Qt::Widget
    slots 'pressed(const QString&)'
    slots 'event_label_action(const QString&)'
    signals 'selectedGrid(const QString&)'
    signals 'eventAction(const QString&)'

    def initialize(parent = nil, screenWidth, screenHeight, worldWidth, worldHeight, gridWidth, gridHeight, is_drop)
        super parent
        @parameters = Hash.new
        # 表示画面サイズ
        @parameters['screenWidth'] = screenWidth
        @parameters['screenHeight'] = screenHeight
        # ワールド画面サイズ
        @parameters['worldWidth'] = worldWidth
        @parameters['worldHeight'] = worldHeight
        # グリッドサイズ
        @parameters['gridWidth'] = gridWidth
        @parameters['gridHeight'] = gridHeight
        # スケール
        @parameters['scale'] = 1.0
        
        resize(@parameters['screenWidth'], @parameters['screenHeight'])

        @scrollArea = Qt::ScrollArea.new
        @canvas = CanvasWidget.new(self, @parameters['worldWidth'], @parameters['worldHeight'], @parameters['gridWidth'], @parameters['gridHeight'], is_drop)
        @canvas.move(0,0)
        @scrollArea.widget = @canvas
        
        connect(@canvas, SIGNAL('pressed(const QString&)'), self, SLOT('pressed(const QString&)'))
        connect(@canvas, SIGNAL('event_label_action(const QString&)'), self, SLOT('event_label_action(const QString&)'))

        setWidget(@scrollArea)
        
        #setAttribute(Qt::WA_DeleteOnClose);
        setWindowFlags ( Qt::CustomizeWindowHint | Qt::WindowTitleHint ) # Qt::WindowMinMaxButtonsHint を設定してしまうと×ボタンも表示されてしまう。。。
        # setWindowFlags ( Qt::CustomizeWindowHint | Qt::WindowTitleHint | (Qt::WindowMinMaxButtonsHint & ~Qt::WindowCloseButtonHint) )
        # setWindowFlags ( Qt::WindowMinMaxButtonsHint | Qt::WindowTitleHint )

    end
    
    def createEventLabel(id,name,pos)
        @canvas.createEventLabel( id, name, pos)
    end
    
    def drawPixmap(pixmap, x, y)
        @canvas.drawPixmap(pixmap,x,y)
    end

    def setScale(scale)
        @canvas.setScale(scale)
    end
    
    def pressed(obj_id)
        screenPoint = ObjectSpace._id2ref(obj_id.to_i)
        @tempScreenPoint = screenPoint
        @tempScreenPoint.id = self.object_id
        emit selectedGrid(@tempScreenPoint.object_id.to_s)
    end
    
    def event_label_action(obj_id)
        @tempEventLabelAction = ObjectSpace._id2ref(obj_id.to_i)
        puts "ScreenWindow::event_label_action #{@tempEventLabelAction.type},#{@tempEventLabelAction.id}"

        emit eventAction(@tempEventLabelAction.object_id.to_s)
    end

    def keyPressEvent(event) # Qt::keyEvent
        if event.key == 59 then # +
            @parameters['scale'] += 0.1 if @parameters['scale'] < 2.0
        end
        if event.key == 45 then # -
            @parameters['scale'] -= 0.1 if @parameters['scale'] > 0.5
        end
        setScale(@parameters['scale'])
        super
    end

end

