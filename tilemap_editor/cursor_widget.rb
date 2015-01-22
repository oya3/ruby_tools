# -*- coding: utf-8 -*-

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'Qt4'

# cursor
class CursorWidget < Qt::Widget
    def initialize(parent = nil, gw, gh)
        super parent
        @base_grid_width = gw
        @base_grid_height = gh
        @cursorPixmap = nil
        @scale = 1
        setScale(@scale)
        # バックグラウンドを透明にする(初期値もそーなってると思われるけど、実験）
        setAttribute(Qt::WA_TranslucentBackground);
        setStyleSheet("background:transparent;");
    end
    
    def setScale(scale)
        # 今回のスケールに応じた描画サイズを生成
        @scale = scale
        width = (@base_grid_width * @scale).to_i
        height = (@base_grid_height * @scale).to_i
        resize(width,height)
#        puts "cursor pos[#{self.x}][#{self.y}]"
    end
    
    def paintEvent(event)
        painter = Qt::Painter.new(self)
        rect = Qt::RectF.new( 0, 0,  self.rect.width-1, self.rect.height-1)
        painter.fillRect( rect, Qt::Color.new( 0x00, 0x00, 0x00, 0x10))
        painter.setPen( Qt::Color.new( 0x00, 0xff, 0x00, 0xff) )
        painter.drawRect(rect)
        painter.end
    end
end

