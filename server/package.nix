{ pkgs, ctx }:

(pkgs.buildGoModule.override { go = ctx.go; }) {
  pname = ctx.package.name;
  version = ctx.package.name;
  src = ctx.package.src;
  goMod = ctx.package.go-mod;
  goSum = ctx.package.go-sum;

  subPackages = [ "." ];
  vendorHash = "sha256-1CqohUAvm2X9NFUOOkKoOq3EBZ5Z9YP2zBq6mEUujuI=";
  proxyVendor = true;

  nativeBuildInputs = [ pkgs.makeWrapper ];
  buildInputs = ctx.build-deps;

  postInstall = ''
    wrapProgram $out/bin/${ctx.package.name} \
      --prefix PATH : ${pkgs.lib.makeBinPath ctx.build-deps}
  '';
}
