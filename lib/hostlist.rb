require 'daybreak'
require 'digest'
require 'thor'
require 'yaml'

class HostList < Thor

  class_option :yaml, type: :string, default: 'hostlist.yaml'
  class_option :db, type: :string, default: '~/.hostlist.db'

  desc 'list', 'List hosts based on a tag.'
  def list(*tags)
    # Verify we have the most recent data in our daybreak cache.
    db_filename = File.expand_path(options[:db])
    db = Daybreak::DB.new db_filename
    begin
      if db.has_key? :md5
        file_md5 = Digest::MD5.file options[:yaml]
        generate_db(db) unless file_md5 == db[:md5]
      else
        generate_db(db)
      end
      db.load
      # Collect all the tags from the database
      hosts = []
      tags.each do |tag|
        if db.has_key? tag
          if hosts == []
            hosts = db[tag]
          else
            hosts = hosts & db[tag]
          end
        end
      end
      hosts.each { |host| puts host }
    ensure
      db.close
    end
  end

  desc 'print_db', 'Print the contents of the database for debugging purposes'
  def print_db
    db = Daybreak::DB.new File.expand_path(options[:db])
    begin
      db.keys.each do |key|
        puts "db[#{key}] = #{db[key]}"
      end
    ensure
      db.close
    end
  end

  no_tasks do
    def generate_db(db)
      puts 'called generate_db'
      db.clear
      hosts = YAML.load_file(options[:yaml])
      hosts.each do |key, value|
        value['tags'].each do |tag|
          if db.has_key? tag
            db[tag] << key
          else
            db[tag] = [key]
          end
        end
      end
      db[:md5] = Digest::MD5.file(options[:yaml]).to_s
    end
  end

end
