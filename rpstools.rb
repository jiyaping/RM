#encoding : utf-8

=begin
	author：	jiyaping
	time: 		2013-06-30
	email: 		jiyaping0802@gmail.com
	version: 	1.1
	description:RPSTools包含pstools工具的ruby接口，后续会增加更多，程序借口
=end
require "csv"

module RPSTools
	def self.stop(process)
		type = process.type || "exe"
		flag_d = process.flag_d || true
		flag_i = process.flag_i || true
		pid = get_pid(process) if type == "bat"

		header = ".\\pskill \\\\#{process.svr.ip} -u #{process.svr.user} -p #{process.svr.password} "

		if type.strip == "bat"
			if process.window_name.strip == ""
				LOG.ERROR "the bat type command must configure the window_name" && return
			end

			pid = get_pid(process)
			result = system("#{header} #{pid}")
		elsif type.strip == "service"
			header = ".\\psexec \\\\#{process.svr.ip} #{"-d" if flag_d} #{"-i" if flag_i} \
					-u #{process.svr.user} -p #{process.svr.password} "
			result = system("#{header} net stop #{process.command}")
		elsif type.strip == "exe"
			temp_cmd = process.command.split("\\").last
			result = system("#{header} #{temp_cmd}")
		else
			LOG.ERROR ("the #{type} type do not support ! please check.")
		end
	end

	def self.start(process)
		type = process.type || "exe"
		flag_d = process.flag_d || true
		flag_i = process.flag_i || true

		header = ".\\psexec \\\\#{process.svr.ip} #{"-d" if flag_d} #{"-i" if flag_i} \
					-u #{process.svr.user} -p #{process.svr.password} "

		if type.strip == "bat"
			result = system("#{header} #{process.command}")
		elsif type.strip == "service"
			result = system("#{header} net start #{process.command}")
		elsif type.strip == "exe"
			result = system("#{header} #{process.command}")
		else
			LOG.ERROR ("the #{type} type do not support ! please check.")
		end
	end

	def self.restart(process)
		stop(process)
		start(process)
	end

	#判断是否存活
	def self.alive?(process)
		info = get_process_info(process)
		return true if info[1]>=0 and info[5].strip.upcase=="RUNNING"

		false
	end

	#可以直接执行语句,不对外开放
	def self.super_exec(str)
		result = `#{str}`
	end

	#获取process的PID,service不用获取pid
	def self.get_pid(process)
		get_process_info(process)[1]
	end

	#获取进程详细信息
	def self.get_process_info(process)
		data = tasklist(process)
		CSV.parse(data) do |row|
			prc_name, window_name = row.first, row.last

			if process.type == "bat"
				if process.window_name == window_name
					return row
				end
			else process.type == "exe"
				if process.command.split("\\").last == prc_name
					return row
				end
			end
		end
	end

	#获取服务器进程信息csv格式
	def self.tasklist(process)
		`tasklist /S #{process.svr.ip} /U #{process.svr.user} /P #{process.svr.password} /NH /FO csv`
	end

	def self.before
	end

	def self.after
	end
end