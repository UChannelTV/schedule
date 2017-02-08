require 'json'
require_relative './http_util'
require 'csv'

module Dump
  include HttpUtil

  def self.dump(host, target)
    url = host + "/schedule/#{target}/dump"
    puts url
    header = {'Content-Type' => 'application/json'}
    JSON.parse(HttpUtil.get(url, header).body)
  end

  def self.nameCodeProgramId(host)
    retVal = [{}, {}]
    dump(host, "programs").each do |row|
      retVal[0][row["name"]] = row["id"]
      retVal[1][row["code"]] = row["id"]
    end
    retVal
  end
end

#info = Dump.nameCodeProgramId(ARGV[0])

