module Tog
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 2
    TINY  = 1
    # http://en.wikipedia.org/wiki/Moons_of_Jupiter
    CODENAME = 'Adrastea'
    STRING = [MAJOR, MINOR, TINY].join('.')
    
    class << self
      def to_s
        "#{CODENAME} #{STRING}"
      end
      alias :to_str :to_s
    end
    
  end
end