{
  inputs = {
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  }; 
  outputs = { self, nixpkgs, nixvim }: {
    nixosModules.nvimConfiguration = { pkgs, ... }: {
        imports = [ nixvim.nixosModules.nixvim ];

        programs.nixvim = {
          enable = true;

          plugins = {
            treesitter.enable = true;
            telescope.enable = true;
            web-devicons.enable = true;
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
