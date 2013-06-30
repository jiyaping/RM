#encoding : utf-8

=begin
	author：	jiyaping
	time: 		2013-06-30
	email: 		jiyaping0802@gmail.com
	version: 	1.1
	description:Utils模块包含常用函数、Des加密解密、邮件通知等用途
=end

["net/smtp","openssl","base64"].each { |lib| require lib }

#tools methods
module Utils
	def self.format_time(time)
		time.strftime("%Y-%m-%d %H:%M:%S")
	end

	def self.now
		Utils::format_time(Time.now)
	end

	# encrypt and decrypt
	class Des
		@@alg = 'DES-EDE3-CBC'
		@@key = 'jiyaping'
		@@des_key = "jiyaping"
		
		#加密
		def self.encode(str)
			des = OpenSSL::Cipher::Cipher.new(@@alg)
			des.pkcs5_keyivgen(@@key, @@des_key)
			des.encrypt
			chipher = des.update(str.strip)
			chipher << des.final

			return Base64.encode64(chipher)
		end

		#解密
		def self.decode(str)
			str = Base64.decode64(str)
			des = OpenSSL::Cipher::Cipher.new(@@alg)
			des.pkcs5_keyivgen(@@key, @@des_key)
			des.decrypt
			des.update(str) + des.final
		end
	end

	#用于邮件通知事件
	class Mail
		def initialize(mail)
			@stmp = mail["smtp"].strip
			@domain = mail["domain"].strip
			@port = mail["port"].strip.to_i
			@user = mail["user"].strip
			@password = mail["password"].strip

			@user = @user + "@" + @domain unless @user.index '@' #使user变成  xxx@xxx.com 的形式
			@password = Des.decode(@password) #解密password
		end

		#send mail 方法
		def send(title, content, receiver)
			message = build_message(title, content, receiver)

			begin
				Net::SMTP.start(@stmp, @port, @domain, @user, @password, :login) do |smtp|
					receiver.each do |sendto|
						smtp.sendmail(message, @user, sendto)
					end
				end
			rescue Exception => e
				LOG.ERROR "An Error occured" + e
			end
		end

		private

		#构建一个发送消息
		def build_message(title, content, receiver, time = Utils.now)

			message = <<MESSAGE
			From: #{@user}
			To: #{receiver.join(',')}
			MIME-Version: 1.0
			Content-type: text/html
			Subject: #{title}

			#{content}

			#{time}
MESSAGE
			
			message
		end
	end
end