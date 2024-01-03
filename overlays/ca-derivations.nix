self: super: {
    redis = super.redis.overrideAttrs (_: {
        doCheck = false;
    });
}
