class MySQLParser

option
  ignorecase

macro
  S                     [\ \t\n]+ 
  BACKTICK              `                                                     #`
  IDENT_IN_BACKTICK     [^`]+                                                 #`
  DOUBLEQUOTE           "                                                     #"
  STRING_IN_DOUBLEQUOTE [^"]*                                                 #"
  SINGLEQUOTE           '                                                     #'
  STRING_IN_SINGLEQUOTE [^']*                                                 #'
  REMIN                 \ *\/\*
  REMOUT                \*\/\ *
  REM                   \ *(\#|--)
  IDENT_NORMAL          [\$a-zA-Z0-9_]+
  NAT                   \d+
  FLOAT                 -?\d+\.\d+
  ZERO                  0+\b # don't know if this is a good idea
  ONE                   1\b  # don't know if this is a good idea
  BEGINNING             \A
  

rule

# beginning
                 {BEGINNING}                { @state = :A_NIL; nil }
# things that are paired                    
:A_NIL           {REMIN}                    { @state = :A_REM_MULTI; [:S_REM_IN, [text, ' /* ']] }
:A_REM_MULTI     {REMOUT}                   { @state = :A_NIL; [:S_REM_OUT, ' */ '] }
:A_REM_MULTI     (.+)(?={REMOUT})           { [:S_COMMENT, text] }
:A_NIL           {REM}                      { @state = :A_REM_INLINE; [:S_REM_IN, '-- '] }
:A_REM_INLINE    \n                         { @state = :A_NIL; [:S_REM_OUT, text] }
:A_REM_INLINE    .*(?=$)                    { [:S_COMMENT, text] }
:A_NIL           {BACKTICK}                 { @state = :A_BACKTICK; [:S_BACKTICK_IN, text] }
:A_BACKTICK      {BACKTICK}{BACKTICK}       { [:S_IDENT_IN_BACKTICK, text] }
:A_BACKTICK      {BACKTICK}                 { @state = :A_NIL; [:S_BACKTICK_OUT, text] }
:A_BACKTICK      {IDENT_IN_BACKTICK}        { [:S_IDENT_IN_BACKTICK, text] }
:A_NIL           {DOUBLEQUOTE}              { @state = :A_DOUBLEQUOTE; [:S_DOUBLEQUOTE_IN, text] }
:A_DOUBLEQUOTE   {DOUBLEQUOTE}{DOUBLEQUOTE} { [:S_STRING_IN_QUOTE, text] }
:A_DOUBLEQUOTE   {DOUBLEQUOTE}              { @state = :A_NIL; [:S_DOUBLEQUOTE_OUT, text] }
:A_DOUBLEQUOTE   {STRING_IN_DOUBLEQUOTE}    { [:S_STRING_IN_QUOTE, text] }
:A_NIL           {SINGLEQUOTE}              { @state = :A_SINGLEQUOTE; [:S_SINGLEQUOTE_IN, text] }
:A_SINGLEQUOTE   {SINGLEQUOTE}{SINGLEQUOTE} { [:S_STRING_IN_QUOTE, text] }
:A_SINGLEQUOTE   {SINGLEQUOTE}              { @state = :A_NIL; [:S_SINGLEQUOTE_OUT, text] }
:A_SINGLEQUOTE   {STRING_IN_SINGLEQUOTE}    { [:S_STRING_IN_QUOTE, text] }

# SYNONYM
:A_NIL TRUE\b { [:S_ONE, text] }
:A_NIL FALSE\b { [:S_ZERO, text] }
:A_NIL BOOLEAN\b { [:TINYINT, text] }
:A_NIL CHARSET\b { [:L_CHARACTER_SET, text] }

# LONG LITERAL
:A_NIL CHARACTER{S}SET\b { [:L_CHARACTER_SET, text] }

# LITERAL THAT DOESN'T EXIST IN THE GRAMMAR FILE
:A_NIL FROM\b { [:FROM, text] }
:A_NIL WHERE\b { [:WHERE, text] }

# DO NOT EDIT THIS BELOW SECTION
# BEGIN LITERAL (AUTO-GENERATED)
:A_NIL ZEROFILL\b { [:ZEROFILL, text] }
:A_NIL YEAR\b { [:YEAR, text] }
:A_NIL WITH\b { [:WITH, text] }
:A_NIL VIEW\b { [:VIEW, text] }
:A_NIL VARCHAR\b { [:VARCHAR, text] }
:A_NIL VARBINARY\b { [:VARBINARY, text] }
:A_NIL VALUES\b { [:VALUES, text] }
:A_NIL UTF8MB4\b { [:UTF8MB4, text] }
:A_NIL UTF8MB3\b { [:UTF8MB3, text] }
:A_NIL UTF8\b { [:UTF8, text] }
:A_NIL USING\b { [:USING, text] }
:A_NIL UPDATE\b { [:UPDATE, text] }
:A_NIL UNSIGNED\b { [:UNSIGNED, text] }
:A_NIL UNIQUE\b { [:UNIQUE, text] }
:A_NIL UNION\b { [:UNION, text] }
:A_NIL UNDEFINED\b { [:UNDEFINED, text] }
:A_NIL TRUNCATE\b { [:TRUNCATE, text] }
:A_NIL TO\b { [:TO, text] }
:A_NIL TINYTEXT\b { [:TINYTEXT, text] }
:A_NIL TINYINT\b { [:TINYINT, text] }
:A_NIL TINYBLOB\b { [:TINYBLOB, text] }
:A_NIL TIMESTAMP\b { [:TIMESTAMP, text] }
:A_NIL TIME\b { [:TIME, text] }
:A_NIL THAN\b { [:THAN, text] }
:A_NIL TEXT\b { [:TEXT, text] }
:A_NIL TEMPTABLE\b { [:TEMPTABLE, text] }
:A_NIL TEMPORARY\b { [:TEMPORARY, text] }
:A_NIL TABLESPACE\b { [:TABLESPACE, text] }
:A_NIL TABLE\b { [:TABLE, text] }
:A_NIL SUBPARTITION\b { [:SUBPARTITION, text] }
:A_NIL STORAGE\b { [:STORAGE, text] }
:A_NIL SRID\b { [:SRID, text] }
:A_NIL SQL\b { [:SQL, text] }
:A_NIL SPATIAL\b { [:SPATIAL, text] }
:A_NIL SMALLINT\b { [:SMALLINT, text] }
:A_NIL SIMPLE\b { [:SIMPLE, text] }
:A_NIL SET\b { [:SET, text] }
:A_NIL SELECT\b { [:SELECT, text] }
:A_NIL SECURITY\b { [:SECURITY, text] }
:A_NIL ROW_FORMAT\b { [:ROW_FORMAT, text] }
:A_NIL RESTRICT\b { [:RESTRICT, text] }
:A_NIL REPLACE\b { [:REPLACE, text] }
:A_NIL REPAIR\b { [:REPAIR, text] }
:A_NIL REORGANIZE\b { [:REORGANIZE, text] }
:A_NIL RENAME\b { [:RENAME, text] }
:A_NIL REMOVE\b { [:REMOVE, text] }
:A_NIL REFERENCES\b { [:REFERENCES, text] }
:A_NIL REDUNDANT\b { [:REDUNDANT, text] }
:A_NIL REBUILD\b { [:REBUILD, text] }
:A_NIL REAL\b { [:REAL, text] }
:A_NIL PRIMARY\b { [:PRIMARY, text] }
:A_NIL PASSWORD\b { [:PASSWORD, text] }
:A_NIL PARTITIONING\b { [:PARTITIONING, text] }
:A_NIL PARTITION\b { [:PARTITION, text] }
:A_NIL PARTIAL\b { [:PARTIAL, text] }
:A_NIL PARSER\b { [:PARSER, text] }
:A_NIL PACK_KEYS\b { [:PACK_KEYS, text] }
:A_NIL ORDER\b { [:ORDER, text] }
:A_NIL OR\b { [:OR, text] }
:A_NIL OPTION\b { [:OPTION, text] }
:A_NIL OPTIMIZE\b { [:OPTIMIZE, text] }
:A_NIL ONLINE\b { [:ONLINE, text] }
:A_NIL ON\b { [:ON, text] }
:A_NIL OFFLINE\b { [:OFFLINE, text] }
:A_NIL NUMERIC\b { [:NUMERIC, text] }
:A_NIL NULL\b { [:NULL, text] }
:A_NIL NOT\b { [:NOT, text] }
:A_NIL NODEGROUP\b { [:NODEGROUP, text] }
:A_NIL NO\b { [:NO, text] }
:A_NIL MODIFY\b { [:MODIFY, text] }
:A_NIL MIN_ROWS\b { [:MIN_ROWS, text] }
:A_NIL MERGE\b { [:MERGE, text] }
:A_NIL MEMORY\b { [:MEMORY, text] }
:A_NIL MEDIUMTEXT\b { [:MEDIUMTEXT, text] }
:A_NIL MEDIUMINT\b { [:MEDIUMINT, text] }
:A_NIL MEDIUMBLOB\b { [:MEDIUMBLOB, text] }
:A_NIL MAX_ROWS\b { [:MAX_ROWS, text] }
:A_NIL MAXVALUE\b { [:MAXVALUE, text] }
:A_NIL MATCH\b { [:MATCH, text] }
:A_NIL LONGTEXT\b { [:LONGTEXT, text] }
:A_NIL LONGBLOB\b { [:LONGBLOB, text] }
:A_NIL LOCAL\b { [:LOCAL, text] }
:A_NIL LINESTRING\b { [:LINESTRING, text] }
:A_NIL LIKE\b { [:LIKE, text] }
:A_NIL LESS\b { [:LESS, text] }
:A_NIL LATIN1\b { [:LATIN1, text] }
:A_NIL LAST\b { [:LAST, text] }
:A_NIL KEY_BLOCK_SIZE\b { [:KEY_BLOCK_SIZE, text] }
:A_NIL KEYS\b { [:KEYS, text] }
:A_NIL KEY\b { [:KEY, text] }
:A_NIL INVOKER\b { [:INVOKER, text] }
:A_NIL INTO\b { [:INTO, text] }
:A_NIL INTEGER\b { [:INTEGER, text] }
:A_NIL INT\b { [:INT, text] }
:A_NIL INSERT_METHOD\b { [:INSERT_METHOD, text] }
:A_NIL INNODB\b { [:INNODB, text] }
:A_NIL INDEX\b { [:INDEX, text] }
:A_NIL IN\b { [:IN, text] }
:A_NIL IMPORT\b { [:IMPORT, text] }
:A_NIL IGNORE\b { [:IGNORE, text] }
:A_NIL IF\b { [:IF, text] }
:A_NIL HASH\b { [:HASH, text] }
:A_NIL FULLTEXT\b { [:FULLTEXT, text] }
:A_NIL FULL\b { [:FULL, text] }
:A_NIL FOREIGN\b { [:FOREIGN, text] }
:A_NIL FLOAT\b { [:FLOAT, text] }
:A_NIL FIXED\b { [:FIXED, text] }
:A_NIL FIRST\b { [:FIRST, text] }
:A_NIL EXISTS\b { [:EXISTS, text] }
:A_NIL ENUM\b { [:ENUM, text] }
:A_NIL ENGINE\b { [:ENGINE, text] }
:A_NIL ENABLE\b { [:ENABLE, text] }
:A_NIL DYNAMIC\b { [:DYNAMIC, text] }
:A_NIL DROP\b { [:DROP, text] }
:A_NIL DOUBLE\b { [:DOUBLE, text] }
:A_NIL DISK\b { [:DISK, text] }
:A_NIL DISCARD\b { [:DISCARD, text] }
:A_NIL DISABLE\b { [:DISABLE, text] }
:A_NIL DIRECTORY\b { [:DIRECTORY, text] }
:A_NIL DESC\b { [:DESC, text] }
:A_NIL DELETE\b { [:DELETE, text] }
:A_NIL DELAY_KEY_WRITE\b { [:DELAY_KEY_WRITE, text] }
:A_NIL DEFINER\b { [:DEFINER, text] }
:A_NIL DEFAULT\b { [:DEFAULT, text] }
:A_NIL DECIMAL\b { [:DECIMAL, text] }
:A_NIL DATETIME\b { [:DATETIME, text] }
:A_NIL DATE\b { [:DATE, text] }
:A_NIL DATA\b { [:DATA, text] }
:A_NIL CURRENT_USER\b { [:CURRENT_USER, text] }
:A_NIL CURRENT_TIMESTAMP\b { [:CURRENT_TIMESTAMP, text] }
:A_NIL CREATE\b { [:CREATE, text] }
:A_NIL CONVERT\b { [:CONVERT, text] }
:A_NIL CONSTRAINT\b { [:CONSTRAINT, text] }
:A_NIL CONNECTION\b { [:CONNECTION, text] }
:A_NIL COMPRESSED\b { [:COMPRESSED, text] }
:A_NIL COMPACT\b { [:COMPACT, text] }
:A_NIL COMMENT\b { [:COMMENT, text] }
:A_NIL COLUMN_FORMAT\b { [:COLUMN_FORMAT, text] }
:A_NIL COLUMN\b { [:COLUMN, text] }
:A_NIL COLLATE\b { [:COLLATE, text] }
:A_NIL COALESCE\b { [:COALESCE, text] }
:A_NIL CHECKSUM\b { [:CHECKSUM, text] }
:A_NIL CHECK\b { [:CHECK, text] }
:A_NIL CHAR\b { [:CHAR, text] }
:A_NIL CHANGE\b { [:CHANGE, text] }
:A_NIL CASCADED\b { [:CASCADED, text] }
:A_NIL CASCADE\b { [:CASCADE, text] }
:A_NIL BY\b { [:BY, text] }
:A_NIL BTREE\b { [:BTREE, text] }
:A_NIL BLOB\b { [:BLOB, text] }
:A_NIL BIT\b { [:BIT, text] }
:A_NIL BINARY\b { [:BINARY, text] }
:A_NIL BIGINT\b { [:BIGINT, text] }
:A_NIL AVG_ROW_LENGTH\b { [:AVG_ROW_LENGTH, text] }
:A_NIL AUTO_INCREMENT\b { [:AUTO_INCREMENT, text] }
:A_NIL ASC\b { [:ASC, text] }
:A_NIL AS\b { [:AS, text] }
:A_NIL ANALYZE\b { [:ANALYZE, text] }
:A_NIL ALTER\b { [:ALTER, text] }
:A_NIL ALL\b { [:ALL, text] }
:A_NIL ALGORITHM\b { [:ALGORITHM, text] }
:A_NIL AFTER\b { [:AFTER, text] }
:A_NIL ADD\b { [:ADD, text] }
:A_NIL ACTION\b { [:ACTION, text] }
# END LITERAL (AUTO-GENERATED)
# DO NOT EDIT THIS ABOVE SECTION

# other things
:A_NIL ,              { [:S_COMMA        , text] }
:A_NIL @              { [:S_AT           , text] }
:A_NIL {ZERO}         { [:S_ZERO         , text] } # this must come before S_NAT
:A_NIL {ONE}          { [:S_ONE          , text] } # this must come before S_NAT
:A_NIL {NAT}          { [:S_NAT          , text] } # definitely not 0, 1
:A_NIL {FLOAT}        { [:S_FLOAT        , text] } # this must come before S_DOT
:A_NIL {IDENT_NORMAL} { [:S_IDENT_NORMAL , text] }
:A_NIL =              { [:S_EQUAL        , text] }
:A_NIL \(             { [:S_LEFT_PAREN   , text] }
:A_NIL \)             { [:S_RIGHT_PAREN  , text] }
:A_NIL -              { [:S_MINUS        , text] }
:A_NIL \.             { [:S_DOT          , text] }

# the rest should be space
:A_NIL {S} { [:S_SPACE, ' '] } # set to one space

inner
  def tokenize(code)
    scan_setup(code)
    tokens = []
    while token = next_token
      tokens << token
    end
    tokens
  end
end
