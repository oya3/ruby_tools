# coding: cp932

require 'win32ole'
require 'stringio'

class WIN32OLE
    @const_defined = Hash.new
    
    def WIN32OLE.const_load_ex(obj, name)
        # �W���G���[�o�͂����_�C���N�g
        sio = StringIO.new
        $stderr = sio
        # �萔�����[�h
        WIN32OLE.const_load(obj, name)
        # �W���G���[�o�͂����ɖ߂�
        $stderr = STDERR
    end
    
    def WIN32OLE.new_with_const(prog_id, const_name_space)
        result = WIN32OLE.new(prog_id)
        unless @const_defined[const_name_space] then
            WIN32OLE.const_load_ex(result, const_name_space)
            @const_defined[const_name_space] = true
        end
        return result
    end
end
