ActiveAdmin.register User do
	permit_params :name, :email, :password, :password_confirmation
	filter :email
	index do
		selectable_column
		id_column
		column :email
		column :name
		column :last_sign_in_at
		column :created_at
		actions
	end
	form do |f|
		f.inputs "new user" do
			f.input :name
			f.input :email
			f.input :password
			f.input :password_confirmation
			f.button :submit
		end
	end

end