{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  python311,
  gtest,
  zlib,
  wavpack,
  sqlite,
  curl,
  libpng,
  rustc,
  cargo,
  rustPlatform,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ddnet-insta-server";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "ddnet-insta";
    repo = "ddnet-insta";
    rev = "v${finalAttrs.version}";
    hash = "sha256-PyJ/jznTFOVXcGCEE/VZAd5nl6w67EeGHmJ70Sx5QAQ=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit (finalAttrs) pname src version;
    hash = "sha256-oSQVvS26nHLiifOcRloiJi1KfJa734Wu0hpDAbHbEHY=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    rustc
    cargo
    rustPlatform.cargoSetupHook
  ];

  nativeCheckInputs = [ gtest ];

  buildInputs = [
    python311
    zlib
    wavpack
    sqlite
    curl
    libpng
  ];

  postPatch = ''
    substituteInPlace src/engine/shared/storage.cpp \
      --replace-fail /usr/ $out/ \
      --replace-fail /ddnet /ddnet-insta

    rm -rf src/engine/external/wavpack
    rm -rf src/engine/external/zlib
  '';

  postInstall = ''
    # Renaming the executable to avoid collisions
    mv $out/bin/DDNet-Server $out/bin/DDNet-Insta-Server

    # Moving the data folder for the same reasons
    mv $out/share/ddnet/ $out/share/ddnet-insta

    rm -rf $out/share/{applications,icons,metainfo}
  '';

  cmakeFlags = [
    "-DCLIENT=OFF"
    "-DTOOLS=OFF"
    "-DSERVER=ON"
  ];

  meta = {
    description = "A teeworlds instagib (grenade/laser capture the flag/death match/catch) mod based on DDRaceNetwork";
    homepage = "https://github.com/ddnet-insta/ddnet-insta/tree/insta";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ theobori ];
    mainProgram = "DDNet-Insta-Server";
    platforms = lib.platforms.unix;
  };
})
