{ ... }:
{
  vim = {
    theme = {
      enable = true;
      name = "onedark";
      style = "darker";
      transparent = true;
    };

    debugger.nvim-dap = {
      enable = true;
      ui = {
        enable = true;
        autoStart = true;
      };
    };

    utility.multicursors.enable = true;

    statusline.lualine.enable = true;
    telescope.enable = true;
    diagnostics.enable = true;
    autocomplete.nvim-cmp.enable = true;
    lsp = {
      enable = true;
      formatOnSave = true;
      trouble = {
        enable = true;
      }; 
    };
    options = {
      tabstop = 8;
      shiftwidth = 2;
    };

    clipboard = {
      enable = true;
      providers.wl-copy.enable = true;
    };

    filetree.nvimTree = {
      enable = true;
      setupOpts = {
        actions.open_file.quit_on_open = true;
        view = {
          side = "right";
        };
        renderer = {
          icons.webdev_colors = true;
        };
      };
    };

    visuals.nvim-web-devicons.enable = true;

    mini.move.enable = true;

    languages = {
      enableTreesitter = true;
      python = {
        enable = true;
        dap.enable = true;
        format.enable = true;
        lsp.enable = true;
        treesitter.enable = true;
      };
      nix = {
        enable = true;
        lsp.enable = true;
        lsp.servers = [ "nixd" ];
        format.enable = true;
        format.type = [ "nixfmt" ];
        treesitter.enable = true;
      };
      rust = {
        enable = true;
        dap.enable = true;
        extensions.crates-nvim.enable = true;
        format.enable = true;
        lsp.enable = true;
        lsp.opts = ''
          ['rust-analyzer'] = {
            cargo = {allFeature = true},
            checkOnSave = true,
            procMacro = {
              enable = true,
            },
          },
        '';
        treesitter.enable = true;
      };
      markdown = {
        enable = true;
        extensions.markview-nvim.enable = true;
      };
    };
  };
}
