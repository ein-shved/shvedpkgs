{
  pkgsOrigin,
  fetchFromGitHub,
}:
pkgsOrigin.lk-jwt-service.overrideAttrs (
  finalAttrs: prevAttrs: {
    version = "0.5.0";
    src = fetchFromGitHub {
      owner = "element-hq";
      repo = "lk-jwt-service";
      tag = "v${finalAttrs.version}";
      hash = "sha256-Lzz4wXk19vCldnaKVCxM9nYlENDLZPKKJvXQhyHDlzo=";
    };
    vendorHash = "sha256-kEC6OXJb9K7sxV0uQGrYLqgnN3Hk+DUV/l7JlBFDdhM=";
  }
)
