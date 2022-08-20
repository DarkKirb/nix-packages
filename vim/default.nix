{
  inputs,
  pkgs,
}: {
  telescope-file-browser-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "telescope-file-browser-nvim";
    src = inputs.nvim-telescope-file-browser;
    # Get nvim's ShaDa file in a writable location
    XDG_DATA_HOME = "/build/tmp";

    # Needed for executing lua scripts
    nativeBuildInputs = with pkgs; [neovim];
  };
}
