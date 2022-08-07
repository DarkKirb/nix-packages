{
  inputs,
  pkgs,
}: {
  mautrix-telegram = pkgs.mautrix-telegram.overrideAttrs (old: {
    src = inputs.mautrix-telegram;
  });
}
