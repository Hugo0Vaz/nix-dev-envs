{
  description = "Collection of development environment templates";

  outputs = { self }: {
    templates = {
      default = {
        path = ./default;
        description = "Minimal development environment";
      };

      golang = {
        path = ./golang;
        description = "Go development environment";
      };

      laravel = {
        path = ./laravel;
        description = "Laravel 11 development environment";
      };

      python-jupyter = {
        path = ./python/jupyter;
        description = "Nix-flake-based Jupyter development environment";
      };

      python-vanilla = {
        path = ./python/vanilla;
        description = "Python project with flake-parts + venv + requirements.txt";
      };

      t3app = {
        path = ./t3app;
        description = "Development environment for T3App project";
      };

      visihub = {
        path = ./visihub;
        description = "Visihub development environment - Laravel backend + Expo frontend";
      };

      astro = {
        path = ./astro;
        description = "Astro.js development environment";
      };

      rust = {
        path = ./rust;
        description = "Rust development environment with rust-overlay and extensive tooling";
      };
    };

    defaultTemplate = self.templates.default;
  };
}
