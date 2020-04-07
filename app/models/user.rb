class User < ApplicationRecord
  PASSWORD_REQUIREMENTS = /\A
    (?=.{8,}) # is at least 8 characters long
    (?=.*\d) # contains at least one number
    (?=.*[a-z]) # contains at least one lowercase letter
    (?=.*[A-Z]) # contains at least one uppercase letter
    (?=.*[[:^alnum:]]) # contains at least one symbol
  /x
  # encrypt the password
  # Adds methods to set and authenticate against a BCrypt password.
  # This mechanism requires you to have a XXX_digest attribute.
  # Where XXX is the attribute name of your desired password
  has_secure_password

  # Model associations
  has_many :tasks, class_name: "Task", foreign_key: "assigned_to_id", dependent: :nullify
  has_many :created_tasks, class_name: "Task", foreign_key: "created_by_id", dependent: :destroy
  has_many :boards, class_name: "Board", foreign_key: "created_by_id"
  has_many :columns, class_name: "Column", foreign_key: "created_by_id"

  # Validations
  validates_presence_of :name, :email, :password_digest
  validates :email, uniqueness: true, case_sensitive: false, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password,
    format: {
      with: PASSWORD_REQUIREMENTS,
      message: "Password must be at least 8 characters long with a at least: one upercase letter, one symbol and one number"
    }
end


