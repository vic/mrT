module MrT
  class FileSelect < Selector/'t'
    def matcher
      @matcher ||= CommandT::Finder.new MrT.dir, cmd_t_options
    end

    def cmd_t_options
      keys = [:max_depth, :max_files, :scan_dot_directories, :show_dot_files]
      opts = Hash[keys.zip(MrT.config.values_at(*keys))]
      opts[:never_show_dot_files] =
          !(opts[:always_show_dot_files] = !!opts.delete(:show_dot_files))
      opts
    end

    def selected(ui)
      File.expand_path(ui.selected, MrT.dir)
    end

    action "", "Custom shell command" do |ui, action|
      cmd = ui.readline("echo "+action.target + " | xargs ")
      system "echo '#{action.target}' | xargs #{cmd}"
      exit 0
    end

    action :rm, "Delete file" do |ui, action|
      require 'fileutils'
      FileUtils.rm action.target
      exit 0
    end

    action :cd, "Shell into containing directory" do |ui, action|
      Kernel.exec ENV['SHELL'], File.dirname(action.target)
    end

    action :edit, "Open using #{ENV['EDITOR']}" do |ui, action|
      Kernel.exec ENV['EDITOR'], action.target
    end if ENV['EDITOR']

    action :vi, "Open using Vi" do |ui, action|
      Kernel.exec 'vi', action.target
    end if MrT.bin('vi')

    action :gvim, "Open using GVim" do |ui, action|
      Kernel.exec 'gvim', action.target
    end if MrT.bin('gvim')

    action :emacs, "Open using Emacs" do |ui, action|
      Kernel.exec 'emacs', action.target
    end if MrT.bin('emacs')

    action :kfmclient, "Open with KDE file manager" do |ui, action|
      Kernel.exec 'kfmclient', 'openURL', action.target
    end if MrT.bin('kfmclient')

    action :dolphin, "Open containing directory with KDE Dolphin" do |ui, action|
      Kernel.exec 'dolphin', File.dirname(action.target)
    end if MrT.bin('dolphin')

    action :konsole, "Open containing directory with KDE Konsole" do |ui, action|
      Kernel.exec 'konsole', '--workdir', File.dirname(action.target)
    end if MrT.bin('konsole')

    action :scp, "Secure shell copy to .." do |ui, action|
      remote = ui.readline('scp '+action.target+' ', false, false)
      Kernel.exec 'scp', action.target, remote
    end if MrT.bin('scp')

    action :zypper_install, "Install with zypper", /\.rpm$/ do |ui, action|
      Kernel.exec 'su', 'zypper', 'install', action.target
    end if MrT.bin('zypper')

  end
end
