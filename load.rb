#encoding : utf-8

=begin
	author：	jiyaping
	time: 		2013-06-30
	email: 		jiyaping0802@gmail.com
	version: 	1.1
	description:使用读取配置文件存入全局变量CONFIG中
=end

require "yaml"
require "logger"

CONFIG = YAML.load_file 'config.yaml'

#log default path is "log.txt" ,default level is DEBUG
log_path = CONFIG["log"]["path"].strip || "log.txt"
log_level = CONFIG["log"]["level"].strip || "DEBUG"
LOG = Logger.new log_path
LOG.level = eval("Logger::#{log_level}")