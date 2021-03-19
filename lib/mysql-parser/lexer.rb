#--
# DO NOT MODIFY!!!!
# This file is automatically generated by rex 1.0.7
# from lexical definition file "mysql.rex.rb".
#++

require 'racc/parser'
class MySQLParser < Racc::Parser
      require 'strscan'

      class ScanError < StandardError ; end

      attr_reader   :lineno
      attr_reader   :filename
      attr_accessor :state

      def scan_setup(str)
        @ss = StringScanner.new(str)
        @lineno =  1
        @state  = nil
      end

      def action
        yield
      end

      def scan_str(str)
        scan_setup(str)
        do_parse
      end
      alias :scan :scan_str

      def load_file( filename )
        @filename = filename
        File.open(filename, "r") do |f|
          scan_setup(f.read)
        end
      end

      def scan_file( filename )
        load_file(filename)
        do_parse
      end


        def next_token
          return if @ss.eos?

          # skips empty actions
          until token = _next_token or @ss.eos?; end
          token
        end

        def _next_token
          text = @ss.peek(1)
          @lineno  +=  1  if text == "\n"
          token = case @state
            when nil
          case
                  when (text = @ss.scan(/\A/i))
                     action { @state = :A_NIL; nil }

          
          else
            text = @ss.string[@ss.pos .. -1]
            raise  ScanError, "can not match: '" + text + "'"
          end  # if

            when :A_NIL
          case
                  when (text = @ss.scan(/ *\/\*/i))
                     action { @state = :A_REM_MULTI; [:S_REM_IN, [text, ' /* ']] }

                  when (text = @ss.scan(/ *(\#|--)/i))
                     action { @state = :A_REM_INLINE; [:S_REM_IN, '-- '] }

                  when (text = @ss.scan(/`/i))
                     action { @state = :A_BACKTICK; [:S_BACKTICK_IN, text] }

                  when (text = @ss.scan(/"/i))
                     action { @state = :A_DOUBLEQUOTE; [:S_DOUBLEQUOTE_IN, text] }

                  when (text = @ss.scan(/'/i))
                     action { @state = :A_SINGLEQUOTE; [:S_SINGLEQUOTE_IN, text] }

                  when (text = @ss.scan(/TRUE\b/i))
                     action { [:S_ONE, text] }

                  when (text = @ss.scan(/FALSE\b/i))
                     action { [:S_ZERO, text] }

                  when (text = @ss.scan(/BOOLEAN\b/i))
                     action { [:TINYINT, text] }

                  when (text = @ss.scan(/CHARSET\b/i))
                     action { [:L_CHARACTER_SET, text] }

                  when (text = @ss.scan(/CHARACTER[ \t\n]+SET\b/i))
                     action { [:L_CHARACTER_SET, text] }

                  when (text = @ss.scan(/FROM\b/i))
                     action { [:FROM, text] }

                  when (text = @ss.scan(/WHERE\b/i))
                     action { [:WHERE, text] }

                  when (text = @ss.scan(/ZEROFILL\b/i))
                     action { [:ZEROFILL, text] }

                  when (text = @ss.scan(/YEAR\b/i))
                     action { [:YEAR, text] }

                  when (text = @ss.scan(/WITH\b/i))
                     action { [:WITH, text] }

                  when (text = @ss.scan(/VIEW\b/i))
                     action { [:VIEW, text] }

                  when (text = @ss.scan(/VARCHAR\b/i))
                     action { [:VARCHAR, text] }

                  when (text = @ss.scan(/VARBINARY\b/i))
                     action { [:VARBINARY, text] }

                  when (text = @ss.scan(/VALUES\b/i))
                     action { [:VALUES, text] }

                  when (text = @ss.scan(/UTF8MB4\b/i))
                     action { [:UTF8MB4, text] }

                  when (text = @ss.scan(/UTF8MB3\b/i))
                     action { [:UTF8MB3, text] }

                  when (text = @ss.scan(/UTF8\b/i))
                     action { [:UTF8, text] }

                  when (text = @ss.scan(/USING\b/i))
                     action { [:USING, text] }

                  when (text = @ss.scan(/UPDATE\b/i))
                     action { [:UPDATE, text] }

                  when (text = @ss.scan(/UNSIGNED\b/i))
                     action { [:UNSIGNED, text] }

                  when (text = @ss.scan(/UNIQUE\b/i))
                     action { [:UNIQUE, text] }

                  when (text = @ss.scan(/UNION\b/i))
                     action { [:UNION, text] }

                  when (text = @ss.scan(/UNDEFINED\b/i))
                     action { [:UNDEFINED, text] }

                  when (text = @ss.scan(/TRUNCATE\b/i))
                     action { [:TRUNCATE, text] }

                  when (text = @ss.scan(/TO\b/i))
                     action { [:TO, text] }

                  when (text = @ss.scan(/TINYTEXT\b/i))
                     action { [:TINYTEXT, text] }

                  when (text = @ss.scan(/TINYINT\b/i))
                     action { [:TINYINT, text] }

                  when (text = @ss.scan(/TINYBLOB\b/i))
                     action { [:TINYBLOB, text] }

                  when (text = @ss.scan(/TIMESTAMP\b/i))
                     action { [:TIMESTAMP, text] }

                  when (text = @ss.scan(/TIME\b/i))
                     action { [:TIME, text] }

                  when (text = @ss.scan(/THAN\b/i))
                     action { [:THAN, text] }

                  when (text = @ss.scan(/TEXT\b/i))
                     action { [:TEXT, text] }

                  when (text = @ss.scan(/TEMPTABLE\b/i))
                     action { [:TEMPTABLE, text] }

                  when (text = @ss.scan(/TEMPORARY\b/i))
                     action { [:TEMPORARY, text] }

                  when (text = @ss.scan(/TABLESPACE\b/i))
                     action { [:TABLESPACE, text] }

                  when (text = @ss.scan(/TABLE\b/i))
                     action { [:TABLE, text] }

                  when (text = @ss.scan(/SUBPARTITION\b/i))
                     action { [:SUBPARTITION, text] }

                  when (text = @ss.scan(/STORAGE\b/i))
                     action { [:STORAGE, text] }

                  when (text = @ss.scan(/SRID\b/i))
                     action { [:SRID, text] }

                  when (text = @ss.scan(/SQL\b/i))
                     action { [:SQL, text] }

                  when (text = @ss.scan(/SPATIAL\b/i))
                     action { [:SPATIAL, text] }

                  when (text = @ss.scan(/SMALLINT\b/i))
                     action { [:SMALLINT, text] }

                  when (text = @ss.scan(/SIMPLE\b/i))
                     action { [:SIMPLE, text] }

                  when (text = @ss.scan(/SET\b/i))
                     action { [:SET, text] }

                  when (text = @ss.scan(/SELECT\b/i))
                     action { [:SELECT, text] }

                  when (text = @ss.scan(/SECURITY\b/i))
                     action { [:SECURITY, text] }

                  when (text = @ss.scan(/ROW_FORMAT\b/i))
                     action { [:ROW_FORMAT, text] }

                  when (text = @ss.scan(/RESTRICT\b/i))
                     action { [:RESTRICT, text] }

                  when (text = @ss.scan(/REPLACE\b/i))
                     action { [:REPLACE, text] }

                  when (text = @ss.scan(/REPAIR\b/i))
                     action { [:REPAIR, text] }

                  when (text = @ss.scan(/REORGANIZE\b/i))
                     action { [:REORGANIZE, text] }

                  when (text = @ss.scan(/RENAME\b/i))
                     action { [:RENAME, text] }

                  when (text = @ss.scan(/REMOVE\b/i))
                     action { [:REMOVE, text] }

                  when (text = @ss.scan(/REFERENCES\b/i))
                     action { [:REFERENCES, text] }

                  when (text = @ss.scan(/REDUNDANT\b/i))
                     action { [:REDUNDANT, text] }

                  when (text = @ss.scan(/REBUILD\b/i))
                     action { [:REBUILD, text] }

                  when (text = @ss.scan(/REAL\b/i))
                     action { [:REAL, text] }

                  when (text = @ss.scan(/PRIMARY\b/i))
                     action { [:PRIMARY, text] }

                  when (text = @ss.scan(/PASSWORD\b/i))
                     action { [:PASSWORD, text] }

                  when (text = @ss.scan(/PARTITIONING\b/i))
                     action { [:PARTITIONING, text] }

                  when (text = @ss.scan(/PARTITION\b/i))
                     action { [:PARTITION, text] }

                  when (text = @ss.scan(/PARTIAL\b/i))
                     action { [:PARTIAL, text] }

                  when (text = @ss.scan(/PARSER\b/i))
                     action { [:PARSER, text] }

                  when (text = @ss.scan(/PACK_KEYS\b/i))
                     action { [:PACK_KEYS, text] }

                  when (text = @ss.scan(/ORDER\b/i))
                     action { [:ORDER, text] }

                  when (text = @ss.scan(/OR\b/i))
                     action { [:OR, text] }

                  when (text = @ss.scan(/OPTION\b/i))
                     action { [:OPTION, text] }

                  when (text = @ss.scan(/OPTIMIZE\b/i))
                     action { [:OPTIMIZE, text] }

                  when (text = @ss.scan(/ONLINE\b/i))
                     action { [:ONLINE, text] }

                  when (text = @ss.scan(/ON\b/i))
                     action { [:ON, text] }

                  when (text = @ss.scan(/OFFLINE\b/i))
                     action { [:OFFLINE, text] }

                  when (text = @ss.scan(/NUMERIC\b/i))
                     action { [:NUMERIC, text] }

                  when (text = @ss.scan(/NULL\b/i))
                     action { [:NULL, text] }

                  when (text = @ss.scan(/NOT\b/i))
                     action { [:NOT, text] }

                  when (text = @ss.scan(/NODEGROUP\b/i))
                     action { [:NODEGROUP, text] }

                  when (text = @ss.scan(/NO\b/i))
                     action { [:NO, text] }

                  when (text = @ss.scan(/MODIFY\b/i))
                     action { [:MODIFY, text] }

                  when (text = @ss.scan(/MIN_ROWS\b/i))
                     action { [:MIN_ROWS, text] }

                  when (text = @ss.scan(/MERGE\b/i))
                     action { [:MERGE, text] }

                  when (text = @ss.scan(/MEMORY\b/i))
                     action { [:MEMORY, text] }

                  when (text = @ss.scan(/MEDIUMTEXT\b/i))
                     action { [:MEDIUMTEXT, text] }

                  when (text = @ss.scan(/MEDIUMINT\b/i))
                     action { [:MEDIUMINT, text] }

                  when (text = @ss.scan(/MEDIUMBLOB\b/i))
                     action { [:MEDIUMBLOB, text] }

                  when (text = @ss.scan(/MAX_ROWS\b/i))
                     action { [:MAX_ROWS, text] }

                  when (text = @ss.scan(/MAXVALUE\b/i))
                     action { [:MAXVALUE, text] }

                  when (text = @ss.scan(/MATCH\b/i))
                     action { [:MATCH, text] }

                  when (text = @ss.scan(/LONGTEXT\b/i))
                     action { [:LONGTEXT, text] }

                  when (text = @ss.scan(/LONGBLOB\b/i))
                     action { [:LONGBLOB, text] }

                  when (text = @ss.scan(/LOCAL\b/i))
                     action { [:LOCAL, text] }

                  when (text = @ss.scan(/LINESTRING\b/i))
                     action { [:LINESTRING, text] }

                  when (text = @ss.scan(/LIKE\b/i))
                     action { [:LIKE, text] }

                  when (text = @ss.scan(/LESS\b/i))
                     action { [:LESS, text] }

                  when (text = @ss.scan(/LATIN1\b/i))
                     action { [:LATIN1, text] }

                  when (text = @ss.scan(/LAST\b/i))
                     action { [:LAST, text] }

                  when (text = @ss.scan(/KEY_BLOCK_SIZE\b/i))
                     action { [:KEY_BLOCK_SIZE, text] }

                  when (text = @ss.scan(/KEYS\b/i))
                     action { [:KEYS, text] }

                  when (text = @ss.scan(/KEY\b/i))
                     action { [:KEY, text] }

                  when (text = @ss.scan(/INVOKER\b/i))
                     action { [:INVOKER, text] }

                  when (text = @ss.scan(/INTO\b/i))
                     action { [:INTO, text] }

                  when (text = @ss.scan(/INTEGER\b/i))
                     action { [:INTEGER, text] }

                  when (text = @ss.scan(/INT\b/i))
                     action { [:INT, text] }

                  when (text = @ss.scan(/INSERT_METHOD\b/i))
                     action { [:INSERT_METHOD, text] }

                  when (text = @ss.scan(/INNODB\b/i))
                     action { [:INNODB, text] }

                  when (text = @ss.scan(/INDEX\b/i))
                     action { [:INDEX, text] }

                  when (text = @ss.scan(/IN\b/i))
                     action { [:IN, text] }

                  when (text = @ss.scan(/IMPORT\b/i))
                     action { [:IMPORT, text] }

                  when (text = @ss.scan(/IGNORE\b/i))
                     action { [:IGNORE, text] }

                  when (text = @ss.scan(/IF\b/i))
                     action { [:IF, text] }

                  when (text = @ss.scan(/HASH\b/i))
                     action { [:HASH, text] }

                  when (text = @ss.scan(/FULLTEXT\b/i))
                     action { [:FULLTEXT, text] }

                  when (text = @ss.scan(/FULL\b/i))
                     action { [:FULL, text] }

                  when (text = @ss.scan(/FOREIGN\b/i))
                     action { [:FOREIGN, text] }

                  when (text = @ss.scan(/FLOAT\b/i))
                     action { [:FLOAT, text] }

                  when (text = @ss.scan(/FIXED\b/i))
                     action { [:FIXED, text] }

                  when (text = @ss.scan(/FIRST\b/i))
                     action { [:FIRST, text] }

                  when (text = @ss.scan(/EXISTS\b/i))
                     action { [:EXISTS, text] }

                  when (text = @ss.scan(/ENUM\b/i))
                     action { [:ENUM, text] }

                  when (text = @ss.scan(/ENGINE\b/i))
                     action { [:ENGINE, text] }

                  when (text = @ss.scan(/ENABLE\b/i))
                     action { [:ENABLE, text] }

                  when (text = @ss.scan(/DYNAMIC\b/i))
                     action { [:DYNAMIC, text] }

                  when (text = @ss.scan(/DROP\b/i))
                     action { [:DROP, text] }

                  when (text = @ss.scan(/DOUBLE\b/i))
                     action { [:DOUBLE, text] }

                  when (text = @ss.scan(/DISK\b/i))
                     action { [:DISK, text] }

                  when (text = @ss.scan(/DISCARD\b/i))
                     action { [:DISCARD, text] }

                  when (text = @ss.scan(/DISABLE\b/i))
                     action { [:DISABLE, text] }

                  when (text = @ss.scan(/DIRECTORY\b/i))
                     action { [:DIRECTORY, text] }

                  when (text = @ss.scan(/DESC\b/i))
                     action { [:DESC, text] }

                  when (text = @ss.scan(/DELETE\b/i))
                     action { [:DELETE, text] }

                  when (text = @ss.scan(/DELAY_KEY_WRITE\b/i))
                     action { [:DELAY_KEY_WRITE, text] }

                  when (text = @ss.scan(/DEFINER\b/i))
                     action { [:DEFINER, text] }

                  when (text = @ss.scan(/DEFAULT\b/i))
                     action { [:DEFAULT, text] }

                  when (text = @ss.scan(/DECIMAL\b/i))
                     action { [:DECIMAL, text] }

                  when (text = @ss.scan(/DATETIME\b/i))
                     action { [:DATETIME, text] }

                  when (text = @ss.scan(/DATE\b/i))
                     action { [:DATE, text] }

                  when (text = @ss.scan(/DATA\b/i))
                     action { [:DATA, text] }

                  when (text = @ss.scan(/CURRENT_USER\b/i))
                     action { [:CURRENT_USER, text] }

                  when (text = @ss.scan(/CURRENT_TIMESTAMP\b/i))
                     action { [:CURRENT_TIMESTAMP, text] }

                  when (text = @ss.scan(/CREATE\b/i))
                     action { [:CREATE, text] }

                  when (text = @ss.scan(/CONVERT\b/i))
                     action { [:CONVERT, text] }

                  when (text = @ss.scan(/CONSTRAINT\b/i))
                     action { [:CONSTRAINT, text] }

                  when (text = @ss.scan(/CONNECTION\b/i))
                     action { [:CONNECTION, text] }

                  when (text = @ss.scan(/COMPRESSED\b/i))
                     action { [:COMPRESSED, text] }

                  when (text = @ss.scan(/COMPACT\b/i))
                     action { [:COMPACT, text] }

                  when (text = @ss.scan(/COMMENT\b/i))
                     action { [:COMMENT, text] }

                  when (text = @ss.scan(/COLUMN_FORMAT\b/i))
                     action { [:COLUMN_FORMAT, text] }

                  when (text = @ss.scan(/COLUMN\b/i))
                     action { [:COLUMN, text] }

                  when (text = @ss.scan(/COLLATE\b/i))
                     action { [:COLLATE, text] }

                  when (text = @ss.scan(/COALESCE\b/i))
                     action { [:COALESCE, text] }

                  when (text = @ss.scan(/CHECKSUM\b/i))
                     action { [:CHECKSUM, text] }

                  when (text = @ss.scan(/CHECK\b/i))
                     action { [:CHECK, text] }

                  when (text = @ss.scan(/CHAR\b/i))
                     action { [:CHAR, text] }

                  when (text = @ss.scan(/CHANGE\b/i))
                     action { [:CHANGE, text] }

                  when (text = @ss.scan(/CASCADED\b/i))
                     action { [:CASCADED, text] }

                  when (text = @ss.scan(/CASCADE\b/i))
                     action { [:CASCADE, text] }

                  when (text = @ss.scan(/BY\b/i))
                     action { [:BY, text] }

                  when (text = @ss.scan(/BTREE\b/i))
                     action { [:BTREE, text] }

                  when (text = @ss.scan(/BLOB\b/i))
                     action { [:BLOB, text] }

                  when (text = @ss.scan(/BIT\b/i))
                     action { [:BIT, text] }

                  when (text = @ss.scan(/BINARY\b/i))
                     action { [:BINARY, text] }

                  when (text = @ss.scan(/BIGINT\b/i))
                     action { [:BIGINT, text] }

                  when (text = @ss.scan(/AVG_ROW_LENGTH\b/i))
                     action { [:AVG_ROW_LENGTH, text] }

                  when (text = @ss.scan(/AUTO_INCREMENT\b/i))
                     action { [:AUTO_INCREMENT, text] }

                  when (text = @ss.scan(/ASC\b/i))
                     action { [:ASC, text] }

                  when (text = @ss.scan(/AS\b/i))
                     action { [:AS, text] }

                  when (text = @ss.scan(/ANALYZE\b/i))
                     action { [:ANALYZE, text] }

                  when (text = @ss.scan(/ALTER\b/i))
                     action { [:ALTER, text] }

                  when (text = @ss.scan(/ALL\b/i))
                     action { [:ALL, text] }

                  when (text = @ss.scan(/ALGORITHM\b/i))
                     action { [:ALGORITHM, text] }

                  when (text = @ss.scan(/AFTER\b/i))
                     action { [:AFTER, text] }

                  when (text = @ss.scan(/ADD\b/i))
                     action { [:ADD, text] }

                  when (text = @ss.scan(/ACTION\b/i))
                     action { [:ACTION, text] }

                  when (text = @ss.scan(/,/i))
                     action { [:S_COMMA        , text] }

                  when (text = @ss.scan(/@/i))
                     action { [:S_AT           , text] }

                  when (text = @ss.scan(/0+\b/i))
                     action { [:S_ZERO         , text] } # this must come before S_NAT

                  when (text = @ss.scan(/1\b/i))
                     action { [:S_ONE          , text] } # this must come before S_NAT

                  when (text = @ss.scan(/\d+/i))
                     action { [:S_NAT          , text] } # definitely not 0, 1

                  when (text = @ss.scan(/-?\d+\.\d+/i))
                     action { [:S_FLOAT        , text] } # this must come before S_DOT

                  when (text = @ss.scan(/[\$a-zA-Z0-9_]+/i))
                     action { [:S_IDENT_NORMAL , text] }

                  when (text = @ss.scan(/=/i))
                     action { [:S_EQUAL        , text] }

                  when (text = @ss.scan(/\(/i))
                     action { [:S_LEFT_PAREN   , text] }

                  when (text = @ss.scan(/\)/i))
                     action { [:S_RIGHT_PAREN  , text] }

                  when (text = @ss.scan(/-/i))
                     action { [:S_MINUS        , text] }

                  when (text = @ss.scan(/\./i))
                     action { [:S_DOT          , text] }

                  when (text = @ss.scan(/[ \t\n]+/i))
                     action { [:S_SPACE, ' '] } # set to one space

          
          else
            text = @ss.string[@ss.pos .. -1]
            raise  ScanError, "can not match: '" + text + "'"
          end  # if

            when :A_REM_MULTI
          case
                  when (text = @ss.scan(/\*\/ */i))
                     action { @state = :A_NIL; [:S_REM_OUT, ' */ '] }

                  when (text = @ss.scan(/(.+)(?=\*\/ *)/i))
                     action { [:S_COMMENT, text] }

          
          else
            text = @ss.string[@ss.pos .. -1]
            raise  ScanError, "can not match: '" + text + "'"
          end  # if

            when :A_REM_INLINE
          case
                  when (text = @ss.scan(/\n/i))
                     action { @state = :A_NIL; [:S_REM_OUT, text] }

                  when (text = @ss.scan(/.*(?=$)/i))
                     action { [:S_COMMENT, text] }

          
          else
            text = @ss.string[@ss.pos .. -1]
            raise  ScanError, "can not match: '" + text + "'"
          end  # if

            when :A_BACKTICK
          case
                  when (text = @ss.scan(/``/i))
                     action { [:S_IDENT_IN_BACKTICK, text] }

                  when (text = @ss.scan(/`/i))
                     action { @state = :A_NIL; [:S_BACKTICK_OUT, text] }

                  when (text = @ss.scan(/[^`]+/i))
                     action { [:S_IDENT_IN_BACKTICK, text] }

          
          else
            text = @ss.string[@ss.pos .. -1]
            raise  ScanError, "can not match: '" + text + "'"
          end  # if

            when :A_DOUBLEQUOTE
          case
                  when (text = @ss.scan(/""/i))
                     action { [:S_STRING_IN_QUOTE, text] }

                  when (text = @ss.scan(/"/i))
                     action { @state = :A_NIL; [:S_DOUBLEQUOTE_OUT, text] }

                  when (text = @ss.scan(/[^"]*/i))
                     action { [:S_STRING_IN_QUOTE, text] }

          
          else
            text = @ss.string[@ss.pos .. -1]
            raise  ScanError, "can not match: '" + text + "'"
          end  # if

            when :A_SINGLEQUOTE
          case
                  when (text = @ss.scan(/''/i))
                     action { [:S_STRING_IN_QUOTE, text] }

                  when (text = @ss.scan(/'/i))
                     action { @state = :A_NIL; [:S_SINGLEQUOTE_OUT, text] }

                  when (text = @ss.scan(/[^']*/i))
                     action { [:S_STRING_IN_QUOTE, text] }

          
          else
            text = @ss.string[@ss.pos .. -1]
            raise  ScanError, "can not match: '" + text + "'"
          end  # if

        else
          raise  ScanError, "undefined state: '" + state.to_s + "'"
        end  # case state
          token
        end  # def _next_token

  def tokenize(code)
    scan_setup(code)
    tokens = []
    while token = next_token
      tokens << token
    end
    tokens
  end
end # class
