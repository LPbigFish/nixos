{
  inputs = {
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  }; 
  outputs = { self, nixvim, nixpkgs, flake-utils }: {
    nixosModules.nvimConfiguration = { pkgs, ... }: {
        imports = [ nixvim.nixosModules.nixvim ];

        programs.nixvim = {
          enable = true;

          plugins = {
            treesitter.enable = true;
            telescope.enable = true;
          };

          extraPlugins = with pkgs.vimPlugins; [
            vim-nix
            onedarkpro-nvim
          ];

          colorscheme = "onedark_dark";

          opts = {
            number = true;
            shiftwidth = 2;
          };
        };
      };
  };
}
