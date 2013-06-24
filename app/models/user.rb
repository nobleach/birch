class User < ActiveRecord::Base
  
  require 'digest'
  require 'securerandom'

  def full_name
    self.first_name + ' ' + self.last_name
  end

  def self.create_reset_code
    # o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten;  
    # string  =  (0..50).map{ o[rand(o.length)]  }.join;
    reset_code = SecureRandom.hex
  end

  def self.make_salt(username="")
    Digest::SHA1.hexdigest("Dribble on #{username} with #{Time.now} to make salt")
  end

  def self.hash_with_salt(password="", salt="")
    Digest::SHA1.hexdigest("Pour some #{salt} on the #{password}")
  end

  attr_protected :hashed_password, :salt

  def self.authenticate(username="", password="")
    #query for matching user
    user = User.find_by_username(username)
    #if found, encrypt and compare hashed passwords
    if user && user.password_match?(password)
      return user
    else
      return false
    end
  end

  def password_match?(password="")
    hashed_password == User.hash_with_salt(password, salt)
  end
end
