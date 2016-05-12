require 'fileutils'
require 'lib/datamapper/stored_file'

desc 'Checks directory "Manualy" and uploads all files from it'
task :manual_monitor do
  Dir["manual/*"].each do |path|
    file = File.new(path)
    filename = File.basename(file.path)
    digest = Digest::SHA1.hexdigest(filename)
    stored_file = StoredFile.new  filename: filename,
                                  sha: digest,
                                  filesize: File.size(file.path)
    FileUtils.mv path, "./files/#{stored_file.id}.upload"
    puts "File #{stored_file.filename} successfully uploaded. ID = #{stored_file.id}"
  end
end
