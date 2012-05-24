require 'fig/command'
require 'fig/command/action/role/has_no_sub_action'

module  Fig; end
class   Fig::Command; end
module  Fig::Command::Action; end

class Fig::Command::Action::Version
  include Fig::Command::Action::Role::HasNoSubAction

  def options
    return %w<--version>
  end

  def descriptor_requirement()
    return :ignore
  end

  def need_base_package?()
    return false
  end

  def need_base_config?()
    return false
  end

  def register_base_package?()
    return false
  end

  def apply_base_config?()
    return false
  end

  def execute()
    version = Fig::Command.get_version()
    return 1 if version.nil?

    puts File.basename($0) + ' v' + version

    return 0
  end
end
