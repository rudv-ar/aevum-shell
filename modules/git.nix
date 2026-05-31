{ ... }:
{
  # setting up a multi git user git configuration in nix. 
  # programs.git makes sure that we have git installed in the nix store
  # additionally, we can also include it in our home.pkgs in home.nix file. 
  programs.git = {
    # enable the git program
    enable = true;
    # git config --global user.name and user.email
    settings = {
      user.name = "rudv-ar";
      user.email = "rudv.ar.base@gmail.com";
      # set default branch for all git inits to be main
      init.defaultBranch = "main";
      # use git merge instead of rebase
      pull.rebase = false;
      # use nvim for commit messages. 
      core.editor = "nvim";
    };

    # additional github accounts if you have any, like work or learning. 
    # include those additional dirs for those specific git account to make sure the name and email are linked. 
    # note the trailing / in the gitdir
    includes = [
      {
        condition = "gitdir:~/Workspace/C/Init87/";
        contents = {
          user.name = "cobra-r9";
          user.email = "cobra.rev.9@gmail.com";
        };
      }
      {
        condition = "gitdir:~/Workspace/C/BSTExp/";
        contents = {
          user.name = "cobra-r9";
          user.email = "cobra.rev.9@gmail.com";
        };
      } 
      # and so on, add other directories and git accounts too...
    ];
  };

  # setup the github via ssh. 
  # nix will install ssh for this purpose, additionally, we can specify it in home.pkgs 
  programs.ssh = {
    # enables ssh in nix
    enable = true;
    enableDefaultConfig = false;

    # match the block in user@<block here>:.... while loggin in via ssh
    matchBlocks = {
      # this one matches git@learn:
      "learn" = {
        # hostname is github.com
        hostname = "github.com";
        # this is the only user github allows while logging in via ssh
        user = "git";
        # ssh key generated and configured via ssh-keygen or github-cli        
        identityFile = "~/.ssh/github_personal";
      };
      # this one is for another identity
      "build" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/github_work";
      };
    };
  };
}
