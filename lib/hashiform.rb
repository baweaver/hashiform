class Hashiform
  def initialize(original_hash, catalysts = {})
    @original_hash = original_hash
    @catalysts = catalysts
  end

  def transform(mapping)
    new_hash = {}

    mapping.each do |new_key, transformation|
      *modifiers, path = transformation.split(':')
      path_segments    = path.split('.')

      value = @original_hash.dig(*path_segments)

      if modifiers.empty?
        new_hash[new_key] = value
      else
        value = modifiers.reduce(value) do |new_value, mod|
          new_value = apply_mod(mod, new_value)

          break new_value if new_value == :_reject

          new_value
        end

        new_hash[new_key] = value unless value == :_reject
      end
    end

    new_hash
  end

  def apply_mod(modifier, value)
    return :_reject if modifier =~ /^if/ && value.nil?

    mod, arg_list = modifier.split('+')

    args = if arg_list
      arg_list =~ /^,/ ?
        arg_list :
        arg_list.split(/, ?/)
    end

    case mod
    when sendable(value)
      args ? value.public_send(mod, *args) : value.public_send(mod)
    when catalyst_target?
      @catalysts[mod][value]
    else
      value
    end
  end

  private

  def catalyst_target?
    -> mod { @catalysts.key?(mod) }
  end

  def sendable(value)
    -> meth { value.respond_to?(meth) }
  end
end
