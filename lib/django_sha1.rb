# Note, this file defines a custom CryptoProvider (see Authlogic) for
# encrypting passwords and salts in the same fashion as Django.
# In Django's auth module, they simply sha1 hash the salt+raw_password.
# However, in the default Authlogic Sha1 CryptoProvider, they hash
# digest+'--'+salt 10 times.

require 'digest/sha1'

class DjangoSha1
  class << self
    # Turns your raw password into a Sha1 hash.
    def encrypt(*tokens)
      tokens = tokens.flatten
      digest = tokens.first
      token = tokens.second
      Digest::SHA1.hexdigest([token, digest].join(''))
    end

    # Does the crypted password match the tokens? Uses the same tokens that were used to encrypt.
    def matches?(crypted, *tokens)
      encrypt(*tokens) == crypted
    end
  end
end
