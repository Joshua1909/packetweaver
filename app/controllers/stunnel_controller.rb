class StunnelController < ApplicationController

	def view
		if File.exist?('/etc/stunnel/stunnel.pem')
			stunnel_preconfigured = true
		else
			stunnel_preconfigured = false
		end
	end

	def new 
		if File.exist?('/etc/stunnel/stunnel.pem')
			redirect_to stunnel_view
		else
			Process.spawn("./stunnel_new_client.sh")
			redirect_to stunnel_view
		end
	end


	def delete 
		if File.exist?('/etc/stunnel/stunnel.pem')
			Process.spawn("sudo rm /etc/stunnel/stunnel.pem")
		else
			Process.spawn("./stunnel_new_client.sh")
			redirect_to stunnel_view
		end
	end
end
