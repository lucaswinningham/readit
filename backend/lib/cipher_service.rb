class CipherService
  def self.encrypt(plain_text)
    cipher = new_cipher
    cipher.encrypt
    cipher.key = key
    cipher.iv = iv
    encrypted = cipher.update(plain_text) + cipher.final
    encoded = Base64.encode64(encrypted)
  end

  def self.decrypt(encoded)
    decoded = Base64.decode64(encoded)
    cipher = new_cipher
    cipher.decrypt
    cipher.key = key
    cipher.iv = iv
    decrypted = cipher.update(decoded) + cipher.final
  end

  def self.new_cipher
    OpenSSL::Cipher::AES128.new(:CBC)
  end

  def self.key
    Base64.decode64(ENV['CIPHER_KEY'])
  end

  def self.iv
    Base64.decode64(ENV['CIPHER_IV'])
  end
end
