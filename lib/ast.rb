class MySQLParser
  class AST
    def initialize(a_name, a_subname, a_val)
      @name = a_name
      @subname = a_subname
      @val = a_val
    end

    def update(a_name, a_subname, a_val)
      initialize(a_name, a_subname, a_val)
    end

    def match(options)
      (
        {top: true}.merge(options)[:top] &&
        @name == options[:name] &&
        (options[:subname].nil? || @subname == options[:subname])
      )
    end

    def find_all(options={})
      ret = []
      ret << self if match options
      sub_options = options.merge top: true
      @val.each do |v|
        if v.is_a? AST
          ret.concat (v.find_all sub_options)
        end
      end
      ret
    end

    def find_left(options={})
      return self if match options
      sub_options = options.merge top: true
      @val.each do |v|
        if v.is_a? AST
          ret = v.find_left sub_options
          return ret if ret
        end
      end
      nil
    end

    def find_top(options={})
      return self if match options
      sub_options = options.merge top: true
      @val.each do |v|
        if v.is_a? AST
          return v if v.match sub_options
        end
      end
      nil
    end

    def name
      @name
    end

    def subname
      @subname
    end

    def val
      @val
    end

    def val=(a_val)
      @val = a_val
    end

    def eval
      to_s.to_f
    end

    def to_list
      to_list_helper.flatten
    end

    def to_s
      @val.map { |v| v.to_s }.join
    end

    def norm_name
      s_all = to_s.strip
      node = find_left(name: :r_tbl_name) || find_left(name: :ident)
      s = node.to_s.strip
      raise 'Internal Error: trying to normalize not-a-name' if s_all != s
      if s.start_with? '`'
        s[1..-2] # strip ` from both beginning and end
      else
        s
      end
    end

    def inspect
      "<#{@name}: #{@val}>"
    end

    protected

    def to_list_helper
      @val.map { |v|
        if v.is_a?(AST) && v.name == @name
          v.to_list_helper
        else
          [v]
        end
      }
    end
  end
end
