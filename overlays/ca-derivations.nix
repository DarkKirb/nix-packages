self: super: {
    redis = super.redis.overrideAttrs (_: {
        doCheck = false;
    });
    openldap = super.openldap.overrideAttrs (_: {
        doCheck = false;
    });
}
