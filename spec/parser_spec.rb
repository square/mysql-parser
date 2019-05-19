require './lib/mysql-parser.rb'

class MySQLParserTester
  describe 'Testing the Parser' do

    def test
      expect(@result[:tree].to_s)
    end

    before(:each) do
      @evaluator = MySQLParser.new
    end

    it 'tests for drop foreign key' do
      @result = @evaluator.parse("ALTER TABLE Orders DROP FOREIGN KEY
      fk_PerOrders /* ignore this */  , DROP FOREIGN KEY `a\n\nbc` -- , DROP FOREIGN KEY def")

      test.to eq(" ALTER TABLE Orders DROP FOREIGN KEY fk_PerOrders\
 , DROP FOREIGN KEY `a\n\nbc` ")

    end

    it 'tests for commas' do
      @result = @evaluator.parse("ALTER TABLE Orders DROP FOREIGN KEY
      fk_PerOrders,DROP FOREIGN KEY `a\n\nbc` -- , DROP FOREIGN KEY def")

      test.to eq(" ALTER TABLE Orders DROP FOREIGN KEY fk_PerOrders\
 , DROP FOREIGN KEY `a\n\nbc` ")
    end

    it 'tests for bad drop' do
      expect{
        @evaluator.parse('ALTERTABLE Orders DROP FOREIGN KEY fk_PerOrder')
      }.to raise_error(ParseError)
    end

    it 'tests for alter table options' do
      @result = @evaluator.parse('ALTER ONLINE IGNORE TAbLE`myTaBle` ROW_FORMAT DYNAMIC, CHECKSUM = 0')
      test.to eq(' ALTER ONLINE IGNORE TAbLE `myTaBle` ROW_FORMAT DYNAMIC , CHECKSUM = 0 ')
    end

    it 'tests by cmg' do
      @result = @evaluator.parse('ALTER TABLE bogus ENGINE=InnoDB , ROW_FORMAT=COMPRESSED, KEY_BLOCK_SIZE=4, CHECKSUM=1, DROP FOREIGN KEY fk1')
      test.to eq(' ALTER TABLE bogus ENGINE = InnoDB , ROW_FORMAT = COMPRESSED , KEY_BLOCK_SIZE = 4 , CHECKSUM = 1 , DROP FOREIGN KEY fk1 ')
    end

    it 'tests for run - short' do
      @result = @evaluator.parse('ALTER TABLE bogus DROP INDEX abc')
      test.to eq(' ALTER TABLE bogus DROP INDEX abc ')
    end

    it 'tests for run - short multi 1' do
      @result = @evaluator.parse('ALTER TABLE bogus DROP INDEX abc, DROP INDEX def')
      test.to eq(' ALTER TABLE bogus DROP INDEX abc , DROP INDEX def ')
    end

    it 'tests for run - short multi 2' do
      @result = @evaluator.parse("ALTER TABLE bogus DROP INDEX abc, MODIFY COLUMN x ENUM ('a', 'b', 'c')")
      test.to eq(" ALTER TABLE bogus DROP INDEX abc , MODIFY COLUMN x ENUM ( 'a' , 'b' , 'c' ) ")
    end

    it 'tests for run - long 1' do
      @result = @evaluator.parse("ALTER TABLE bogus ENABLE KEYS, MODIFY COLUMN x ENUM ('a', 'b', 'c')")
      test.to eq(" ALTER TABLE bogus ENABLE KEYS , MODIFY COLUMN x ENUM ( 'a' , 'b' , 'c' ) ")
    end

    it 'tests for run - short 3' do
      @result = @evaluator.parse("ALTER TABLE bogus MODIFY COLUMN x ENUM ('a''def', 'b'     , 'c'), MODIFY COLUMN y ENUM ('a', 'b', 'c')")
      test.to eq(" ALTER TABLE bogus MODIFY COLUMN x ENUM ( 'a''def' , 'b' , 'c' ) , MODIFY COLUMN y ENUM ( 'a' , 'b' , 'c' ) ")
    end

    it 'tests for run - long 2' do
      @result = @evaluator.parse("ALTER TABLE bogus MODIFY COLUMN x ENUM ('a', 'b', 'c'), MODIFY COLUMN y INT")
      test.to eq(" ALTER TABLE bogus MODIFY COLUMN x ENUM ( 'a' , 'b' , 'c' ) , MODIFY COLUMN y INT ")
    end

    it 'tests for empty string' do
      @result = @evaluator.parse("ALTER TABLE bogus MODIFY COLUMN x ENUM ('', 'b', 'c'), MODIFY COLUMN y INT")
      test.to eq(" ALTER TABLE bogus MODIFY COLUMN x ENUM ( '' , 'b' , 'c' ) , MODIFY COLUMN y INT ")
    end

    it 'tests by cmg2' do
      @result = @evaluator.parse('ALTER TABLE bogus ENGINE=InnoDB ROW_FORMAT=COMPRESSED, KEY_BLOCK_SIZE=4, CHECKSUM=1, DROP FOREIGN KEY fk1')
      test.to eq(' ALTER TABLE bogus ENGINE = InnoDB ROW_FORMAT = COMPRESSED , KEY_BLOCK_SIZE = 4 , CHECKSUM = 1 , DROP FOREIGN KEY fk1 ')
    end

    it 'tests alter union' do
      @result = @evaluator.parse('alter table abc MAX_ROWS = 1, UNION = (a, b, c), MIN_ROWS=0')
      test.to eq(' alter table abc MAX_ROWS = 1 , UNION = ( a , b , c ) , MIN_ROWS = 0 ')
    end

    it 'tests alter add columns' do
      @result = @evaluator.parse('alter table `add` add column abc DATE')
      test.to eq(' alter table `add` add column abc DATE ')
    end

    it 'tests alter add foreign keys' do
      @result = @evaluator.parse('alter table `child` add constraint `fk` foreign key (`parent_id`) references `parent` (`id`)')
      test.to eq(' alter table `child` add constraint `fk` foreign key ( `parent_id` ) references `parent` ( `id` ) ')
    end

    it 'tests for bad keyword' do
      expect{
        @evaluator.parse('alter table select add column abc DATE')
      }.to raise_error(ParseError)
    end

    it 'tests from w3schools' do
      @result = @evaluator.parse('ALTER TABLE Persons
ADD DateOfBirth date')
      test.to eq(' ALTER TABLE Persons ADD DateOfBirth date ')
    end

    it 'tests for discard tablespace' do
      @result = @evaluator.parse('ALTER TABLE Persons
DISCARD TABLESPACE')
      test.to eq(' ALTER TABLE Persons DISCARD TABLESPACE ')
    end

    it 'tests for remove partitioning' do
      @result = @evaluator.parse('ALTER TABLE Persons
REMOVE PARTITIONING')
      test.to eq(' ALTER TABLE Persons REMOVE PARTITIONING ')
    end

    it 'tests for normal op and remove partitioning' do
      @result = @evaluator.parse('ALTER TABLE Persons ENABLE KEYS
REMOVE PARTITIONING')
      test.to eq(' ALTER TABLE Persons ENABLE KEYS REMOVE PARTITIONING ')
    end

    it 'tests from pending migration1' do
      @result = @evaluator.parse('ALTER TABLE transmission_entries ADD COLUMN live boolean DEFAULT NULL')
      test.to eq(' ALTER TABLE transmission_entries ADD COLUMN live boolean DEFAULT NULL ')
    end

    it 'tests from failed migration1' do
      expect {
        @evaluator.parse('ALTER TABLE invoices DROP INDEX `merchant_invoice_number`, DROP INDEX `invoices_merchant_token_state_index`, CHANGE COLUMN merchant_token VARCHAR(255) NULL')
      }.to raise_error(ParseError)
    end

    it 'tests for bare alter table' do
      @result = @evaluator.parse('ALTER TABLE invoices')
      test.to eq(' ALTER TABLE invoices ')
    end

    it 'tests for multidot' do
      @result = @evaluator.parse('DROP TABLE asd.dsa')
      test.to eq(' DROP TABLE asd.dsa ')
    end

    it 'tests for too many dot' do
      expect{
        @evaluator.parse('DROP TABLE asd.dsa.def')
      }.to raise_error(ParseError)
    end

    it 'tests for alter table with compressed / key_block_size' do
      @result = @evaluator.parse("ALTER TABLE asd ENGINE=Innodb \
ROW_FORMAT=Compressed KEY_BLOCK_SIZE=8")
      test.to eq(" ALTER TABLE asd ENGINE = Innodb \
ROW_FORMAT = Compressed KEY_BLOCK_SIZE = 8 ")
    end

    it 'tests for create table' do
      @result = @evaluator.parse("CREATE TABLE Persons
(
PersonID int,
LastName varchar(255),
FirstName varchar(255),
Address varchar(255),
City varchar(255)
)")

      test.to eq(" CREATE TABLE Persons ( PersonID int , \
LastName varchar ( 255 ) , FirstName varchar ( 255 ) , \
Address varchar ( 255 ) , City varchar ( 255 ) ) ")
    end

    it 'tests for empty backtick' do
      @result = @evaluator.parse("    DROP TABLE ``")
      test.to eq(" DROP TABLE `` ")
    end

    it 'tests for hooks (positive)' do
      hooks = {
        r_DROP_VIEW: lambda do |val, state|
          state[:abc] = 123
        end
      }
      @evaluator.merge_hooks! hooks
      @evaluator.merge_state! Hash.new
      @result = @evaluator.parse("DROP VIEW def")
      expect(@result[:state][:abc]).to eq(123)
      test.to eq(" DROP VIEW def ")
    end

    it 'tests for hooks (negative, modify)' do
      hooks = {
        r_DROP_VIEW: lambda do |tree, state|
          state[:abc] = 123
        end,
        r_ALTER_TABLE: lambda do |tree, state|
          raw_ident = tree
            .find_top(name: :r_tbl_name)
            .find_left(name: :raw_ident)
          raw_ident.val[0] = "abc"
        end
      }
      @evaluator.merge_hooks! hooks
      @evaluator.merge_state! Hash.new
      @result = @evaluator.parse("ALTER TABLE def")
      expect(@result[:state]).to eq({})
      test.to eq(" ALTER TABLE abc ")
    end

    it 'tests for hooks with subname' do
      hooks = {
        ident__without_backtick: lambda do |tree, state|
          tree.val[0].val[0] = "abc"
        end
      }
      @evaluator.merge_hooks! hooks
      @evaluator.merge_state! Hash.new
      @result = @evaluator.parse("ALTER TABLE def")
      expect(@result[:state]).to eq({})
      test.to eq(" ALTER TABLE abc ")
    end

    it 'tests for to_list' do
      @result = @evaluator.parse("ALTER TABLE bogus MODIFY COLUMN x ENUM (  'a'  ,  'zzz', 'c', 'd'), MODIFY COLUMN y INT")
      expect(
        @result[:tree]
          .find_left(name: :r_comma_separated_string)
          .to_list
          .select { |v| v.name == :string }
          .length
      ).to eq(4)
    end
  end
end
