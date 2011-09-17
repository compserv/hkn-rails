module Kernel

  # Hook for Kernel.system with sanitized arguments
  def system_with_sanitize(*args)
    safe_args = args.collect { |arg| sanitize_arg(arg) }
    system_without_sanitize(*safe_args)
  end

  alias_method_chain :system, :sanitize

  private

  # Sanitizes an argument
  # - strings have backticks removed
  # - arrays are element-wise sanitized
  # - others are simply pass-thru
  def sanitize_arg(arg)
    case
    when arg.is_a?(String)
      arg.gsub(/`/, '')
    when arg.is_a?(Array)
      arg.collect {|a| sanitize_arg(a)}
    else
      arg
    end
  end
end
