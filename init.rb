require 'rubygems'

# Sinatra
# require 'sinatra'
require File.expand_path(File.dirname(__FILE__) + '/lib/sinatra/lib/sinatra')

# Local config
require File.expand_path(File.dirname(__FILE__) + '/lib/config')

# File operations
require 'fileutils'

# DataMapper
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-migrations'

# Class for Stored Files
require "#{File.dirname(__FILE__)}/lib/stored_file"


# Список файлов
get  '/' do
  @files = StoredFile.all
  haml :list
end

# Загрузка файлов
post '/' do
  temp_file = params['file'][:tempfile]
  filename  = params['file'][:filename]
  digest = Digest::SHA1.hexdigest(filename)
  @file = StoredFile.new filename: params['file'][:filename],
                         created_at: DateTime.now,
                         sha: digest,
                         filesize: File.size(temp_file.path)
  @file.save!
  FileUtils.copy(temp_file.path, "./files/#{@file.id}.upload")
  redirect '/'
end

# Скачка файлов
get '/:sha' do
  @file = StoredFile.first(sha: params[:sha])
  @file.dowloads += 1
  @file.save

  if @file
    send_file "./files/#{@file.id}.upload", filename: @file.filename, type: 'Application/octet-stream'
    redirect '/'
  else
    "File Not Found"
  end
end

get '/:sha/delete' do
  StoredFile.first(sha: params[:sha]).destroy
  File.delete("./files/#{params[:id]}.upload")
  redirect '/'
end
