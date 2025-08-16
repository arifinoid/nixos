{ icons, ... }: {
  web-devicons = {
    enable = true;
    customIcons = {
      norg = {
        icon = icons.language.org;
        color = "#389EDD";
        cterm_color = "65";
        name = "Norg";
      };
      re = {
        icon = icons.language.reason;
        color = "#DE4B39";
        cterm_color = "65";
        name = "ReasonML";
      };
      dune = {
        icon = icons.language.reason;
        color = "#F5DF36";
        cterm_color = "65";
        name = "Dune";
      };
    };
  };
}
