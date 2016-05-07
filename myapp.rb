require 'rubygems'
require 'sinatra'
require 'fileutils'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/mydatabase.sqlite3")

use Rack::Auth::Basic do |username, password|
  username == 'admin' && password == 'secret'
end

class StoredFile
  include DataMapper::Resource

  property :id,         Serial
  property :filename,   String,  required: true
  property :created_at, DateTime

  default_scope(:default).update(:order => [:created_at.desc])
end

DataMapper.auto_migrate!
DataMapper.auto_upgrade!

# Список файлов
get  '/' do
  @files = StoredFile.all
  erb :list
end

# Загрузка файлов
post '/' do
  temp_file = params['file'][:tempfile]
  @file = StoredFile.new filename: params['file'][:filename], created_at: DateTime.now
  @file.save!
  FileUtils.copy(temp_file.path, "./files/#{@file.id}.upload")
  redirect '/'
end

# Скачка файлов
get '/:id' do
  @file = StoredFile.get(params[:id])
  send_file "./files/#{@file.id}.upload", filename: @file.filename, type: 'Application/octet-stream'
  redirect '/'
end

get '/:id/delete' do
  StoredFile.get(params[:id]).destroy
  File.delete("./files/#{params[:id]}.upload")
  redirect '/'
end
