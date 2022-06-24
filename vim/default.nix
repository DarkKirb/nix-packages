{
  inputs,
  pkgs,
}: {
  copilot-lua = pkgs.vimUtils.buildVimPlugin {
    name = "copilot-lua";
    src = inputs.copilot-lua;
  };
  copilot-cmp = pkgs.vimUtils.buildVimPlugin {
    name = "copilot-cmp";
    src = inputs.copilot-cmp;
  };
}
