self: super: {
    ruby = super.ruby.overrideAttrs (_: {
        disallowedRequisites = [];
    });
    neovim = super.neovim.overrideAttrs (_: {
        disallowedReferences = [];
    });
}
