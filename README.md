MySQLParser
===========

This is a library to parse SQL commands. The only commands that are currently
supported are ddl statements, specifically CREATE TABLE, ALTER TABLE, DROP VIEW,
and DROP TABLE.

Installation
------------

In command line:

    > gem install mysql-parser.x.x.x.gem

Usage
-----

In ruby:

    > require 'mysql-parser'
    > MySQLParser.new.parse "ALTER TABLE `table` DROP INDEX abc, DROP INDEX def"
    => {:tree=><root: [<S: [" "]>, <r_commands: [<r_ALTER_TABLE: ["ALTER", <S: [" "]>, <r_ONLINE_OFFLINE: []>, <r_opt_IGNORE: []>, "TABLE", <S: [" "]>, <r_tbl_name: [<r_tbl_name_int: [<ident: ["`", <opt_ident_in_backtick: [<opt_ident_in_backtick: []>, "table"]>, "`", <S: [" "]>]>]>]>, <r_opt_alter_commands: [<r_comma_separated_alter_specification: [<r_comma_separated_alter_specification: [<r_alter_specification: ["DROP", <S: [" "]>, <r_INDEX_or_KEY: ["INDEX", <S: [" "]>]>, <r_index_name: [<ident: [<raw_ident: ["abc", <S: [" "]>]>]>]>]>]>, <comma: [",", <S: [" "]>]>, <r_alter_specification: ["DROP", <S: [" "]>, <r_INDEX_or_KEY: ["INDEX", <S: [" "]>]>, <r_index_name: [<ident: [<raw_ident: ["def", <S: [" "]>]>]>]>]>]>]>, <r_opt_after_alter: []>, <r_opt_PARTITION_options: []>]>]>]>, :state=>{}}

Files
-----

### mysql.rex.rb
This file is a lexer. It determines that `DROP` is a command, and
that `'abcdef'` is a string. Most of this file is auto-generated
by `bin/generate-literal` which reads `mysql.y.rb` and generates the required
literals automatically. Therefore this file will not normally need to be edited.
The following reasons might be reason to edit it:

1. Creating a synonym
2. Creating a long literal[1]
3. Creating a literal which doesn't exist in the parser already

[1] a long literal is a literal which is needed for a special purpose, for example,
because it consists of spaces and needs a synonym to be assigned to it.
Normally, however, we do not need them.

#### Convention

1. `S_...` means some symbol
2. `A_...` means some state
3. `L_...` means long literal
4. Everything else is literal

### mysql.y.rb
This is the main file of this library. It contains all grammar and associated
actions.

#### Grammar

The original MySQL grammar can be found at
https://github.com/twitter/mysql/blob/master/sql/sql_yacc.yy. The documentation
can be found under https://dev.mysql.com/doc/refman/5.6/en/

##### Conflict
`sql_yacc.yy` is not perfect. It contains a lot of conflicts. When translating
to `mysql.y.rb`, please resolve those conflicts so that the rules can be
predictable.

#### Debugging

Debugging `mysql.y.rb` can be done by passing `true` as `debug` argument.

```ruby
MySQLParser.new(debug: true)
```

#### Literals

Introduction of a new literals can be done by just _using_ it. `bin/generate-literal.rb`
will read `mysql.y.rb` and make sure that new literals are created.
Similarly, removing any literal can be done by just _not using_ it.

#### Convention

Following is general convention.

1. Space is `S`
2. `opt_...` means that the rule is optional. The first branch should be
empty.
3. `{comma, space}_separated_...` means a collection of items separated by
a separator (comma or space)

### bin/generate-literal.rb

This script scans `mysql.y.rb` (or actually, `parser.output` which is
generated from `mysql.y.rb`) and adds new literals that don't exist, and
removes literals that are unused.

### bin/runner

This is a REPL. Just input whatever and send an end-of-file character
(`ctrl-d`) to let the script process the input. To exit, just terminate
using `ctrl-c`.

    > DROP TABLE


    table
    ^D
    parse error on value "table" (TABLE)
    >

### bin/sanity_check

This script makes sure that there is no skipped action and that all action
names are correct.

Development
-----------

After changing `mysql.rex.rb` or `mysql.y.rb`, run `rake generate` to
generate the real lexer and parser. Run `rake spec` to run all test cases

License
=======

    Copyright 2015 Square, Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
