#encoding : utf-8

=begin
	author：	jiyaping
	time: 		2013-06-29
	email: 		jiyaping0802@gmail.com
	version: 	1.1
	description:使用pstool组件和windows自带程序完成远程系统管理功能
=end

#load libs
["yaml","logger", "net/smtp","openssl","base64","csv"].each { |lib| require lib }

#加载其它组件
["./load.rb", "./utils.rb", "./rpstools.rb", "./manager.rb"].each {|file| require file}

M = Manager::Manager.instance

#身份验证
puts "--------------------------------------"
print "Input your name:"
user_input = gets.strip
user_encrypt = Utils::Des.encode(user_input)
login_user = nil
login_user = user_input if CONFIG["users"].include? user_encrypt
if login_user
	puts "welcome #{login_user} !"
	puts "------------------------------------"
else
	puts "Refuse Login , Bye-Bye "
	puts "------------------------------------"
	exit
end


print "#{login_user} execute : "
cmd = gets.strip
M.run(cmd)


