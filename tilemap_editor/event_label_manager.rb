# -*- coding: utf-8 -*-

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'Qt4'
require 'event_label'

class EventLabelManager < Qt::Object
    def self.getEventData(params)
        events = params['events']
        filepath = params['path'] + '/' + events['file'] # json ファイル読み込み
        event_json_data = open(filepath) do |io|
            JSON.load(io)
        end
        event_id2name = Hash.new
        event_json_data['data'].each do |hash|
            event_id2name[hash['id']] = hash['name'].force_encoding('utf-8')
        end
        eventData = Array.new
        events['data'].each do |hash|
            one = Hash.new
            one[:id] = hash['id']
            one[:name] = event_id2name[ hash['id'] ]
            one[:pos] = Qt::Point.new( hash['x'],hash['y'])
           eventData.push(one)
        end
        return eventData
    end

    def self.getEventList(params)
        events = params['events']
        filepath = params['path'] + '/' + events['file'] # json ファイル読み込み
        event_list = open(filepath) do |io|
            JSON.load(io)
        end
        return event_list
    end

    def initialize(parentWidget = nil)
        super parentWidget
        @events = Hash.new
    end

    # 追加
    def add(obj_id,id,pos)
        values = Hash.new
        values[:id] = id
        values[:pos] = pos
        @events[obj_id] = values
    end
    
    
    # 削除
    def del(obj_id)
        @events.delete(obj_id)
    end

    # 指定方向でソート ASC(昇順), DESC(降順)
    def getSortEventList(direction='x', oder_by='asc')
        array = nil
        if( direction == 'x' ) then
            array = @events.sort{|a,b| a[1][:pos].x <=> b[1][:pos].x }
        else
            array = @events.sort{|a,b| a[1][:pos].y <=> b[1][:pos].y }
        end
        if( oder_by == 'desc' ) then
            array.reverse!
        end
        return array
    end
    
    # # テストコード
    # h = {
    #     10 => { :id => 0, :pos => 100},
    #     1 => { :id => 0, :pos => 10},
    #     5 => { :id => 0, :pos => 1}
    # }
    # h.sort{|a,b| a[1][:pos] <=> b[1][:pos] }
    
end

