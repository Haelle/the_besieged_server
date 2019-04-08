class Account < ApplicationRecord
  has_secure_password
  cattr_reader :current_password

  validates :email, uniqueness: true
  validates_format_of :email, with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/

  has_many :characters

  def update_with_password(account_params)
    current_password = account_params.delete(:current_password)

    if authenticate(current_password)
      update(account_params)
    else
      errors.add(:current_password, current_password.blank? ? :blank : :invalid)
      false
    end
  end

  def as_json(options = {})
    options[:except] ||= :password_digest
    super
  end
end
