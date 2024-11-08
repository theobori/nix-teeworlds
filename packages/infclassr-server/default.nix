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
  icu,
  curl,
  libpng,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "infclassr-server";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "infclass";
    repo = "teeworlds-infclassR";
    rev = "v${finalAttrs.version}";
    hash = "sha256-TEWaAXqsltmHnPbvvMpm4RaR0zLxabt4hSpKZnCrZYU=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  nativeCheckInputs = [ gtest ];

  buildInputs = [
    python311
    zlib
    wavpack
    sqlite
    icu
    curl
    libpng
  ];

  postPatch = ''
    substituteInPlace src/engine/shared/storage.cpp \
      --replace-fail /usr/ $out/ \
      --replace-fail /ddnet /infclassr

    rm -rf src/engine/external/zlib
    # TODO: Also remove json-parser and patch the cmake file
  '';

  postInstall = ''
    mkdir -p $out/bin
    mkdir -p $out/share/infclassr

    mv $out/Infclass-Server $out/bin

    rm -rf $out/autoexec.cfg
    rm -rf $out/ChangeLog.txt
    rm -rf $out/storage.cfg.example

    mv $out/data $out/share/infclassr
    mv $out/reset.cfg $out/share/infclassr/data
  '';

  patches = [ ./storage_data_path.patch ];

  meta = {
    description = "Infection Mod with a class system for TeeWorlds";
    homepage = "https://github.com/infclass/teeworlds-infclassR";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ theobori ];
    mainProgram = "Infclass-Server";
    platforms = lib.platforms.unix;
  };
})
