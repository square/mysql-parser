class MySQLParser

options no_result_var

rule
  root : S r_commands {
    call(:root, nil, val)
  }

  r_commands :
    r_ALTER_TABLE    { call(:r_commands, :ALTER_TABLE, val) }
  | r_CREATE_TABLE   { call(:r_commands, :CREATE_TABLE, val) }
  | r_DROP_TABLE     { call(:r_commands, :DROP_TABLE, val) }
  | r_DROP_VIEW      { call(:r_commands, :DROP_VIEW, val) }
  | r_CREATE_VIEW    { call(:r_commands, :CREATE_VIEW, val) }
  | r_TRUNCATE_TABLE { call(:r_commands, :TRUNCATE_TABLE, val) }

  # ===========================
  # ======= CREATE VIEW =======
  # ===========================

  r_CREATE_VIEW :
    CREATE S r_opt_OR_REPLACE r_opt_ALGORITHM_with_val r_opt_DEFINER_with_val
    r_opt_SQL_SECURITY VIEW S r_view_name r_opt_COLUMN_list AS S star
    { call(:r_CREATE_VIEW, nil, val) } # incomplete grammar

  r_opt_COLUMN_list :
    { call(:r_opt_COLUMN_list, :empty, val) }
  | left_paren r_comma_separated_col_name right_paren
    { call(:r_opt_COLUMN_list, :body, val) }

  r_opt_OR_REPLACE :
    { call(:r_opt_OR_REPLACE, :empty, val) }
  | OR S REPLACE S
    { call(:r_opt_OR_REPLACE, :body, val) }

  r_opt_ALGORITHM_with_val :
    { call(:r_opt_ALGORITHM_with_val, :empty, val) }
  | ALGORITHM S equal UNDEFINED S
    { call(:r_opt_ALGORITHM_with_val, :UNDEFINED, val) }
  | ALGORITHM S equal MERGE S
    { call(:r_opt_ALGORITHM_with_val, :MERGE, val) }
  | ALGORITHM S equal TEMPTABLE S
    { call(:r_opt_ALGORITHM_with_val, :TEMPTABLE, val) }

  r_opt_DEFINER_with_val :
    { call(:r_opt_DEFINER_with_val, :empty, val) }
  | DEFINER S equal r_user_name
    { call(:r_opt_DEFINER_with_val, :user_name, val) }
  | DEFINER S equal CURRENT_USER S
    { call(:r_opt_DEFINER_with_val, :CURRENT_USER, val) }

  r_opt_SQL_SECURITY :
    { call(:r_opt_SQL_SECURITY, :empty, val) }
  | SQL S SECURITY S DEFINER S
    { call(:r_opt_SQL_SECURITY, :DEFINER, val) }
  | SQL S SECURITY S INVOKER S
    { call(:r_opt_SQL_SECURITY, :INVOKER, val) }

  # =========================
  # ======= DROP VIEW =======
  # =========================

  r_DROP_VIEW :
    DROP S VIEW S r_opt_IF_EXISTS r_comma_separated_view_name
    r_opt_RESTRICT_or_CASCADE
    { call(:r_DROP_VIEW, nil, val) }

  r_opt_IF_EXISTS :
    { call(:r_opt_IF_EXISTS, :empty, val) }
  | IF S EXISTS S
    { call(:r_opt_IF_EXISTS, :body, val) }

  r_opt_RESTRICT_or_CASCADE :
    { call(:r_opt_RESTRICT_or_CASCADE, :empty, val) }
  | r_RESTRICT_or_CASCADE
    { call(:r_opt_RESTRICT_or_CASCADE, :body, val) }

  # ============================
  # ======= DROP TABLE =======
  # ============================

  r_DROP_TABLE :
    DROP S r_opt_TEMPORARY TABLE S r_opt_IF_EXISTS r_comma_separated_tbl_name
    r_opt_RESTRICT_or_CASCADE
    { call(:r_DROP_TABLE, nil, val) }

  # ========================
  # ======= TRUNCATE =======
  # ========================

  r_TRUNCATE_TABLE :
    TRUNCATE S r_opt_TABLE r_tbl_name
    { call(:r_TRUNCATE_TABLE, nil, val) }

  # ============================
  # ======= CREATE TABLE =======
  # ============================

  r_CREATE_TABLE :
    CREATE S r_opt_TEMPORARY TABLE S r_opt_IF_NOT_EXISTS
    r_tbl_name r_create_variation
    { call(:r_CREATE_TABLE, nil, val) }

  r_create_variation :
    r_create_definition_list r_opt_CREATE_TABLE_options r_opt_PARTITION_options
    { call(:r_create_variation, :with_list_without_select, val) }
  | r_create_definition_list r_opt_CREATE_TABLE_options r_opt_PARTITION_options
    r_select_statement
    { call(:r_create_variation, :with_list_with_select, val) }
  | r_opt_CREATE_TABLE_options r_opt_PARTITION_options r_select_statement
    { call(:r_create_variation, :without_list_with_select, val) }
  | left_paren LIKE S r_tbl_name right_paren
    { call(:r_create_variation, :LIKE_with_paren, val) }
  | LIKE S r_tbl_name
    { call(:r_create_variation, :LIKE_without_paren, val) }

  r_create_definition_list :
    left_paren r_comma_separated_create_definition right_paren
    { call(:r_create_definition_list, nil, val) }

  r_opt_TEMPORARY :
    { call(:r_opt_TEMPORARY, :empty, val) }
  | TEMPORARY S
    { call(:r_opt_TEMPORARY, :body, val) }

  r_opt_TABLE :
    { call(:r_opt_TABLE, :empty, val) }
  | TABLE S
    { call(:r_opt_TABLE, :body, val) }

  r_opt_IF_NOT_EXISTS :
    { call(:r_opt_IF_NOT_EXISTS, :empty, val) }
  | IF S NOT S EXISTS S
    { call(:r_opt_IF_NOT_EXISTS, :body, val) }

  r_create_definition :
    r_col_name_with_definition
    { call(:r_create_definition, :col, val) }
  | r_shared_create_alter
    { call(:r_create_definition, :shared_create_alter, val) }
  | CHECK S                    {
    raise 'check not supported' # incomplete grammar
  }

  r_col_name_with_definition :
    r_col_name r_column_definition
    { call(:r_col_name_with_definition, nil, val) }

  # =====================
  # ======= ALTER =======
  # =====================

  r_ALTER_TABLE :
    ALTER S r_ONLINE_OFFLINE r_opt_IGNORE TABLE S r_tbl_name
    r_opt_alter_commands r_opt_after_alter r_opt_PARTITION_options
    { call(:r_ALTER_TABLE, nil, val) }

  r_ONLINE_OFFLINE :
    { call(:r_ONLINE_OFFLINE, :empty, val) }
  | ONLINE S
    { call(:r_ONLINE_OFFLINE, :ONLINE, val) }
  | OFFLINE S
    { call(:r_ONLINE_OFFLINE, :OFFLINE, val) }

  r_opt_IGNORE :
    { call(:r_opt_IGNORE, :empty, val) }
  | IGNORE S
    { call(:r_opt_IGNORE, :body, val) }

  r_opt_alter_commands :
    { call(:r_opt_alter_commands, :empty, val) }
  | r_comma_separated_alter_specification
    { call(:r_opt_alter_commands, :list, val) }
  | r_single_alter_specification
    { call(:r_opt_alter_commands, :single, val) }

  r_ROW_FORMAT_option :
    DEFAULT S { call(:r_ROW_FORMAT_option, :DEFAULT, val) }
  | DYNAMIC S { call(:r_ROW_FORMAT_option, :DYNAMIC, val) }
  | COMPRESSED S { call(:r_ROW_FORMAT_option, :COMPRESSED, val) }
  | FIXED S { call(:r_ROW_FORMAT_option, :FIXED, val) }
  | REDUNDANT S { call(:r_ROW_FORMAT_option, :REDUNDANT, val) }
  | COMPACT S { call(:r_ROW_FORMAT_option, :COMPACT, val) }

  r_opt_CREATE_TABLE_options :
    { call(:r_opt_CREATE_TABLE_options, :empty, val) }
  | r_space_or_comma_separated_table_option
    { call(:r_opt_CREATE_TABLE_options, :body, val) }

  r_opt_PARTITION_options :
    { call(:r_opt_PARTITION_options, :empty, val) }
  | REMOVE S PARTITIONING S
    { call(:r_opt_PARTITION_options, :REMOVE, val) }
    # not on the list, but it fits
  | PARTITION S BY S # incomplete grammar
    { call(:r_opt_PARTITION_options, :PARTITION, val) }

  r_select_statement : # incomplete grammar
    r_opt_IGNORE_or_REPLACE r_opt_AS SELECT S star
    { call(:r_select_statement, nil, val) }

  r_shared_create_alter :
    r_opt_CONSTRAINT_with_val PRIMARY S KEY S r_alter_index_opt
    { call(:r_shared_create_alter, :PRIMARY, val) }
  | r_INDEX_or_KEY r_opt_index_name r_alter_index_opt
    { call(:r_shared_create_alter, :alter_index, val) }
  | r_opt_CONSTRAINT_with_val UNIQUE S r_opt_INDEX_or_KEY r_opt_index_name
    r_alter_index_opt
    { call(:r_shared_create_alter, :UNIQUE, val) }
  | FULLTEXT S r_opt_INDEX_or_KEY r_opt_index_name r_alter_index_opt
    { call(:r_shared_create_alter, :FULLTEXT, val) }
  | SPATIAL S r_opt_INDEX_or_KEY r_opt_index_name r_alter_index_opt
    { call(:r_shared_create_alter, :SPATIAL, val) }
  | r_opt_CONSTRAINT_with_val FOREIGN S KEY S r_opt_index_name r_alter_index_opt
    { call(:r_shared_create_alter, :FOREIGN_KEY, val) }

  r_alter_specification :
    r_space_separated_alter_table_option
    { call(:r_alter_specification, :table_options, val) }
  | ADD S r_opt_COLUMN r_col_name r_column_definition r_opt_pos_column
    { call(:r_alter_specification, :ADD_col, val) }
  | ADD S r_opt_COLUMN left_paren r_comma_separated_add_col right_paren
    { call(:r_alter_specification, :ADD_cols, val) }
  | ADD S r_shared_create_alter
    { call(:r_alter_specification, :ADD_shared, val) }
  | ALTER S r_opt_COLUMN r_col_name r_SET_or_DROP_DEFAULT
    { call(:r_alter_specification, :ALTER_col_SET_or_DROP_DEFAULT, val) }
  | CHANGE S r_opt_COLUMN r_col_name r_col_name r_column_definition
    r_opt_pos_column
    { call(:r_alter_specification, :CHANGE_col, val) }
  | DROP S r_opt_COLUMN r_col_name
    { call(:r_alter_specification, :DROP_col, val) }
  | DROP S FOREIGN S KEY S r_fk_symbol
    { call(:r_alter_specification, :DROP_FOREIGN_KEY, val) }
  | DISABLE S KEYS S
    { call(:r_alter_specification, :DISABLE_KEYS, val) }
  | ENABLE S KEYS S
    { call(:r_alter_specification, :ENABLE_KEYS, val) }
  | RENAME S r_opt_TO_or_AS r_tbl_name
    { call(:r_alter_specification, :RENAME, val) }
  | CONVERT S TO S L_CHARACTER_SET S r_charset_name opt_COLLATE_with_val
    { call(:r_alter_specification, :CONVERT, val) }
  | r_CHARACTER_SET_equal_with_val COLLATE S opt_equal r_collation_name
    { call(:r_alter_specification, :CHARACTER_SET_COLLATE, val) }
    # enforce to have collate -- the opt case is handle by table_option
  | DROP S r_INDEX_or_KEY r_index_name
    { call(:r_alter_specification, :DROP_index, val) }
  | MODIFY S r_opt_COLUMN r_col_name r_column_definition r_opt_pos_column
    { call(:r_alter_specification, :MODIFY_col, val) }
  | DROP S PRIMARY S KEY S
    { call(:r_alter_specification, :DROP_PRIMARY_KEY, val) }

  r_opt_after_alter :
    { call(:r_opt_after_alter, :empty, val) }
  | ORDER S BY S r_comma_separated_col_name
    { call(:r_opt_after_alter, :ORDER_BY, val) }

  r_DATA_DIRECTORY_equal_with_val :
    DATA S DIRECTORY S opt_equal string
    { call(:r_DATA_DIRECTORY_equal_with_val, nil, val) }

  r_INDEX_DIRECTORY_equal_with_val :
    INDEX S DIRECTORY S opt_equal string
    { call(:r_INDEX_DIRECTORY_equal_with_val, nil, val) }


  # ref: https://dev.mysql.com/doc/refman/5.1/en/create-table.html
  r_shared_table_option :
    AUTO_INCREMENT S opt_equal nat
    { call(:r_shared_table_option, :AUTO_INCREMENT, val) }
  | AVG_ROW_LENGTH S opt_equal nat
    { call(:r_shared_table_option, :AVG_ROW_LENGTH, val) }
  | r_CHARACTER_SET_equal_with_val
    { call(:r_shared_table_option, :CHARACTER_SET, val) }
  | CHECKSUM S opt_equal binary
    { call(:r_shared_table_option, :CHECKSUM, val) }
  | CONNECTION S opt_equal string
    { call(:r_shared_table_option, :CONNECTION, val) }
  | DELAY_KEY_WRITE S opt_equal binary
    { call(:r_shared_table_option, :DELAY_KEY_WRITE, val) }
  | INSERT_METHOD S opt_equal r_NO_or_FIRST_or_LAST
    { call(:r_shared_table_option, :INSERT_METHOD, val) }
  | PACK_KEYS S opt_equal r_binary_or_DEFAULT
    { call(:r_shared_table_option, :PACK_KEYS, val) }
  | PASSWORD S opt_equal string
    { call(:r_shared_table_option, :PASSWORD, val) }
  | ROW_FORMAT S opt_equal r_ROW_FORMAT_option
    { call(:r_shared_table_option, :ROW_FORMAT, val) }
  | TABLESPACE S r_tablespace_name r_opt_STORAGE_option
    { call(:r_shared_table_option, :TABLESPACE, val) }
  | UNION S opt_equal left_paren opt_equal
    r_comma_separated_tbl_name right_paren
    { call(:r_shared_table_option, :UNION, val) }
  | KEY_BLOCK_SIZE S opt_equal nat
    { call(:r_shared_table_option, :KEY_BLOCK_SIZE, val) }
  | r_COMMENT_equal_with_val
    { call(:r_shared_table_option, :COMMENT, val) }
  | r_DATA_DIRECTORY_equal_with_val
    { call(:r_shared_table_option, :DATA_DIRECTORY, val) }
  | r_INDEX_DIRECTORY_equal_with_val
    { call(:r_shared_table_option, :INDEX_DIRECTORY, val) }
  | r_MAX_ROWS_equal_with_val
    { call(:r_shared_table_option, :MAX_ROWS, val) }
  | r_MIN_ROWS_equal_with_val
    { call(:r_shared_table_option, :MIN_ROWS, val) }
  | r_ENGINE_equal_with_val
    { call(:r_shared_table_option, :ENGINE, val) }

  r_CREATE_TABLE_option :
    r_shared_table_option
    { call(:r_CREATE_TABLE_option, :shared, val) }
  | r_opt_DEFAULT COLLATE S opt_equal r_collation_name
    { call(:r_CREATE_TABLE_option, :COLLATE, val) }
  # include COLLATE command specifically because alter's COLLATE and
  # create's COLLATE are different.

  r_alter_table_option :
    r_shared_table_option
    { call(:r_alter_table_option, nil, val) }
  # exclude COLLATE command specifically. It is in r_alter_specification already

  r_opt_NODEGROUP_equal_with_val :
    { call(:r_opt_NODEGROUP_equal_with_val, :empty, val) }
  | NODEGROUP S
    { call(:r_opt_NODEGROUP_equal_with_val, :body, val) }

  r_single_alter_specification :
    DISCARD S TABLESPACE S
    { call(:r_single_alter_specification, :DISCARD_TABLESPACE, val) }
  | IMPORT S TABLESPACE S
    { call(:r_single_alter_specification, :IMPORT_TABLESPACE, val) }
  | ADD S PARTITION S left_paren r_partition_definition right_paren
    { call(:r_single_alter_specification, :ADD_PARTITION, val) }
  | DROP S PARTITION S r_comma_separated_partition_name
    { call(:r_single_alter_specification, :DROP_PARTITION, val) }
  | REBUILD S PARTITION S r_partition_name_list_or_ALL
    { call(:r_single_alter_specification, :REBUILD_PARTITION, val) }
  | OPTIMIZE S PARTITION S r_partition_name_list_or_ALL
    { call(:r_single_alter_specification, :OPTIMIZE_PARTITION, val) }
  | ANALYZE S PARTITION S r_partition_name_list_or_ALL
    { call(:r_single_alter_specification, :ANALYZE_PARTITION, val) }
  | CHECK S PARTITION S r_partition_name_list_or_ALL
    { call(:r_single_alter_specification, :CHECK_PARTITION, val) }
  | REPAIR S PARTITION S r_partition_name_list_or_ALL
    { call(:r_single_alter_specification, :REPAIR_PARTITION, val) }
  | COALESCE S PARTITION S nat
    { call(:r_single_alter_specification, :COALESCE_PARTITION, val) }
  | TRUNCATE S PARTITION S r_partition_name_list_or_ALL
    { call(:r_single_alter_specification, :TRUNCATE_PARTITION, val) }
  | REORGANIZE S PARTITION S r_opt_partition_names_INTO_definitions
    { call(:r_single_alter_specification, :REORGANIZE_PARTITION, val) }

  r_opt_CONSTRAINT_with_val :
    { call(:r_opt_CONSTRAINT_with_val, :empty, val) }
  | CONSTRAINT S
    { call(:r_opt_CONSTRAINT_with_val, :CONTRAINT_without_symbol, val) }
  | CONSTRAINT S symbol
    { call(:r_opt_CONSTRAINT_with_val, :CONTRAINT_with_symbol, val) }

  r_CHARACTER_SET_equal_with_val :
    r_opt_DEFAULT L_CHARACTER_SET S opt_equal r_charset_name
    { call(:r_CHARACTER_SET_equal_with_val, nil, val) }

  r_alter_index_opt :
    r_opt_index_type left_paren r_comma_separated_index_col_name right_paren
    r_opt_space_separated_index_option
    { call(:r_alter_index_opt, nil, val) }

  r_opt_INDEX_or_KEY :
    { call(:r_opt_INDEX_or_KEY, :empty, val) }
  | r_INDEX_or_KEY
    { call(:r_opt_INDEX_or_KEY, :body, val) }

  r_INDEX_or_KEY :
    INDEX S
    { call(:r_INDEX_or_KEY, :INDEX, val) }
  | KEY S
    { call(:r_INDEX_or_KEY, :KEY, val) }

  r_opt_index_name :
    { call(:r_opt_index_name, :empty, val) }
  | r_index_name
    { call(:r_opt_index_name, :body, val) }

  r_opt_index_type :
    { call(:r_opt_index_type, :empty, val) }
  | r_index_type
    { call(:r_opt_index_type, :body, val) }

  r_index_type :
    USING S BTREE S
    { call(:r_index_type, :BTREE, val) }
  | USING S HASH S
    { call(:r_index_type, :HASH, val) }

  r_index_option :
    r_index_type
    { call(:r_index_option, :index_type, val) }
  | KEY_BLOCK_SIZE S opt_equal nat
    { call(:r_index_option, :KEY_BLOCK_SIZE, val) }
  | WITH S PARSER S r_parser_name
    { call(:r_index_option, :WITH_PARSER, val) }

  r_SET_or_DROP_DEFAULT :
    SET S DEFAULT S literal
    { call(:r_SET_or_DROP_DEFAULT, :SET, val) }
  | DROP S DEFAULT S
    { call(:r_SET_or_DROP_DEFAULT, :DROP, val) }

  r_opt_COLUMN :
    { call(:r_opt_COLUMN, :empty, val) }
  | COLUMN S
    { call(:r_opt_COLUMN, :body, val) }

  r_column_definition :
    r_datatype r_opt_NULL_status r_opt_DEFAULT_with_val r_opt_AUTO_INCREMENT
    r_opt_UNIQUE_or_PRIMARY r_opt_COMMENT_with_val r_opt_COLUMN_FORMAT
    r_opt_STORAGE r_opt_COLUMN_ON_UPDATE
    { call(:r_column_definition, nil, val) }

  # ========================
  # ======= DATATYPE =======
  # ========================

  r_opt_datatype_number :
    { call(:r_opt_datatype_number, :empty, val) }
  | r_length_int
    { call(:r_opt_datatype_number, :int, val) }
  | r_length_real
    { call(:r_opt_datatype_number, :real, val) }

  r_opt_datatype_int :
    r_opt_length_int r_opt_UNSIGNED r_opt_ZEROFILL
    { call(:r_opt_datatype_int, nil, val) }

  r_opt_datatype_real :
    r_opt_length_real r_opt_UNSIGNED r_opt_ZEROFILL
    { call(:r_opt_datatype_real, nil, val) }

  r_opt_datatype_char :
    r_opt_BINARY r_opt_CHARACTER_SET_with_val opt_COLLATE_with_val
    { call(:r_opt_datatype_char, nil, val) }

  r_opt_length_int :
    { call(:r_opt_length_int, :empty, val) }
  | r_length_int
    { call(:r_opt_length_int, :body, val) }

  r_opt_length_real :
    { call(:r_opt_length_real, :empty, val) }
  | r_length_real
    { call(:r_opt_length_real, :body, val) }

  r_length_int :
    left_paren nat right_paren
    { call(:r_length_int, nil, val) }

  r_length_real :
    left_paren nat comma nat right_paren
    { call(:r_length_real, nil, val) }

  r_opt_UNSIGNED :
    { call(:r_opt_UNSIGNED, :empty, val) }
  | UNSIGNED S
    { call(:r_opt_UNSIGNED, :body, val) }

  r_opt_ZEROFILL :
    { call(:r_opt_ZEROFILL, :empty, val) }
  | ZEROFILL S
    { call(:r_opt_ZEROFILL, :body, val) }

  r_opt_BINARY :
    { call(:r_opt_BINARY, :empty, val) }
  | BINARY S
    { call(:r_opt_BINARY, :body, val) }

  r_opt_NULL_status :
    { call(:r_opt_NULL_status, :empty, val) }
  | NOT S null
    { call(:r_opt_NULL_status, :NOT_NULL, val) }
  | null
    { call(:r_opt_NULL_status, :NULL, val) }

  r_opt_DEFAULT_with_val :
    { call(:r_opt_DEFAULT_with_val, :empty, val) }
  | DEFAULT S value
    { call(:r_opt_DEFAULT_with_val, :body, val) }

  r_opt_AUTO_INCREMENT :
    { call(:r_opt_AUTO_INCREMENT, :empty, val) }
  | AUTO_INCREMENT S
    { call(:r_opt_AUTO_INCREMENT, :body, val) }

  r_opt_UNIQUE_or_PRIMARY :
    { call(:r_opt_UNIQUE_or_PRIMARY, :empty, val) }
  | UNIQUE S
    { call(:r_opt_UNIQUE_or_PRIMARY, :UNIQUE, val) }
  | UNIQUE S KEY S
    { call(:r_opt_UNIQUE_or_PRIMARY, :UNIQUE_KEY, val) }
  | PRIMARY S
    { call(:r_opt_UNIQUE_or_PRIMARY, :PRIMARY, val) }
  | PRIMARY S KEY S
    { call(:r_opt_UNIQUE_or_PRIMARY, :PRIMARY_KEY, val) }

  r_opt_COMMENT_with_val :
    { call(:r_opt_COMMENT_with_val, :empty, val) }
  | COMMENT S string
    { call(:r_opt_COMMENT_with_val, :body, val) }

  r_opt_COLUMN_FORMAT :
    { call(:r_opt_COLUMN_FORMAT, :empty, val) }
  | COLUMN_FORMAT S FIXED S
    { call(:r_opt_COLUMN_FORMAT, :FIXED, val) }
  | COLUMN_FORMAT S DYNAMIC S
    { call(:r_opt_COLUMN_FORMAT, :DYNAMIC, val) }
  | COLUMN_FORMAT S DEFAULT S
    { call(:r_opt_COLUMN_FORMAT, :DEFAULT, val) }

  r_opt_STORAGE :
    { call(:r_opt_STORAGE, :empty, val) }
  | STORAGE S DISK S
    { call(:r_opt_STORAGE, :DISK, val) }
  | STORAGE S MEMORY S
    { call(:r_opt_STORAGE, :MEMORY, val) }
  | STORAGE S DEFAULT S
    { call(:r_opt_STORAGE, :DEFAULT, val) }

  r_opt_REFERENCES_definition :
    { call(:r_opt_REFERENCES_definition, :empty, val) }
  | REFERENCES S r_tbl_name left_paren r_comma_separated_index_col_name
    right_paren r_opt_MATCH r_opt_ON_DELETE_and_UPDATE
    { call(:r_opt_REFERENCES_definition, :body, val) }

  r_opt_MATCH :
    { call(:r_opt_MATCH, :empty, val) }
  | MATCH S FULL S
    { call(:r_opt_MATCH, :FULL, val) }
  | MATCH S PARTIAL S
    { call(:r_opt_MATCH, :PARTIAL, val) }
  | MATCH S SIMPLE S
    { call(:r_opt_MATCH, :SIMPLE, val) }

  r_opt_ASC_or_DESC :
    { call(:r_opt_ASC_or_DESC, :empty, val) }
  | ASC S
    { call(:r_opt_ASC_or_DESC, :ASC, val) }
  | DESC S
    { call(:r_opt_ASC_or_DESC, :DESC, val) }

  r_opt_ON_DELETE_and_UPDATE :
    { call(:r_opt_ON_DELETE_and_UPDATE, :empty, val) }
  | ON S DELETE S r_reference_option
    { call(:r_opt_ON_DELETE_and_UPDATE, :DELETE, val) }
  | ON S DELETE S r_reference_option
    ON S UPDATE S r_reference_option
    { call(:r_opt_ON_DELETE_and_UPDATE, :DELETE_UPDATE, val) }
  | ON S UPDATE S r_reference_option
    { call(:r_opt_ON_DELETE_and_UPDATE, :UPDATE, val) }

  r_opt_COLUMN_ON_UPDATE :
    { call(:r_opt_COLUMN_ON_UPDATE, :empty, val) }
  | ON S UPDATE S literal
    { call(:r_opt_COLUMN_ON_UPDATE, :UPDATE, val) }

  r_RESTRICT_or_CASCADE :
    RESTRICT S
    { call(:r_RESTRICT_or_CASCADE, :RESTRICT, val) }
  | CASCADE S
    { call(:r_RESTRICT_or_CASCADE, :CASCADE, val) }

  r_reference_option :
    r_RESTRICT_or_CASCADE
    { call(:r_reference_option, :RESTRICT_or_CASCADE, val) }
  | SET S null
    { call(:r_reference_option, :SET, val) }
  | NO S ACTION S
    { call(:r_reference_option, :NO_ACTION, val) }

  r_opt_TO_or_AS :
    { call(:r_opt_TO_or_AS, :empty, val) }
  | AS S
    { call(:r_opt_TO_or_AS, :AS, val) }
  | TO S
    { call(:r_opt_TO_or_AS, :TO, val) }

  r_opt_AS :
    { call(:r_opt_AS, :empty, val) }
  | AS S
    { call(:r_opt_AS, :AS, val) }

  r_opt_CHARACTER_SET_with_val :
    { call(:r_opt_CHARACTER_SET_with_val, :empty, val) }
  | L_CHARACTER_SET S r_charset_name
    { call(:r_opt_CHARACTER_SET_with_val, :body, val) }

  opt_COLLATE_with_val :
    { call(:opt_COLLATE_with_val, :empty, val) }
  | COLLATE S r_collation_name
    { call(:opt_COLLATE_with_val, :body, val) }

  r_opt_pos_column :
    { call(:r_opt_pos_column, :empty, val) }
  | FIRST S
    { call(:r_opt_pos_column, :FIRST, val) }
  | AFTER S r_col_name
    { call(:r_opt_pos_column, :AFTER, val) }

  r_binary_or_DEFAULT :
    DEFAULT S
    { call(:r_binary_or_DEFAULT, :DEFAULT, val) }
  | binary
    { call(:r_binary_or_DEFAULT, :binary, val) }

  r_NO_or_FIRST_or_LAST :
    NO S
    { call(:r_NO_or_FIRST_or_LAST, :NO, val) }
  | FIRST S
    { call(:r_NO_or_FIRST_or_LAST, :FIRST, val) }
  | LAST S
    { call(:r_NO_or_FIRST_or_LAST, :LAST, val) }

  r_opt_STORAGE_option :
    { call(:r_opt_STORAGE_option, :empty, val) }
  | STORAGE S DISK S
    { call(:r_opt_STORAGE_option, :DISK, val) }
  | STORAGE S MEMORY S
    { call(:r_opt_STORAGE_option, :MEMORY, val) }
  | STORAGE S DEFAULT S
    { call(:r_opt_STORAGE_option, :DEFAULT, val) }

  r_opt_DEFAULT :
    { call(:r_opt_DEFAULT, :empty, val) }
  | DEFAULT S
    { call(:r_opt_DEFAULT, :body, val) }

  r_opt_COMMENT_equal_with_val :
    { call(:r_opt_COMMENT_equal_with_val, :empty, val) }
  | r_COMMENT_equal_with_val
    { call(:r_opt_COMMENT_equal_with_val, :body, val) }

  r_COMMENT_equal_with_val :
    COMMENT S opt_equal string
    { call(:r_COMMENT_equal_with_val, nil, val) }

  r_MAX_ROWS_equal_with_val :
    MAX_ROWS S opt_equal nat
    { call(:r_MAX_ROWS_equal_with_val, nil, val) }

  r_MIN_ROWS_equal_with_val :
    MIN_ROWS S opt_equal nat
    { call(:r_MIN_ROWS_equal_with_val, nil, val) }

  r_partition_definition :
    PARTITION S r_partition_name r_opt_partition_values
    r_partition_subpartition_share r_opt_subpartition_definition_list
    { call(:r_partition_definition, nil, val) }

  r_opt_partition_values :
    { call(:r_opt_partition_values, :empty, val) }
  | VALUES S LESS S THAN S MAXVALUE S
    { call(:r_opt_partition_values, :LESS_THAN_MAXVALUE, val) }
  | VALUES S LESS S THAN S left_paren expr right_paren
    { call(:r_opt_partition_values, :LESS_THAN_values, val) }
  | VALUES S IN S left_paren r_comma_separated_integer right_paren
    { call(:r_opt_partition_values, :IN_values, val) }

  r_ENGINE_equal_with_val :
    ENGINE S opt_equal r_ENGINE_name
    { call(:r_ENGINE_equal_with_val, nil, val) }

  r_opt_STORAGE_ENGINE_equal_with_val :
    { call(:r_opt_STORAGE_ENGINE_equal_with_val, :empty, val) }
  | STORAGE S ENGINE S opt_equal r_ENGINE_name
    { call(:r_opt_STORAGE_ENGINE_equal_with_val, :STORAGE_ENGINE, val) }
  | r_ENGINE_equal_with_val
    { call(:r_opt_STORAGE_ENGINE_equal_with_val, :ENGINE, val) }

  r_opt_DATA_DIRECTORY_equal_with_val :
    { call(:r_opt_DATA_DIRECTORY_equal_with_val, :empty, val) }
  | r_DATA_DIRECTORY_equal_with_val
    { call(:r_opt_DATA_DIRECTORY_equal_with_val, :body, val) }

  r_opt_INDEX_DIRECTORY_equal_with_val :
    { call(:r_opt_INDEX_DIRECTORY_equal_with_val, :empty, val) }
  | r_INDEX_DIRECTORY_equal_with_val
    { call(:r_opt_INDEX_DIRECTORY_equal_with_val, :body, val) }

  r_opt_MAX_ROWS_equal_with_val :
    { call(:r_opt_MAX_ROWS_equal_with_val, :empty, val) }
  | r_MAX_ROWS_equal_with_val
    { call(:r_opt_MAX_ROWS_equal_with_val, :body, val) }

  r_opt_MIN_ROWS_equal_with_val :
    { call(:r_opt_MIN_ROWS_equal_with_val, :empty, val) }
  | r_MIN_ROWS_equal_with_val
    { call(:r_opt_MIN_ROWS_equal_with_val, :body, val) }

  r_opt_TABLESPACE_equal_with_val :
    { call(:r_opt_TABLESPACE_equal_with_val, :empty, val) }
  | TABLESPACE S opt_equal r_tablespace_name
    { call(:r_opt_TABLESPACE_equal_with_val, :body, val) }

  r_subpartition_definition :
    SUBPARTITION S r_logical_name r_partition_subpartition_share
    { call(:r_subpartition_definition, nil, val) }

  r_partition_subpartition_share :
    r_opt_STORAGE_ENGINE_equal_with_val r_opt_COMMENT_equal_with_val
    r_opt_DATA_DIRECTORY_equal_with_val r_opt_INDEX_DIRECTORY_equal_with_val
    r_opt_MAX_ROWS_equal_with_val r_opt_MIN_ROWS_equal_with_val
    r_opt_TABLESPACE_equal_with_val r_opt_NODEGROUP_equal_with_val
    { call(:r_partition_subpartition_share, nil, val) }

  r_opt_subpartition_definition_list :
    { call(:r_opt_subpartition_definition_list, :empty, val) }
  | left_paren r_comma_separated_subpartition_definition right_paren
    { call(:r_opt_subpartition_definition_list, :body, val) }

  r_opt_partition_names_INTO_definitions :
    { call(:r_opt_partition_names_INTO_definitions, :empty, val) }
  | r_comma_separated_partition_name INTO S left_paren
    r_comma_separated_partition_definition right_paren
    { call(:r_opt_partition_names_INTO_definitions, :body, val) }

  r_partition_name_list_or_ALL :
    ALL S
    { call(:r_partition_name_list_or_ALL, :ALL, val) }
  | r_comma_separated_partition_name
    { call(:r_partition_name_list_or_ALL, :list, val) }

  r_opt_IGNORE_or_REPLACE :
    { call(:r_opt_IGNORE_or_REPLACE, :empty, val) }
  | IGNORE
    { call(:r_opt_IGNORE_or_REPLACE, :IGNORE, val) }
  | REPLACE S
    { call(:r_opt_IGNORE_or_REPLACE, :REPLACE, val) }

  # ============================================
  # ======= COMMA/SPACE-SEPARATED-THINGS =======
  # ============================================

  r_comma_separated_col_name :
    r_col_name
    { call(:r_comma_separated_col_name, :base, val) }
  | r_comma_separated_col_name comma r_col_name
    { call(:r_comma_separated_col_name, :inc, val) }

  r_comma_separated_tbl_name :
    r_tbl_name
    { call(:r_comma_separated_tbl_name, :base, val) }
  | r_comma_separated_tbl_name comma r_tbl_name
    { call(:r_comma_separated_tbl_name, :inc, val) }

  r_comma_separated_index_col_name :
    r_index_col_name
    { call(:r_comma_separated_index_col_name, :base, val) }
  | r_comma_separated_index_col_name comma r_index_col_name
    { call(:r_comma_separated_index_col_name, :inc, val) }

  r_comma_separated_add_col :
    r_col_name_with_definition
    { call(:r_comma_separated_add_col, :base, val) }
  | r_comma_separated_add_col comma r_col_name_with_definition
    { call(:r_comma_separated_add_col, :inc, val) }

  r_comma_separated_alter_specification :
    r_alter_specification
    { call(:r_comma_separated_alter_specification, :base, val) }
  | r_comma_separated_alter_specification comma r_alter_specification
    { call(:r_comma_separated_alter_specification, :inc, val) }

  r_comma_separated_partition_name :
    r_partition_name
    { call(:r_comma_separated_partition_name, :base, val) }
  | r_comma_separated_partition_name comma r_partition_name
    { call(:r_comma_separated_partition_name, :inc, val) }

  r_comma_separated_subpartition_definition :
    r_subpartition_definition
    { call(:r_comma_separated_subpartition_definition, :base, val) }
  | r_comma_separated_subpartition_definition comma r_subpartition_definition
    { call(:r_comma_separated_subpartition_definition, :inc, val) }

  r_comma_separated_partition_definition :
    r_partition_definition
    { call(:r_comma_separated_partition_definition, :base, val) }
  | r_comma_separated_partition_definition comma r_partition_definition
    { call(:r_comma_separated_partition_definition, :inc, val) }

  r_space_separated_alter_table_option :
    r_alter_table_option
    { call(:r_space_separated_alter_table_option, :base, val) }
  | r_space_separated_alter_table_option r_alter_table_option
    { call(:r_space_separated_alter_table_option, :inc, val) }
  # not comma separated, the comma separated one is done by the top level

  r_comma_separated_view_name :
    r_view_name
    { call(:r_comma_separated_view_name, :base, val) }
  | r_comma_separated_view_name comma r_view_name
    { call(:r_comma_separated_view_name, :inc, val) }

  r_opt_space_separated_index_option :
    { call(:r_opt_space_separated_index_option, :base, val) }
  | r_opt_space_separated_index_option r_index_option
    { call(:r_opt_space_separated_index_option, :inc, val) }

  r_comma_separated_integer :
    integer
    { call(:r_comma_separated_integer, :base, val) }
  | r_comma_separated_integer comma integer
    { call(:r_comma_separated_integer, :inc, val) }

  r_comma_separated_create_definition :
    r_create_definition
    { call(:r_comma_separated_create_definition, :base, val) }
  | r_comma_separated_create_definition comma r_create_definition
    { call(:r_comma_separated_create_definition, :inc, val) }

  r_space_or_comma_separated_table_option :
    r_CREATE_TABLE_option
    { call(:r_space_or_comma_separated_table_option, :base, val) }
  | r_space_or_comma_separated_table_option
    opt_comma r_CREATE_TABLE_option
    { call(:r_space_or_comma_separated_table_option, :inc, val) }

  r_comma_separated_string :
    string
    { call(:r_comma_separated_string, :base, val) }
  | r_comma_separated_string comma string
    { call(:r_comma_separated_string, :inc, val) }

  # ==================================
  # ======= ALL THE NAME THING =======
  # ==================================

  r_index_col_name :
    r_col_name r_opt_length_int r_opt_ASC_or_DESC
    { call(:r_index_col_name, nil, val) }

  r_view_name : r_tbl_name_int { call(:r_view_name, nil, val) }
  r_partition_name : ident { call(:r_partition_name, nil, val) }
  r_logical_name : ident { call(:r_logical_name, nil, val) }
  r_parser_name : ident { call(:r_parser_name, nil, val) }
  r_index_name : ident { call(:r_index_name, nil, val) }
  r_tablespace_name : ident { call(:r_tablespace_name, nil, val) }
  r_collation_name : raw_ident  { call(:r_collation_name, nil, val) }
  r_col_name : ident { call(:r_col_name, nil, val) }
  r_tbl_name : r_tbl_name_int { call(:r_tbl_name, nil, val) }

  r_tbl_name_int :
    ident
    { call(:r_tbl_name_int, :without_dot, val) }
  | S_IDENT_NORMAL S_DOT ident
    { call(:r_tbl_name_int, :with_database, val) }
  | S_DOT ident
    { call(:r_tbl_name_int, :with_dot, val) }

  r_user_name :
    r_user_name_part
    { call(:r_user_name, :without_at, val) }
  | r_user_name_part S_AT r_user_name_part # no S after S_AT
    { call(:r_user_name, :with_at, val) }

  r_user_name_part :
    string { call(:r_user_name_part, :string, val) }
  | ident  { call(:r_user_name_part, :ident, val) } # could have backtick

  r_fk_symbol : ident { call(:r_fk_symbol, nil, val) }

  r_ENGINE_name :
    INNODB S  { call(:r_ENGINE_name, :INNODB, val) }
  | raw_ident { call(:r_ENGINE_name, :other, val) } # TODO

  r_charset_name :
    LATIN1 S  { call(:r_charset_name, :LATIN1, val) }
  | UTF8 S    { call(:r_charset_name, :UTF8, val) }
  | UTF8MB4 S { call(:r_charset_name, :UTF8MB4, val) }
  | UTF8MB3 S { call(:r_charset_name, :UTF8MB3, val) }
  | raw_ident { call(:r_charset_name, :other, val) }

  # ref: https://dev.mysql.com/doc/refman/5.1/en/create-table.html
  r_datatype :
    BIT S r_opt_length_int
    { call(:r_datatype, :BIT, val) }
  | TINYINT S r_opt_datatype_int
    { call(:r_datatype, :TINYINT, val) }
  | SMALLINT S r_opt_datatype_int
    { call(:r_datatype, :SMALLINT, val) }
  | MEDIUMINT S r_opt_datatype_int
    { call(:r_datatype, :MEDIUMINT, val) }
  | INT S r_opt_datatype_int
    { call(:r_datatype, :INT, val) }
  | INTEGER S r_opt_datatype_int
    { call(:r_datatype, :INTEGER, val) }
  | BIGINT S r_opt_datatype_int
    { call(:r_datatype, :BIGINT, val) }
  | REAL S r_opt_datatype_real
    { call(:r_datatype, :REAL, val) }
  | DOUBLE S r_opt_datatype_real
    { call(:r_datatype, :DOUBLE, val) }
  | FLOAT S r_opt_datatype_real
    { call(:r_datatype, :FLOAT, val) }
  | DECIMAL S r_opt_datatype_number
    { call(:r_datatype, :DECIMAL, val) }
  | NUMERIC S r_opt_datatype_number
    { call(:r_datatype, :NUMERIC, val) }
  | DATE S r_opt_datatype_int
    { call(:r_datatype, :DATE, val) }
  | TIME S r_opt_datatype_int
    { call(:r_datatype, :TIME, val) }
  | TIMESTAMP S r_opt_datatype_int
    { call(:r_datatype, :TIMESTAMP, val) }
  | DATETIME S r_opt_datatype_int
    { call(:r_datatype, :DATETIME, val) }
  | YEAR S
    { call(:r_datatype, :YEAR, val) }
  | CHAR S r_opt_length_int r_opt_datatype_char
    { call(:r_datatype, :CHAR, val) }
  | VARCHAR S r_opt_length_int r_opt_datatype_char
    { call(:r_datatype, :VARCHAR, val) }
  | BINARY S r_opt_length_int
    { call(:r_datatype, :BINARY, val) }
  | VARBINARY S r_length_int
    { call(:r_datatype, :VARBINARY, val) }
  | TINYBLOB S
    { call(:r_datatype, :TINYBLOB, val) }
  | BLOB S
    { call(:r_datatype, :BLOB, val) }
  | MEDIUMBLOB S
    { call(:r_datatype, :MEDIUMBLOB, val) }
  | LONGBLOB S
    { call(:r_datatype, :LONGBLOB, val) }
  | TINYTEXT S r_opt_datatype_char
    { call(:r_datatype, :TINYTEXT, val) }
  | TEXT S r_opt_datatype_char
    { call(:r_datatype, :TEXT, val) }
  | MEDIUMTEXT S r_opt_datatype_char
    { call(:r_datatype, :MEDIUMTEXT, val) }
  | LONGTEXT S r_opt_datatype_char
    { call(:r_datatype, :LONGTEXT, val) }
  | SET S left_paren r_comma_separated_string right_paren
    r_opt_CHARACTER_SET_with_val opt_COLLATE_with_val
    { call(:r_datatype, :SET, val) }
  | ENUM S left_paren r_comma_separated_string right_paren
    r_opt_CHARACTER_SET_with_val opt_COLLATE_with_val
    { call(:r_datatype, :ENUM, val) }
  | raw_ident # spatial type, incomplete grammar
    { call(:r_datatype, :spatial, val) }

  # ====================
  # ======= CORE =======
  # ====================

  expr : number { call(:expr, nil, val) }

  opt_comma :
    { call(:opt_comma, :empty, val) }
  | comma
    { call(:opt_comma, :body, val) }

  comma : S_COMMA S { call(:comma, nil, val) }

  opt_equal :
    { call(:opt_equal, :empty, val) }
  | equal
    { call(:opt_equal, :body, val) }

  equal : S_EQUAL S { call(:equal, nil, val) }

  left_paren : S_LEFT_PAREN S   { call(:left_paren, nil, val) }
  right_paren : S_RIGHT_PAREN S { call(:right_paren, nil, val) }

  symbol : ident { call(:symbol, nil, val) }

  literal : value { call(:literal, nil, val) }

  value :
    null                { call(:value, :literal, val) }
  | number              { call(:value, :number, val) }
  | string              { call(:value, :string, val) }
  | CURRENT_TIMESTAMP S { call(:value, :CURRENT_TIMESTAMP, val) }

  # # no rule uses it
  # string_expr :
  #   string
  #   { call(:string_expr, :base, val) }
  # | string_expr string
  #   { call(:string_expr, :inc, val) }

  string :
    S_SINGLEQUOTE_IN opt_string_in_quote S_SINGLEQUOTE_OUT S
    { call(:string, :single, val) }
  | S_DOUBLEQUOTE_IN opt_string_in_quote S_DOUBLEQUOTE_OUT S
    { call(:string, :double, val) }

  opt_string_in_quote :
    { call(:opt_string_in_quote, :empty, val) }
  | opt_string_in_quote S_STRING_IN_QUOTE
    { call(:opt_string_in_quote, :inc, val) }

  number :
    integer { call(:number, :integer, val) }
  | float   { call(:number, :float, val) }

  float : S_FLOAT S { call(:float, nil, val) }

  binary :
    S_ZERO S { call(:binary, :zero, val) }
  | S_ONE S  { call(:binary, :one, val) }

  integer :
    nat              { call(:integer, :nat, val) }
  | negative_integer { call(:integer, :neg, val) }

  negative_integer :
    S_MINUS S_ONE S { call(:negative_integer, :one, val) } # TODO: space between?
  | S_MINUS S_NAT S { call(:negative_integer, :rest, val) }

  nat :
    S_NAT S { call(:nat, :not_binary, val) }
    # not 0, 1, cause it was matched already
  | binary  { call(:nat, :binary, val) }

  null : NULL S { call(:null, nil, val) }

  ident :
    raw_ident
    { call(:ident, :without_backtick, val) }
  | S_BACKTICK_IN opt_ident_in_backtick S_BACKTICK_OUT S
    { call(:ident, :with_backtick, val) }

  opt_ident_in_backtick :
    { call(:opt_ident_in_backtick, :empty, val) }
  | opt_ident_in_backtick S_IDENT_IN_BACKTICK
    { call(:opt_ident_in_backtick, :inc, val) }

  raw_ident : S_IDENT_NORMAL S { call(:raw_ident, nil, val) }

  S : S_SPACE { call(:S, nil, val) }

  # (star includes S already)
  star : dot { call(:star, :base, val) }
  | star dot { call(:star, :inc, val) }

  # dot must be the last rule, as sanity check assumes
  # that it is the last rule

  # DO NOT EDIT THIS BELOW SECTION
  # BEGIN LITERAL (AUTO-GENERATED)
  dot :
    ZEROFILL { call(:dot, :ZEROFILL, val) }
  | YEAR { call(:dot, :YEAR, val) }
  | WITH { call(:dot, :WITH, val) }
  | VIEW { call(:dot, :VIEW, val) }
  | VARCHAR { call(:dot, :VARCHAR, val) }
  | VARBINARY { call(:dot, :VARBINARY, val) }
  | VALUES { call(:dot, :VALUES, val) }
  | UTF8MB4 { call(:dot, :UTF8MB4, val) }
  | UTF8MB3 { call(:dot, :UTF8MB3, val) }
  | UTF8 { call(:dot, :UTF8, val) }
  | USING { call(:dot, :USING, val) }
  | UPDATE { call(:dot, :UPDATE, val) }
  | UNSIGNED { call(:dot, :UNSIGNED, val) }
  | UNIQUE { call(:dot, :UNIQUE, val) }
  | UNION { call(:dot, :UNION, val) }
  | UNDEFINED { call(:dot, :UNDEFINED, val) }
  | TRUNCATE { call(:dot, :TRUNCATE, val) }
  | TO { call(:dot, :TO, val) }
  | TINYTEXT { call(:dot, :TINYTEXT, val) }
  | TINYINT { call(:dot, :TINYINT, val) }
  | TINYBLOB { call(:dot, :TINYBLOB, val) }
  | TIMESTAMP { call(:dot, :TIMESTAMP, val) }
  | TIME { call(:dot, :TIME, val) }
  | THAN { call(:dot, :THAN, val) }
  | TEXT { call(:dot, :TEXT, val) }
  | TEMPTABLE { call(:dot, :TEMPTABLE, val) }
  | TEMPORARY { call(:dot, :TEMPORARY, val) }
  | TABLESPACE { call(:dot, :TABLESPACE, val) }
  | TABLE { call(:dot, :TABLE, val) }
  | S_ZERO { call(:dot, :S_ZERO, val) }
  | S_STRING_IN_SINGLEQUOTE { call(:dot, :S_STRING_IN_SINGLEQUOTE, val) }
  | S_STRING_IN_QUOTE { call(:dot, :S_STRING_IN_QUOTE, val) }
  | S_SPACE { call(:dot, :S_SPACE, val) }
  | S_SINGLEQUOTE_OUT { call(:dot, :S_SINGLEQUOTE_OUT, val) }
  | S_SINGLEQUOTE_IN { call(:dot, :S_SINGLEQUOTE_IN, val) }
  | S_RIGHT_PAREN { call(:dot, :S_RIGHT_PAREN, val) }
  | S_ONE { call(:dot, :S_ONE, val) }
  | S_NAT { call(:dot, :S_NAT, val) }
  | S_MINUS { call(:dot, :S_MINUS, val) }
  | S_LEFT_PAREN { call(:dot, :S_LEFT_PAREN, val) }
  | S_IDENT_NORMAL { call(:dot, :S_IDENT_NORMAL, val) }
  | S_IDENT_IN_BACKTICK { call(:dot, :S_IDENT_IN_BACKTICK, val) }
  | S_FLOAT { call(:dot, :S_FLOAT, val) }
  | S_EQUAL { call(:dot, :S_EQUAL, val) }
  | S_DOUBLEQUOTE_OUT { call(:dot, :S_DOUBLEQUOTE_OUT, val) }
  | S_DOUBLEQUOTE_IN { call(:dot, :S_DOUBLEQUOTE_IN, val) }
  | S_DOT { call(:dot, :S_DOT, val) }
  | S_COMMA { call(:dot, :S_COMMA, val) }
  | S_BACKTICK_OUT { call(:dot, :S_BACKTICK_OUT, val) }
  | S_BACKTICK_IN { call(:dot, :S_BACKTICK_IN, val) }
  | S_AT { call(:dot, :S_AT, val) }
  | SUBPARTITION { call(:dot, :SUBPARTITION, val) }
  | STORAGE { call(:dot, :STORAGE, val) }
  | SQL { call(:dot, :SQL, val) }
  | SPATIAL { call(:dot, :SPATIAL, val) }
  | SMALLINT { call(:dot, :SMALLINT, val) }
  | SIMPLE { call(:dot, :SIMPLE, val) }
  | SET { call(:dot, :SET, val) }
  | SELECT { call(:dot, :SELECT, val) }
  | SECURITY { call(:dot, :SECURITY, val) }
  | ROW_FORMAT { call(:dot, :ROW_FORMAT, val) }
  | RESTRICT { call(:dot, :RESTRICT, val) }
  | REPLACE { call(:dot, :REPLACE, val) }
  | REPAIR { call(:dot, :REPAIR, val) }
  | REORGANIZE { call(:dot, :REORGANIZE, val) }
  | RENAME { call(:dot, :RENAME, val) }
  | REMOVE { call(:dot, :REMOVE, val) }
  | REFERENCES { call(:dot, :REFERENCES, val) }
  | REDUNDANT { call(:dot, :REDUNDANT, val) }
  | REBUILD { call(:dot, :REBUILD, val) }
  | REAL { call(:dot, :REAL, val) }
  | PRIMARY { call(:dot, :PRIMARY, val) }
  | PASSWORD { call(:dot, :PASSWORD, val) }
  | PARTITIONING { call(:dot, :PARTITIONING, val) }
  | PARTITION { call(:dot, :PARTITION, val) }
  | PARTIAL { call(:dot, :PARTIAL, val) }
  | PARSER { call(:dot, :PARSER, val) }
  | PACK_KEYS { call(:dot, :PACK_KEYS, val) }
  | ORDER { call(:dot, :ORDER, val) }
  | OR { call(:dot, :OR, val) }
  | OPTION { call(:dot, :OPTION, val) }
  | OPTIMIZE { call(:dot, :OPTIMIZE, val) }
  | ONLINE { call(:dot, :ONLINE, val) }
  | ON { call(:dot, :ON, val) }
  | OFFLINE { call(:dot, :OFFLINE, val) }
  | NUMERIC { call(:dot, :NUMERIC, val) }
  | NULL { call(:dot, :NULL, val) }
  | NOT { call(:dot, :NOT, val) }
  | NODEGROUP { call(:dot, :NODEGROUP, val) }
  | NO { call(:dot, :NO, val) }
  | MODIFY { call(:dot, :MODIFY, val) }
  | MIN_ROWS { call(:dot, :MIN_ROWS, val) }
  | MERGE { call(:dot, :MERGE, val) }
  | MEMORY { call(:dot, :MEMORY, val) }
  | MEDIUMTEXT { call(:dot, :MEDIUMTEXT, val) }
  | MEDIUMINT { call(:dot, :MEDIUMINT, val) }
  | MEDIUMBLOB { call(:dot, :MEDIUMBLOB, val) }
  | MAX_ROWS { call(:dot, :MAX_ROWS, val) }
  | MAXVALUE { call(:dot, :MAXVALUE, val) }
  | MATCH { call(:dot, :MATCH, val) }
  | L_CHARACTER_SET { call(:dot, :L_CHARACTER_SET, val) }
  | LONGTEXT { call(:dot, :LONGTEXT, val) }
  | LONGBLOB { call(:dot, :LONGBLOB, val) }
  | LOCAL { call(:dot, :LOCAL, val) }
  | LIKE { call(:dot, :LIKE, val) }
  | LESS { call(:dot, :LESS, val) }
  | LATIN1 { call(:dot, :LATIN1, val) }
  | LAST { call(:dot, :LAST, val) }
  | KEY_BLOCK_SIZE { call(:dot, :KEY_BLOCK_SIZE, val) }
  | KEYS { call(:dot, :KEYS, val) }
  | KEY { call(:dot, :KEY, val) }
  | INVOKER { call(:dot, :INVOKER, val) }
  | INTO { call(:dot, :INTO, val) }
  | INTEGER { call(:dot, :INTEGER, val) }
  | INT { call(:dot, :INT, val) }
  | INSERT_METHOD { call(:dot, :INSERT_METHOD, val) }
  | INNODB { call(:dot, :INNODB, val) }
  | INDEX { call(:dot, :INDEX, val) }
  | IN { call(:dot, :IN, val) }
  | IMPORT { call(:dot, :IMPORT, val) }
  | IGNORE { call(:dot, :IGNORE, val) }
  | IF { call(:dot, :IF, val) }
  | HASH { call(:dot, :HASH, val) }
  | FULLTEXT { call(:dot, :FULLTEXT, val) }
  | FULL { call(:dot, :FULL, val) }
  | FOREIGN { call(:dot, :FOREIGN, val) }
  | FLOAT { call(:dot, :FLOAT, val) }
  | FIXED { call(:dot, :FIXED, val) }
  | FIRST { call(:dot, :FIRST, val) }
  | EXISTS { call(:dot, :EXISTS, val) }
  | ENUM { call(:dot, :ENUM, val) }
  | ENGINE { call(:dot, :ENGINE, val) }
  | ENABLE { call(:dot, :ENABLE, val) }
  | DYNAMIC { call(:dot, :DYNAMIC, val) }
  | DROP { call(:dot, :DROP, val) }
  | DOUBLE { call(:dot, :DOUBLE, val) }
  | DISK { call(:dot, :DISK, val) }
  | DISCARD { call(:dot, :DISCARD, val) }
  | DISABLE { call(:dot, :DISABLE, val) }
  | DIRECTORY { call(:dot, :DIRECTORY, val) }
  | DESC { call(:dot, :DESC, val) }
  | DELETE { call(:dot, :DELETE, val) }
  | DELAY_KEY_WRITE { call(:dot, :DELAY_KEY_WRITE, val) }
  | DEFINER { call(:dot, :DEFINER, val) }
  | DEFAULT { call(:dot, :DEFAULT, val) }
  | DECIMAL { call(:dot, :DECIMAL, val) }
  | DATETIME { call(:dot, :DATETIME, val) }
  | DATE { call(:dot, :DATE, val) }
  | DATA { call(:dot, :DATA, val) }
  | CURRENT_USER { call(:dot, :CURRENT_USER, val) }
  | CURRENT_TIMESTAMP { call(:dot, :CURRENT_TIMESTAMP, val) }
  | CREATE { call(:dot, :CREATE, val) }
  | CONVERT { call(:dot, :CONVERT, val) }
  | CONSTRAINT { call(:dot, :CONSTRAINT, val) }
  | CONNECTION { call(:dot, :CONNECTION, val) }
  | COMPRESSED { call(:dot, :COMPRESSED, val) }
  | COMPACT { call(:dot, :COMPACT, val) }
  | COMMENT { call(:dot, :COMMENT, val) }
  | COLUMN_FORMAT { call(:dot, :COLUMN_FORMAT, val) }
  | COLUMN { call(:dot, :COLUMN, val) }
  | COLLATE { call(:dot, :COLLATE, val) }
  | COALESCE { call(:dot, :COALESCE, val) }
  | CHECKSUM { call(:dot, :CHECKSUM, val) }
  | CHECK { call(:dot, :CHECK, val) }
  | CHAR { call(:dot, :CHAR, val) }
  | CHANGE { call(:dot, :CHANGE, val) }
  | CASCADED { call(:dot, :CASCADED, val) }
  | CASCADE { call(:dot, :CASCADE, val) }
  | BY { call(:dot, :BY, val) }
  | BTREE { call(:dot, :BTREE, val) }
  | BLOB { call(:dot, :BLOB, val) }
  | BIT { call(:dot, :BIT, val) }
  | BINARY { call(:dot, :BINARY, val) }
  | BIGINT { call(:dot, :BIGINT, val) }
  | AVG_ROW_LENGTH { call(:dot, :AVG_ROW_LENGTH, val) }
  | AUTO_INCREMENT { call(:dot, :AUTO_INCREMENT, val) }
  | ASC { call(:dot, :ASC, val) }
  | AS { call(:dot, :AS, val) }
  | ANALYZE { call(:dot, :ANALYZE, val) }
  | ALTER { call(:dot, :ALTER, val) }
  | ALL { call(:dot, :ALL, val) }
  | ALGORITHM { call(:dot, :ALGORITHM, val) }
  | AFTER { call(:dot, :AFTER, val) }
  | ADD { call(:dot, :ADD, val) }
  | ACTION { call(:dot, :ACTION, val) }
  # END LITERAL (AUTO-GENERATED)
  # DO NOT EDIT THIS ABOVE SECTION

end

---- header
  require_relative 'lexer'
  require_relative 'ast'

  def deep_copy(o)
    Marshal.load(Marshal.dump(o))
  end

---- inner
  def initialize
    #@yydebug = true
    @phooks = Hash.new
    @pstate = Hash.new
  end

  def call(name, subname, val)
    tree = AST.new(name, subname, val)
    combined_name = subname.nil? ? name : "#{name}__#{subname}".to_sym
    if (@phooks.has_key? combined_name)
      @phooks[combined_name].call(tree, @pstate)
    end
    tree
  end

  def merge_hooks!(hooks)
    @phooks = hooks
  end

  def merge_state!(hash)
    @pstate.merge!(hash)
  end

  def parse(input)
    original_state = deep_copy(@pstate)

    space = [:S, ' ']
    to_prepend_space = [:S_BACKTICK_IN, :S_DOUBLEQUOTE_IN,
                        :S_SINGLEQUOTE_IN, :S_AT]
    to_append_space = [:S_BACKTICK_OUT, :S_DOUBLEQUOTE_OUT, :S_SINGLEQUOTE_OUT]
    to_wrap_space = [:S_COMMA, :S_EQUAL, :S_LEFT_PAREN, :S_RIGHT_PAREN]
    to_be_space = [:S_COMMENT, :S_REM_IN, :S_REM_OUT]
    s = tokenize(' ' + input + ' ') # append a space
      .map{ |t|
        case
          when to_be_space.include?(t[0])      then [space]
          when to_prepend_space.include?(t[0]) then [space, t]
          when to_append_space.include?(t[0])  then [t, space]
          when to_wrap_space.include?(t[0])    then [space, t, space]
          else [t]
        end
      }
      .flatten(1)
      .reduce([]) { |mem, obj|
        (!mem.empty? && mem[-1][0] == :S && obj[0] == :S) ? mem : mem << obj
      }
      .map{ |t| t[1] }
      .join

    ret = {
      tree: scan_str(s),
      state: @pstate
    }

    @pstate = original_state
    ret
  end
