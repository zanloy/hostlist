require 'hostlist'
require 'thor'

class HostListThor < Thor

  default_task :list

  class_option :yaml, type: :string, default: '/etc/hostlist.yaml'
  class_option :db, type: :string, default: '~/.hostlist.db'

  def method_missing(method, *args)
    args = ['list', method.to_s] + args
    HostListThor.start(args)
  end

  desc 'list', 'List hosts based on a tag.'
  def list(*tags)
    hostlist = HostList.new(yaml: options[:yaml], cache: options[:db])
    hostlist.list(tags).each { |host| puts host }
  end

  desc 'Show tags', 'Show all the tags in the cache database.'
  def show
    hostlist = HostList.new(yaml: options[:yaml], cache: options[:db])
    hostlist.keys.each { |key| puts key }
  end

  desc 'print_db', 'Print the contents of the database for debugging purposes.'
  def print_db
    hostlist = HostList.new(yaml: options[:yaml], cache: options[:db])
    hostlist.print_db
  end

  desc 'print_ansible', 'Print out the ansible hosts to stdout.'
  def print_ansible
    hostlist = HostList.new(yaml: options[:yaml], cache: options[:db])
    hostlist.export_ansible(nil)
  end

end
