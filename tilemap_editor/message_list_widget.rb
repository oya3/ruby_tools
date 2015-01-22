# -*- coding: utf-8 -*-

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'Qt4'

#  widget
class MessageListWidget < Qt::Widget
    # slots 'log(const QString&)'

    def initialize(parent = nil)
        super parent
        @widget = Qt::ListWidget.new(self)
        # setAttribute(Qt::WA_DeleteOnClose)
    end

    # def addUser(user)
    #     connect(user, SIGNAL('log(const QString&)'), self, SLOT('log(const QString&)'))
    # end
    def log(string)
        addItems(string)
    end

end

