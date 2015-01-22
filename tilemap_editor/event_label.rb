# -*- coding: utf-8 -*-

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'Qt4'

class EventLabelAction
    attr_accessor :type, :obj_id, :id, :pos
    
    # 生成
    def initialize(type,obj_id,id,pos)
        @type = type
        @obj_id = obj_id
        @id = id
        @pos = pos
    end
end


class EventLabel < Qt::Label
    attr_accessor :id, :name, :world_pos
    signals 'delete_event_label(const QString&)'

    
    def initialize(id, name, parent = nil)
        super("#{id} #{name}", parent)
        @id = id
        @name = name
        @world_pos = Qt::Point.new(0,0)
        puts "new event label [#{@id},#{@name}]"
        setFrameShape(Qt::Frame::Panel)
        setFrameShadow(Qt::Frame::Raised)

        setAttribute(Qt::WA_DeleteOnClose)
    end
    
    def setWorldPosition(pos)
        @world_pos = pos
    end
    

    def mousePressEvent(event)
        # ドラッグ中がmacはテキスト名が表示されるがwindowsは表示されない。動作をかえるなよ。バグかと思った。。。
        # plainText = self.text().force_encoding('utf-8') # for quoting purposes
        mimeData = Qt::MimeData.new
        mimeData.text = "#{@id},#{@name}"
        puts "press  [#{@id},#{@name}]"
        drag = Qt::Drag.new(self)
        drag.mimeData = mimeData
        drag.hotSpot = event.pos - rect.topLeft
        dropAction = drag.start(Qt::CopyAction | Qt::MoveAction)
        
        if (dropAction == Qt::MoveAction) then # || (dropAction == Qt::CopyAction) then
            # 同一widgetなら削除。それ以外はコピーにする
            close()
            update()
            puts "dropAction close"
        end
    end

    def closeEvent(event)
        @eventAction = EventLabelAction.new('delete', self.object_id, @id, self.pos)
        emit delete_event_label(@eventAction.object_id.to_s)
        super
    end
end
