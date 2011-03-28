require 'mrT/command-t/filesys_finder'

module MrT
  class DirSelect < Selector/'d'
    def prepared?
      true
    end

    def matcher
      @matcher ||= CommandT::FilesysFinder.new MrT.dir, cmd_t_options
    end

    def cmd_t_options
      keys = [:max_depth, :max_files, :scan_dot_directories]
      opts = Hash[keys.zip(MrT.config.values_at(*keys))]
      # Search only for directories
      opts[:directories] = true
      opts[:files] = false
      opts
    end

    def selected(ui)
      File.expand_path(ui.selected, MrT.dir)
    end

    action "", "Custom shell command" do |ui, action|
      cmd = ui.readline("echo " + action.target + " | xargs ", true, false)
      Kernel.exec "echo '#{action.target}' | xargs #{cmd}"
    end

    action :cd, "Shell into directory" do |ui, action|
      Dir.chdir action.target
      Kernel.exec ENV['SHELL']
    end

    action :rmdir, "Delete directory" do |ui, action|
      require 'fileutils'
      FileUtils.rmdir action.target
      exit 0
    end

    action :rm_rf, "Delete directory recursively" do |ui, action|
      require 'fileutils'
      FileUtils.rm_rf action.target
      exit 0
    end

    action :kfmclient, "Open directory with KDE file manager" do |ui, action|
      Kernel.exec 'kfmclient', 'openURL', action.target
    end

    action :dolphin, "Open directory with KDE Dolphin" do |ui, action|
      Kernel.exec 'dolphin', action.target
    end

    action :konsole, "Open directory with KDE Konsole" do |ui, action|
      Kernel.exec 'konsole', '--workdir', action.target
    end
  end
end
