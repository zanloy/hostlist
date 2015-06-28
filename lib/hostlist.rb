require 'bracecomp'
require 'daybreak'
require 'digest'
require 'yaml'

class HostList

  def initialize(yaml: '/etc/hostlist.yaml', cache: '~/.hostlist.db')
    @yaml = yaml
    @db_filename = cache
  end

  # Return array based on tags. Tags can be a string or array of strings.
  def list(tags)
    tags = [tags] if tags.is_a? String
    # Verify we have the most recent data in our daybreak cache.
    db = open_db
    begin
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
    ensure
      db.close
    end
    return hosts
  end

  # Return all the keys in the database.
  def keys
    db = open_db
    begin
      keys = db.keys
    ensure
      db.close
    end
    return keys
  end

  # Print the contents of the database for debugging purposes
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

  # Open cache database
  def open_db
    db = Daybreak::DB.new File.expand_path(@db_filename)
    if db.has_key? :md5
      file_md5 = Digest::MD5.file @yaml
      generate_db(db) unless file_md5 == db[:md5]
    else
      generate_db(db)
    end
    return db
  end

  # Read in yaml file and cache to database
  def generate_db(db)
    db.clear
    db[:all] = []
    hosts = YAML.load_file(@yaml)
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
    db[:md5] = Digest::MD5.file(@yaml).to_s
    db.flush
  end

  # Export the host list as an ansible hosts file.
  def export_ansible(filename = '/etc/ansible/hosts')
    db = open_db
    output = []
    begin
      db.keys.each do |key|
        next if key == 'md5'
        output << "[#{key}]"
        db[key].each do |host|
          output << host
        end
      end
      output = output.join("\n")
      if filename and File.writable? filename
        File.open(filename, 'w') { |f| f.write(output) }
      else
        puts output
      end
    ensure
      db.close
    end
  end

end
