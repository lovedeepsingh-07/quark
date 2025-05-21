{ pkgs, go-pkgs, bun-pkgs, ctx }:

pkgs.mkShell { packages = [ pkgs.just go-pkgs.templ bun-pkgs.bun ctx.go ] ++ ctx.build-deps; }
