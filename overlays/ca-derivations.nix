self: super: {
    redis = super.redis.overrideAttrs (_: {
        doCheck = false;
    });
    openldap = super.openldap.overrideAttrs (_: {
        doCheck = false;
    });
    ruby = super.ruby.overrideAttrs (_: {
        disallowedReferences = [];
    });
    neovim = super.neovim.overrideAttrs (_: {
        disallowedRequisites = [];
    });
}
