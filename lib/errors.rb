module Genosaurus
  module Errors
    
    # Raised if a Genosaurus::Base required parameter is not supplied.
    class RequiredGeneratorParameterMissing < StandardError
      # Takes the name of the missing parameter.
      def initialize(name)
        super("The required parameter '#{name.to_s.upcase}' is missing for this generator!")
      end
    end
    
  end # Errors
end # Genosaurus