# coding: cp932

# Hashを構造体のように使えるようにするためのモジュール
module HashStruct
  NoError = true

  def method_missing(sym, *arg)
    name = sym.to_s
    case arg.size
    when 0
      arg = nil
    when 1
      arg = arg[0]
    end
    if name =~ /^(.+)=$/
      key = $1
      res = arg
      if arg
        self[key] = arg
      end
    elsif  self.member?(name)
      res = self[name]
    else
      if NoError
        self[name] = {}.structize
        res = self[name]
      else
        STDERR.printf("method missing [%s]\n", name)
        res = nil
      end
    end
    return res
  end
end

class Hash
  def structize
    unless @structize_switch
      extend HashStruct
      @structize_switch = true
    end
    return self
  end
end

=begin
dog = {}.structize
dog.name = "John"
dog.age = 4
dog.body.tail = 1
dog.body.paw = 4
p dog
=end
