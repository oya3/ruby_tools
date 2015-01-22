# -*- coding: utf-8 -*-

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'Qt4'
require 'qtuitools'

# pameters widget
class ParamtersWidget < Qt::Widget
    def initialize(parent = nil)
        super parent
        # 画面構成読み込み＆設定
        @widget = nil
        Qt::File.new("parameters.ui") do |file|
            loader = Qt::UiLoader.new
            file.open(Qt::File::ReadOnly)
            @widget = loader.load(file, self)
        end
        setMinimumSize(240,240)
        #setMaximumSize(350,400)
        #setCentralWidget(@widget)
        # layout = Qt::VBoxLayout.new
        # layout.addWidget(@formWidget)
        # setLayout(layout)
        # self.windowTitle = "パラメータ"
    end
end

