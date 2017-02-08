require 'json'
require_relative './http_util'
require 'csv'

module Import
  include HttpUtil

  def self.import(host, target, data)
    url = host + "/schedule/#{target}/import"
    puts url
    header = {'Content-Type' => 'application/json'}
    HttpUtil.post(url, header, {"entities" => data}.to_json)
  end
  
  def self.readTsv(names, default_value, fname)
    retVal = []
    CSV.foreach(fname, col_sep: "\t", headers: true) do |row|
      value = default_value.clone
      names.each do |key, val|
        value[val] = row[key] if !row[key].nil?
      end
      retVal << value
    end
    retVal
  end

  def self.getImporter(host, target)
    case target
    when ProviderImporter.target
      return ProviderImporter.new(host)
    when CategoryImporter.target
      return CategoryImporter.new(host)
    when ProgramImporter.target
      return ProgramImporter.new(host)
    else
      raise "Unknown target #{target}"
    end
  end

  class Importer
    def initialize(host, target, default_value, fields)
      @host = host
      @target = target
      @fields = fields
      @default_value = default_value
    end

    def import(fname)
      data = Import.readTsv(@fields, @default_value, fname)
      response = Import.import(@host, @target, data)
      puts response.code
      puts response.body
    end
  end

  class ProviderImporter < Importer
    @@target = "providers"

    def initialize(host)
      super(host, @@target, {}, 
            {"PVCODE" => "code", "PVNAME" => "name", "PVFULLNAME" => "full_name",
             "PVSOURCE" => "source", "STATUS" => "status", "REMARK" => "remark"})
    end

    def self.target
      @@target
    end
  end

  class CategoryImporter < Importer
    @@target = "categories"
    
    def initialize(host)
      super(host, @@target, {},
            {"CACODE" => "eng_name", "CANAME" => "name", 
             "STATUS" => "status", "REMARK" => "remakr"})
    end

    def self.target
      @@target
    end
  end

  class ProgramImporter < Importer
    @@target = "programs"
    
    def initialize(host)
      super(host, @@target, {},
            {"PGNAME" => "name", "PGENGNAME" => "eng_name", "PGCODE" => "code",
             "CATEGORYID" => "category_id", "PROVIDERID" => "provider_id",
             "TOTALEPISODE" => "total_episodes", "PGLANGUAGE" => "language",
             "ISINHOUSE" => "is_in_house", "ISLIVE" => "is_live", 
             "STATUS" => "status", "REMARK" => "remakr"})
    end

    def self.target
      @@target
    end
  end
end

#importer = Import.getImporter(ARGV[0], ARGV[1])
#importer.import(ARGV[2])
