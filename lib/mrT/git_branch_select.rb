module MrT
  class GitBranchSelect < Selector/'b'
    def items
      `git branch -a`.split.reject { |s| s == "*" || s == "->" || s.strip.empty? }
    end

    action :merge, "Merge into current branch" do |ui, action|
      Kernel.exec 'git', 'merge', action.target
    end

    action :diff, "Diff with current branch" do |ui, action|
      Kernel.exec 'git', 'diff', 'HEAD...'+action.target
    end

    action :checkout, "Checkout this branch" do |ui, action|
      if `git status --porcelain | wc -l`.chomp.to_i == 0
        Kernel.exec 'git', 'checkout', action.target
      else
        puts 'Please, commit your changes or stash them before you can switch branches.'
        exit 1
      end
    end

    action :rebase, "Rebase on top of this branch" do |ui, action|
      Kernel.exec 'git', 'rebase', action.target
    end

  end
end if MrT.git_root
