module TLV

  # Attempt to parse a (series) or BER encoded
  # data structures. May be be passed a
  #
  #   "\x00"=> "Tag Name"
  #
  # encoded dictionary to provide names for tags.
  # Some dictionaries are predefined in TLV::DICTIONARIES
  #
  # Parameters:
  # +bytes+ : a string of raw bytes to decode
  # +dictionary+ : a tag=>name dictionary for tag name lookup
  #
  # Returns:
  # a string representation of the data structure
  def self.parse(bytes, dictionary={})
    tlv = TLV::Root.new
    _parse(bytes, dictionary, tlv)

    tlv
  end

  #
  # Attempt to decode a (series) of BER encoded
  # data structures (see parse)
  #
  # The data passed to this method is expected to
  # be hex formatted instead of in binary form.
  #
  def self.parse_hex(hex_str, dictionary={})
    self.parse s2b(hex_str), dictionary
  end

  #
  # Attempt to decode a DGI encoded data structure.
  # This is used in EMV (CPS).
  # see parse
  #
  def self.parse_dgi bytes, dictionary={}
    _parse_dgi(bytes, dictionary)
  end

  #
  # Attempt to decode a DGI encoded data structure.
  # This is used in EMV (CPS).
  # see parse_hex
  #
  def self.parse_dgi_hex hex_str, dictionary={}
    self.parse_dgi s2b(hex_str), dictionary
  end

  def self._parse(bytes, dictionary, parent)
    tlv_root = parent

    begin
      tlv, rest = _parse_tlv(bytes, dictionary)
      tlv_root.children << tlv
      bytes = rest
    end while rest && rest.length != 0

    tlv_root.children
  end

  def self._parse_tlv(bytes, dictionary)
    tlv = TLV::Node.new

    tag, rest = TLV.get_tag(bytes)
    tlv.tag = tag.pack('C*').unpack("H*").first
    if dictionary[tlv.tag]
      tlv.description = dictionary[tlv.tag]
    end

    if !rest || rest.empty?
      return [tlv, nil]
    end

    len, rest_2, display_len = TLV.get_length(rest)

    tlv.length = display_len

    if (tag[0] & 0x20) != 0x00 # constructed object
      tlv.children = _parse(rest_2[0, len], dictionary, tlv)
    else
      tlv.value = rest_2[0, len].bytes.to_a.pack("c*")
    end

    [tlv, rest_2[len, rest_2.length]]
  end

  def self.s2b(string)
    return '' unless string

    string = string.gsub(/\s+/, '')
    string = '0' + string unless (string.length % 2 == 0)

    [string].pack("H*")
  end

  def self.b2s(bytestr)
    return '' unless bytestr

    r = bytestr.unpack("H*")[0]
    r.length > 1 ? r : '  '
  end

  def self.get_tag(bytes)
    new_bytes = bytes.bytes.to_a

    tag = (new_bytes[0,1])

    if (tag[0] & 0x1f) == 0x1f # last 5 bits set, 2 byte tag
      tag = new_bytes[0,2]
      if (tag[1] & 0x80) == 0x80 # bit 8 set -> 3 byte tag
        tag = new_bytes[0,3]
      end
    end

    [tag, new_bytes[tag.length, new_bytes.length]]
  end

  def self.get_length(bytes)
    len = bytes[0, 1].first
    display_len = len
    num_bytes=0

    if (len & 0x80) == 0x80     # if MSB set
      display_len = b2s((bytes[0,3].pack('c*'))).to_i(16)

      num_bytes = len & 0x0F    # 4 LSB are num bytes total
      raise "Don't be silly: #{b2s(bytes)}" if num_bytes > 4

      len = ("#{"\x00"*(4-num_bytes)}%s" % len).unpack("N")[0]
    end

    # this will return ALL the rest, not just `len` bytes of the rest. Does this make sense?
    rest = bytes[1+num_bytes, bytes.length]
    # TODO handle errors...
    # warn if rest.length > length || rest.length < length ?

    return len, rest.pack('c*'), display_len
  end

end