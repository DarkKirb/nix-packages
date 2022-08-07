{
  inputs,
  pkgs,
}: {
  mautrix-signal = pkgs.mautrix-signal.overrideAttrs (old: {
    src = inputs.mautrix-signal;
  });
}
