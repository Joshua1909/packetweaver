class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :confirmable,:timeoutable,
         :recoverable, :rememberable, :trackable, :validatable
end
