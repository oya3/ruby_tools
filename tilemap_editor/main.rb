# -*- coding: utf-8 -*-

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'Qt4'
require 'main_window'

app = Qt::Application.new(ARGV)
widget = MainWindow.new
widget.resize(1024,768)
widget.show
app.exec
