require 'fig/unparser'
require 'fig/unparser/v1_base'
require 'fig/unparser/v2_base'

module Fig; end
module Fig::Unparser; end

# Handles serializing of statements in the v3 grammar.
class Fig::Unparser::V3
  include Fig::Unparser
  include Fig::Unparser::V1Base
  include Fig::Unparser::V2Base

  def initialize(
    emit_as_input_or_to_be_published_values,
    indent_string = ' ' * 2,
    initial_indent_level = 0
  )
    @emit_as_input_or_to_be_published_values =
      emit_as_input_or_to_be_published_values
    @indent_string        = indent_string
    @initial_indent_level = initial_indent_level

    return
  end

  def grammar_version(statement)
    add_indent

    @text << "grammar v3\n"

    return
  end

  def grammar_description()
    return 'v3'
  end
end
