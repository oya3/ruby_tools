# -*- coding: utf-8 -*-

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'Qt4'
require 'event_label'

#  widget
class EventListWidget < Qt::Widget
    def initialize(parent = nil, parameters)
        super parent
        # setAttribute(Qt::WA_DeleteOnClose)
        @parameters = parameters
        eventList = EventLabelManager.getEventList(@parameters)
        setWindowTitle( eventList['name'] )
        y = 0
        width = 0
        eventList['data'].each do |hash|
            eventLabel = EventLabel.new(hash['id'], hash['name'].force_encoding('utf-8'), self)
            eventLabel.move(0,y)
            y += eventLabel.size.height
            if( width < eventLabel.size.width ) then
                width = eventLabel.size.width
            end
        end
        
        setAcceptDrops(false)
        setMinimumSize(width,y)
    end

    # 選択したイベントIDを通知する仕組みが必要。。。
    
end

