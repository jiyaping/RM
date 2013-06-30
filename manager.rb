#encoding : utf-8

=begin
	author：	jiyaping
	time: 		2013-06-30
	email: 		jiyaping0802@gmail.com
	version: 	1.1
	description:管理工具。用户接口
=end

module Manager
	class Process
		def initialize(prc_name, svr, command, alive, window_name, type)
			@prc_name = prc_name			#进程名称
			@svr = svr						#服务器
			@command = command				#执行命令 可以是路径,也可以命令名
			@alive = alive					#检测存活方式
			@window_name = window_name		#窗口名称
			@type = type 					#执行的方式 目前有三种exe、bat、service,默认为exe

			@flag_i, @flag_d = true, true
		end

		attr_accessor :prc_name, :svr, :command, :alive, :window_name, :type, :flag_i, :flag_d

		#操作方法
		def stop
			RPSTools::stop(self)
		end

		def start
			RPSTools::start(self)
		end

		def restart
			RPSTools::restart(self)
		end

		def alive?
			RPSTools::alive?(self)
		end
	end

	class Server
		def initialize(name, ip, user, password, bussiness)
			@name = name
			@ip = ip
			@user = user
			@password = password
			@bussiness = bussiness

			@password = Utils::Des.decode(@password) if @password.end_with? "==\n"
		end

		attr_accessor :name, :ip, :user, :password, :bussiness
	end

	#管理器，为单例
	class Manager
		private_class_method :new
		@@instance = nil

		attr_accessor :server, :process

		def initialize
			@server = []
			@process = []

			#初始化server信息
			CONFIG["server"].each do |svr_name, svr_info|
				@server << Server.new(svr_name, svr_info["ip"], svr_info["user"], svr_info["password"], svr_info["bussiness"])
			end

			#初始化process
			CONFIG["process"].each do |prc_key, prc_info|
				svr_name, prc_name = prc_key.split("_")
				@process << Process.new(prc_name, get_server(svr_name), prc_info["command"], prc_info["alive"],
								 							 prc_info["window_name"], prc_info["type"])
			end
		end

		def self.instance
			@@instance = new unless @@instance
			@@instance
		end

		#运行操作命令 {action=>"stop",svr=>"test",bussiness=>"test",process=>"goagent"}
		def operate(hash)
			action = hash["action"]
			tmp_prcs = get_process(hash)
			
			tmp_prcs.each do |prc|
				eval("prc.#{action}")
			end
		end

		#执行命令 eg: stop svr process;start bussiness process2 ,默认为服务器名称
		def run(str)
			str.split(";").each do |s|
				operate(parse_action(s))
			end
		end

		#根据filer获取process svr和business只能有一个起作用 {svr=>"test",bussiness=>"test",process=>"goagent"}
		def get_process(hash)
			svr = hash["svr"]
			bussiness = hash["bussiness"]
			process = hash["process"]

			return "ERROR:server info and bussiness info are not nil !" if not svr.nil? and not bussiness.nil?

			temp = []
			@process.each do |prc|
				temp << prc if (prc.svr.name == svr or prc.svr.bussiness == bussiness) and prc.prc_name == process 
			end

			temp
		end

		#根据名称获取server对象
		def get_server(name)
			@server.each do |svr|
				return svr if svr.name == name
			end

			nil
		end

		private

		#解析命令参数
		def parse_action(str)
			action, limit, process = str.split(" ")
			hash = {"action"=>action, "svr"=>limit, "bussiness"=>limit, "process"=>process}
			if get_server(limit).nil?
				hash["svr"] = nil
			else
				hash["bussiness"] = nil
			end
			
			hash
		end
	end
end