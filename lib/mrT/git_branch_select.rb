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

  end
end if MrT.git_root
