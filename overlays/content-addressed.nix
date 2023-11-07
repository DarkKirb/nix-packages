self: super: {
    ruby = super.ruby.overrideAttrs (_: {
        disallowedReferences = [];
    });
    neovim = super.neovim.overrideAttrs (_: {
        disallowedRequisites = [];
    });
}
