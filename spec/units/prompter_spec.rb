require 'spec_helper'
require 'gitsh/prompter'

describe Gitsh::Prompter do
  include Color

  describe '#prompt' do
    context 'an un-initialized git repository' do
      it 'displays an uninitialized prompt' do
        repo = git_repo_double(initialized?: false)
        prompter = Gitsh::Prompter.new({}, repo)

        expect(prompter.prompt).to eq "uninitialized#{red_background}!!#{clear} "
      end
    end

    context 'a clean repository' do
      it 'displays the branch name and a clean symbol' do
        repo = git_repo_double(current_head: 'my-feature')
        prompter = Gitsh::Prompter.new({}, repo)

        expect(prompter.prompt).to eq 'my-feature@ '
      end
    end

    context 'a repository with untracked files' do
      it 'displays the branch name and an untracked symbol' do
        repo = git_repo_double(has_untracked_files?: true)
        prompter = Gitsh::Prompter.new({}, repo)

        expect(prompter.prompt).to eq "master#{red}!#{clear} "
      end
    end

    context 'a repository with uncommitted changes' do
      it 'displays the branch name an a modified symbol' do
        repo = git_repo_double(has_modified_files?: true)
        prompter = Gitsh::Prompter.new({}, repo)

        expect(prompter.prompt).to eq "master#{orange}&#{clear} "
      end
    end

    context 'with color disabled' do
      it 'displays the prompt without colors' do
        repo = git_repo_double(has_modified_files?: true)
        prompter = Gitsh::Prompter.new({color: false}, repo)

        expect(prompter.prompt).to eq "master& "
      end
    end

    context 'with a custom prompt format' do
      it 'replaced %# with the prompt terminator' do
        repo = git_repo_double(has_modified_files?: true, format: '%#')
        prompter = Gitsh::Prompter.new({}, repo)

        expect(prompter.prompt).to eq "#{orange}&#{clear} "
      end

      it 'replaces %b with the current HEAD name' do
        repo = git_repo_double(current_head: 'a-branch', format: '%b')
        prompter = Gitsh::Prompter.new({}, repo)

        expect(prompter.prompt).to eq "a-branch "
      end

      it 'replaces %d with the absolute path of the current directory' do
        repo = git_repo_double(format: '%d')
        prompter = Gitsh::Prompter.new({}, repo)

        expect(prompter.prompt).to eq "#{Dir.getwd} "
      end

      it 'replaces %D with the basename of the current directory' do
        repo = git_repo_double(format: '%D')
        prompter = Gitsh::Prompter.new({}, repo)

        expect(prompter.prompt).to eq "#{File.basename(Dir.getwd)} "
      end
    end

    def git_repo_double(attrs={})
      format = attrs.delete(:format)
      default_attrs = {
        initialized?: true,
        has_modified_files?: false,
        has_untracked_files?: false,
        current_head: 'master'
      }
      stub('GitRepository', default_attrs.merge(attrs)) do |repo|
        repo.stubs(:config).with('gitsh.prompt').returns(format)
      end
    end
  end
end
