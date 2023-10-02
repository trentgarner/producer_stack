class User < ApplicationRecord
  has_many :blogs
  has_many :beats

  validates :first_name, presence: true
  validates :last_name, presence: true
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: {admin: 0, basic: 1}

  def full_name
    "#{first_name} #{last_name}"
  end

end