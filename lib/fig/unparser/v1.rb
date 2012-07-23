require 'fig/unparser'

module Fig; end
module Fig::Unparser; end

# Handles serializing of statements in the v1 grammar.
class Fig::Unparser::V1
  def initialize(indent_string = ' ' * 2, initial_indent_level = 0)
    @indent_string        = indent_string
    @initial_indent_level = initial_indent_level

    return
  end

  def command(statement)
    add_indent

    @text << %q<command ">
    @text << statement.command
    @text << %Q<"\n>

    return
  end

  def grammar_version(statement)
    add_indent

    @text << "grammar v1\n"

    return
  end

  private

  def asset(keyword, statement)
    quote = %q<'>
    path  = asset_path statement

    if statement.glob_if_not_url?
      quote = %q<">
      path.gsub!(/\\/, '\\\\')
    end

    add_indent
    @text << keyword
    @text << ' '
    @text << quote
    @text << path
    @text << quote
    @text << "\n"

    return
  end
end
