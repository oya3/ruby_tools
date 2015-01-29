# -*- coding: utf-8 -*-

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'Qt4'
require 'grid_widget'
require 'cursor_widget'
require 'event_label'

require 'pp'
# canvas layer
class CanvasWidget < Qt::Widget
    signals 'pressed(const QString&)'
    signals 'event_label_action(const QString&)'
    slots 'delete_event_label(const QString&)'
    
    def initialize(parent = nil, world_w, world_h, grid_w, grid_h,is_drop)
        super parent
        @gridSize = Qt::Size.new(grid_w,grid_h) # グリッドサイズ
        @cursorPos = Qt::Point.new(0,0) # カーソル位置
        # ワールドタイル数
        @worldTileSize = Qt::Size.new(world_w / grid_w, world_h / grid_h)
        # キャンバス
        @canvasPixmap = Qt::Pixmap.new( world_w, world_h) # , Qt::Image::Format_ARGB32_Premultiplied)
        @canvasScaledPixmap = Qt::Pixmap.new( world_w, world_h) # , Qt::Image::Format_ARGB32_Premultiplied)
        # グリッド
        @grid = GridWidget.new(self, world_w, world_h, grid_w, grid_h)
        @grid.setGrid(grid_w,grid_h)
        # カーソル
        @cursor = CursorWidget.new(self, grid_w, grid_h)
        # イベントオブジェクト管理
        @events = Hash.new # キャンバスレベルで管理してみる。もっさ。。。
        @scale = 1
        setScale(@scale) # とりあえず開始は1にする
        # puts "Canvas #{@canvasPixmap.width},#{@canvasPixmap.height},#{@gridSize.width},#{@gridSize.height}"
        setAcceptDrops(is_drop)

    end
    
    def drawPixmap(pixmap, x, y)
        w = (pixmap.rect.width * @scale).to_i
        h = (pixmap.rect.height * @scale).to_i
        # 原寸の描画
        painter = Qt::Painter.new(@canvasPixmap)
        painter.drawPixmap(x,y,pixmap)
        painter.end
        
        # 拡大縮小用の描画
        painter = Qt::Painter.new(@canvasScaledPixmap)
        painter.drawPixmap( (x*@scale).to_i, (y*@scale).to_i, pixmap.scaled( w, h, Qt::KeepAspectRatio, Qt::FastTransformation))
        painter.end
        
        update
    end
    
    # スケールしたキャンバスを生成
    def resizeEvent(event)
        @canvasScaledPixmap = @canvasPixmap.scaled( event.size.width, event.size.height, Qt::KeepAspectRatio, Qt::FastTransformation) # 大画面の切り替えはresizeEventがいいっぽい。
    end
    
    # 描画
    def paintEvent(event)
        #puts "CanvasWidget paintEvent"
        painter = Qt::Painter.new(self)
        painter.drawPixmap(0, 0, @canvasScaledPixmap)
        painter.end
    end
    
    # 指定したスケール値を考慮したサイズを返す
    def calcSize(w,h,scale)
        return ((w * scale).to_i), ((h * scale).to_i) # 小数点は切り捨て
    end
    
    # 指定したスケール値で位置を変換
    def getScaledPositon(pos,now_scale,next_scale)
        # pos.x : @canvasScaledPixmap.width = X : @canvasPixmap.width
        # @canvasScaledPixmap.width X = pos.x * @canvasPixmap.width
        (now_w,now_h) = calcSize(@canvasPixmap.width, @canvasPixmap.height, now_scale)
        (next_w,next_h) = calcSize(@canvasPixmap.width, @canvasPixmap.height, next_scale)
        puts "getScaledPositon x[#{pos.x}],y[#{pos.y}],scale[#{now_scale}][#{next_scale}],now_w[#{now_w}],now_h[#{now_h}],next_w[#{next_w}],next_h[#{next_h}]"
        scaledPos = Qt::Point.new
        scaledPos.x = (pos.x * next_w / now_w) + 0.5
        scaledPos.y = (pos.y * next_h / now_h) + 0.5
        return scaledPos
    end
    
    # スケールする
    def setScale(scale)
        @cursorPos = getScaledPositon(@cursorPos,@scale,scale)
        (scaled_w,scaled_h) = calcSize(@canvasPixmap.width, @canvasPixmap.height, scale)
        resize(scaled_w, scaled_h)
        @grid.setScale(scale)
        @cursor.setScale(scale)
        moveCursor(@cursorPos,scale)

        # イベント一式の位置を書き換える
        @events.each do |obj_id,eventLabel|
            scaled_pos = getScaledPositon(eventLabel.world_pos,1.0,scale)
            eventLabel.move(scaled_pos)
        end
        
        @scale = scale
    end
    
    # グリッド位置を取得
    def getGridPositon(x,y,scale)
        return (x / (@gridSize.width  * scale)).to_i, (y / (@gridSize.height * scale)).to_i
    end
    
    # グリッド単位の正規化
    def getNormalizedGrid(x,y,scale)
        (gx,gy) = getGridPositon(x,y,scale)
        return (gx * @gridSize.width * scale), (gy * @gridSize.height * scale) 
    end
    
    # カーソル移動
    def moveCursor(pos,scale)
        (gwx,gwy) = getNormalizedGrid(pos.x,pos.y,scale)
        @cursor.move( gwx, gwy)
    end
    
    # マウス移動
    def mouseMoveEvent(event)
        # puts "mouseMoveEvent x[#{event.pos.x}] y[#{event.pos.y}]"
        @cursorPos = event.pos
        moveCursor(event.pos, @scale)
        notifyPressed( createScreenPoint(event.pos) )
    end
    
    # マウスボタン押下
    def mousePressEvent(event)
        # puts "mousePressEvent x[#{event.pos.x}] y[#{event.pos.y}]"
        @cursorPos = event.pos
        moveCursor(event.pos, @scale)
        notifyPressed( createScreenPoint(event.pos) )
    end
    
    def notifyPressed(screenPoint)
        @tempScreenPoint = screenPoint # イベント送信する間、メモリ保持するためメンバ変数に代入
        emit pressed(@tempScreenPoint.object_id.to_s)
    end
    
    def createScreenPoint(pos)
        normal_pos = getScaledPositon(pos,@scale,1.0)
        (gx,gy) = getGridPositon(pos.x,pos.y,@scale)
        screenPoint = ScreenPoint.new
        # screenPoint.id = self.object_id
        screenPoint.x = normal_pos.x
        screenPoint.y = normal_pos.y
        screenPoint.gx = gx
        screenPoint.gy = gy
        screenPoint.id = self.object_id
        screenPoint.index = (gy *  @worldTileSize.width) + gx
        return screenPoint
    end

    # type : create or delete
    def notifyEventLabelAction(type,obj_id,id,pos)
        @eventLabelAction = EventLabelAction.new(type,obj_id,id,pos)
        emit event_label_action(@eventLabelAction.object_id.to_s)
    end

    # イベントが削除された
    def delete_event_label(obj_id)
        eventLabelAction = ObjectSpace._id2ref(obj_id.to_i)
        puts "CanvasWidget::delete_event_label #{eventLabelAction.type},#{eventLabelAction.id}"
        @events.delete(eventLabelAction.object_id);

        # 必要かどうか不明。。。
        # disconnect(eventLabelAction, SIGNAL('delete_event_label(const QString&)'), self, SLOT('delete_event_label(const QString&)'))
        notifyEventLabelAction( eventLabelAction.type, eventLabelAction.obj_id,eventLabelAction.id, eventLabelAction.pos)
    end
    
    def createEventLabel(id, name, pos)
        eventLabel = EventLabel.new(id, name, self)
        @events[eventLabel.object_id] = eventLabel
        
        normal_pos = getScaledPositon(pos,@scale,1.0)
        eventLabel.setWorldPosition(normal_pos);
        
        eventLabel.move(pos)
        eventLabel.show()
        connect(eventLabel, SIGNAL('delete_event_label(const QString&)'), self, SLOT('delete_event_label(const QString&)'))
        notifyEventLabelAction( 'create', eventLabel.object_id, id, normal_pos) # 生成と移動時に発生する
        return eventLabel
    end
    
    # drag & drop イベント
    def dragEnterEvent(event)
        if event.mimeData.hasText
            event.acceptProposedAction
        else
            event.ignore
        end
    end
    
    def dropEvent(event)
        puts "dropEvent"
        if event.mimeData().hasText()
            params = event.mimeData.text.force_encoding('utf-8').match(/^(.+?),(.+)$/)
            puts "moved id[#{params[1]}] name[#{params[2]}]"
            eventLabel = createEventLabel(params[1].to_i, params[2].to_s, event.pos)
            if children().include? event.source()
                puts "include"
                event.dropAction = Qt::MoveAction
                event.accept()
            else
                puts "not include"
                event.acceptProposedAction()
            end
        else
            puts "ignore"
            event.ignore()
        end
    end
end

