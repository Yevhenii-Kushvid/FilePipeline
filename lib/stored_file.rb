# DataMapper
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/files.sqlite3")

class StoredFile
  include DataMapper::Resource

  property :id,         Serial
  property :filename,   String,  required: true
  property :created_at, DateTime

  property :sha,        String

  property :dowloads,   Integer, default: 0
  property :filesize,   Integer, required: true

  default_scope(:default).update(:order => [:created_at.desc])
end

DataMapper.auto_migrate!
DataMapper.auto_upgrade!
