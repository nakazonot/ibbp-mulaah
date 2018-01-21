class Services::Eth::AddressValidator

  def initialize(address)
    @address = address
  end

  def call
    valid?
  end

  private

  def valid?
    if !matches_any_format?
      false
    elsif not_checksummed?
      true
    else
      checksum_matches?
    end
  end

  def checksummed
    return nil unless matches_any_format?

    cased = unprefixed.chars.zip(checksum.chars).map do |char, check|
      check.match(/[0-7]/) ? char.downcase : char.upcase
    end

    prefix_hex(cased.join)
  end

  def checksum_matches?
    @address == checksummed
  end

  def not_checksummed?
    all_uppercase? || all_lowercase?
  end

  def all_uppercase?
    @address.match(/(?:0[xX])[A-F0-9]{40}/)
  end

  def all_lowercase?
    @address.match(/(?:0[xX])[a-f0-9]{40}/)
  end

  def matches_any_format?
    @address.match(/\A(?:0[xX])[a-fA-F0-9]{40}\z/)
  end

  def checksum
    bin_to_hex(keccak256 unprefixed.downcase)
  end

  def unprefixed
    remove_hex_prefix(@address)
  end

  def prefix_hex(hex)
    hex.match(/\A0x/) ? hex : "0x#{hex}"
  end

  def remove_hex_prefix(s)
    s[0,2] == '0x' ? s[2..-1] : s
  end

  def keccak256(x)
    Digest::SHA3.new(256).digest(x)
  end

  def bin_to_hex(string)
    string.unpack('H*').first
  end
end