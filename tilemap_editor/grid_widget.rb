# -*- coding: utf-8 -*-

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'Qt4'

# grid layer
class GridWidget < Qt::Widget
    def initialize(parent = nil, w, h, gw, gh)
        super parent
        @width = w
        @height = h
        setGrid(gw,gh)
        @scale = 0
        setScale(1)
    end

    def setScale(scale)
        w = (@width * scale).to_i
        h = (@height * scale).to_i
        if @scale != scale then
            resize(w,h)
            setMinimumSize(w,h)
            setMaximumSize(w,h)
            @scale = scale
        end
        # puts "grid scale#{@scale}"
        update
    end
    
    def setGrid(w,h)
        @grid_width = w
        @grid_height = h
        update
    end
    
    def paintEvent(event)
        painter = Qt::Painter.new(self)
        color = Qt::Color.new( 0xff, 0x00, 0x00, 0xff) # r,g,b,a
        painter.setPen(color)
        scaled_w = (@width * @scale).to_i
        scaled_h = (@height * @scale).to_i
        (0..(@width/@grid_width)).each do |x|
            w = (x * @grid_width * @scale).to_i
            painter.drawLine( w, 0, w, scaled_h)
        end
        (0..(@height/@grid_height)).each do |y|
            h = (y * @grid_height * @scale).to_i
            painter.drawLine( 0, h, scaled_w, h)
         end
        painter.end
    end
end

