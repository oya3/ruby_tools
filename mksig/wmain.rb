# coding: utf-8
# -*- coding: utf-8 -*-

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__))+'/../common_modules/')

require 'Qt4'
require 'signature_widget'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

app = Qt::Application.new(ARGV)
widget = SignatureWidgt.new
widget.show
app.exec

