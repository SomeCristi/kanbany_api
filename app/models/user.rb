class User < ApplicationRecord
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
end


# TODO Add valdiations for password and email format
