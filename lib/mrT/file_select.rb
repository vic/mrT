require 'command-t/finder'
require 'mrT/command-t/scanner'

module MrT
  class FileSelect < Selector/'t'
    def prepared?
      true
    end

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
      cmd = ui.readline("echo " + action.target + " | xargs ", true, false)
      Kernel.exec "echo '#{action.target}' | xargs #{cmd}"
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

    action :pager, "Open using #{ENV['PAGER']}" do |ui, action|
      Kernel.exec ENV['PAGER'], action.target
    end if ENV['PAGER']

    action :vi, "Open using Vi" do |ui, action|
      Kernel.exec 'vi', action.target
    end if MrT.bin('vi')

    action :gvim, "Open using GVim" do |ui, action|
      Kernel.exec 'gvim', action.target
    end if MrT.bin('gvim')

    action :emacs, "Open using Emacs" do |ui, action|
      Kernel.exec 'emacs', action.target
    end if MrT.bin('emacs')

    action :kwrite, "Open using KWrite" do |ui, action|
      Kernel.spawn 'kwrite', action.target, :err=>'/dev/null'
      exit 0
    end if MrT.bin('kwrite')

    action :kate, "Open using Kate" do |ui, action|
      Kernel.spawn 'kate', action.target, :err=>'/dev/null'
      exit 0
    end if MrT.bin('kate')

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

    gist = lambda { |file, auth|
      require 'cgi'
      name = File.basename(file)
      ext = File.extname(name)[1..-1]
      content = CGI.escape File.read(file)
      login = `git config github.user`.chomp
      token = `git config github.token`.chomp
      params = [auth && "action_button=private",
                auth && "login=#{login}",
                auth && "token=#{token}",
                "file_ext[gistfile1]=#{ext}",
                "file_name[gistfile1]=#{name}",
                "file_contents[gistfile1]=#{content}"].compact
      xml = `curl -d '#{params.join('&')}' https://gist.github.com/gists`
      /a href=\"(.*?)\"/.match(xml)[1]
    }

    action :gist_public, "Create a public Gist" do |ui, action|
      gist.call(action.target, nil)
    end if MrT.bin('curl')

    action :gist_private, "Create a private Gist" do |ui, action|
      gist.call(action.target, true)
    end if MrT.bin('curl')

    action :chrome, "Open with Google Chrome" do |ui, action|
      Kernel.spawn 'google-chrome', action.target, [:out,:err]=>'/dev/null'
      exit 0
    end if MrT.bin('google-chrome')

    action :firefox, "Open with Firefox" do |ui, action|
      Kernel.spawn 'firefox', action.target, [:out,:err]=>'/dev/null'
      exit 0
    end if MrT.bin('firefox')

    action :konqueror, "Open with Konqueror" do |ui, action|
      Kernel.spawn 'konqueror', action.target, [:out,:err]=>'/dev/null'
      exit 0
    end if MrT.bin('konqueror')

  end
end
