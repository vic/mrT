require 'yaml'
require 'mrT/ui'
require 'mrT/file_select'
require 'mrT/action_select'

module MrT

  @@defaults = {
    :max_depth => 15,
    :max_files => 10_000,
    :scan_dot_directories => false,
    :show_dot_files => false,
    :find_git_root => true,
    :ignore_patterns => []
  }

  def self.config
    unless @config
      config = {}
      config_file = File.expand_path('~/.mrTrc')
      if File.exist?(config_file) &&
          Hash === (cfg = YAML.load_file(config_file))
        cfg.each_pair { |k,v| config[k.to_sym] = v }
      end
      @config = @@defaults.merge(config)
    end
    @config
  end

end

