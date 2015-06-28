require 'bracecomp'
require 'daybreak'
require 'digest'
require 'thor'
require 'yaml'

class HostList < Thor

  default_task :list

  class_option :yaml, type: :string, default: '/etc/hostlist.yaml'
  class_option :db, type: :string, default: '~/.hostlist.db'

  def method_missing(method, *args)
    args = ['list', method.to_s] + args
    HostList.start(args)
  end

  desc 'list', 'List hosts based on a tag.'
  def list(*tags)
    # Verify we have the most recent data in our daybreak cache.
    db = open_db
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
      if tags.empty?
        hosts = db[:all]
      else
        tags.each do |tag|
          if db.has_key? tag
            if hosts == []
              hosts = db[tag]
            else
              hosts = hosts & db[tag]
            end
          end
        end
      end
      hosts.each { |host| puts host }
    ensure
      db.close
    end
  end

  desc 'Show tags', 'Show all the tags in the cache database.'
  def show
    db = open_db
    begin
      db.keys.each do |key|
        puts key
      end
    ensure
      db.close
    end
  end

  desc 'print_db', 'Print the contents of the database for debugging purposes'
  def print_db
    db = open_db
    begin
      db.keys.each do |key|
        puts "db[#{key}] = #{db[key]}"
      end
    ensure
      db.close
    end
  end

  no_tasks do
    def open_db
      Daybreak::DB.new File.expand_path(options[:db])
    end

    def generate_db(db)
      db.clear
      db[:all] = []
      hosts = YAML.load_file(options[:yaml])
      hosts.each do |key, value|
        value['tags'].each do |tag|
          if db.has_key? tag
            db[tag] += key.expand
          else
            db[tag] = key.expand
          end
        end
        # Add servers to :all
        # TODO: Figure out why this isn't working. db[:all] is always an empty array.
        key.expand.each { |host| db[:all] += [host] unless db[:all].include?(host) }
      end
      db[:md5] = Digest::MD5.file(options[:yaml]).to_s
      db.flush
    end
  end

end
