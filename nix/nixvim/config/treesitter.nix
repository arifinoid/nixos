{
  plugins.treesitter = {
    enable = true;
    settings = {
      indent.enable = true;
      textobjects = {
        select = {
          enable = true;
          lookahead = true;
          keymaps = {
            "a=" = {
              query = "@assignment.outer";
              desc = "Select [a]round outer part of an [=] assignment";
            };
            "i=" = {
              query = "@assignment.inner";
              desc = "Select [i]nner part of an [=] assignment";
            };
            "l=" = {
              query = "@assignment.lhs";
              desc = "Select [l]eft hand side of an [=] assignment";
            };
            "r=" = {
              query = "@assignment.rhs";
              desc = "Select [r]ight hand side of an [=] assignment";
            };
            "aa" = {
              query = "@parameter.outer";
              desc = "Select [a]round the outer part of a p[a]rameter";
            };
            "ia" = {
              query = "@parameter.inner";
              desc = "Select the [i]nner part of a p[a]rameter";
            };
            "ai" = {
              query = "@conditional.outer";
              desc = "Select [a]round the outer part of a cond[i]tional";
            };
            "ii" = {
              query = "@conditional.inner";
              desc = "Select the [i]nner part of a cond[i]tional";
            };
            "al" = {
              query = "@loop.outer";
              desc = "Select [a]round the outer part of a [l]oop";
            };
            "il" = {
              query = "@loop.inner";
              desc = "Select the [i]nner part of a [l]oop";
            };
            "af" = {
              query = "@call.outer";
              desc = "Select [a]round the outer part of a function call";
            };
            "if" = {
              query = "@call.inner";
              desc = "Select the [i]nner part of a function call";
            };
            "am" = {
              query = "@function.outer";
              desc = "Select [a]round the outer part of a [m]ethod";
            };
            "im" = {
              query = "@function.inner";
              desc = "Select the [i]nner part of a [m]ethod";
            };
            "ac" = {
              query = "@class.outer";
              desc = "Select [a]round the outer part of a [c]lass";
            };
            "ic" = {
              query = "@class.inner";
              desc = "Select the [i]nner part of a [c]lass";
            };
          };
        };
        move = {
          enable = true;
          set_jumps = true;
          goto_next_start = {
            "]f" = {
              query = "@call.outer";
              desc = "Next [f]unction call start";
            };
            "]m" = {
              query = "@function.outer";
              desc = "Next [m]ethod or function def start";
            };
            "]c" = {
              query = "@class.outer";
              desc = "Next [c]lass start";
            };
            "]i" = {
              query = "@conditional.outer";
              desc = "Next cond[i]tional start";
            };
            "]l" = {
              query = "@loop.outer";
              desc = "Next [l]oop start";
            };
            "]s" = {
              query = "@scope";
              query_group = "locals";
              desc = "Next [s]cope";
            };
            "]z" = {
              query = "@fold";
              query_group = "folds";
              desc = "Next [f]old";
            };
          };

          goto_previous_start = {
            "[f" = {
              query = "@call.outer";
              desc = "Prev [f]unction call start";
            };
            "[m" = {
              query = "@function.outer";
              desc = "Prev [m]ethod or function def start";
            };
            "[c" = {
              query = "@class.outer";
              desc = "Prev [c]lass start";
            };
            "[i" = {
              query = "@conditional.outer";
              desc = "Prev cond[i]tional start";
            };
            "[l" = {
              query = "@loop.outer";
              desc = "Prev [l]oop start";
            };
          };

          goto_next_end = {
            "]F" = {
              query = "@call.outer";
              desc = "Next [F]unction call end";
            };
            "]M" = {
              query = "@function.outer";
              desc = "Next [M]ethod or function def end";
            };
            "]C" = {
              query = "@class.outer";
              desc = "Next [C]lass end";
            };
            "]I" = {
              query = "@conditional.outer";
              desc = "Next cond[I]tional end";
            };
            "]L" = {
              query = "@loop.outer";
              desc = "Next [L]oop end";
            };
          };

          goto_previous_end = {
            "[F" = {
              query = "@call.outer";
              desc = "Prev [F]unction call end";
            };
            "[M" = {
              query = "@function.outer";
              desc = "Prev [M]ethod or function def end";
            };
            "[C" = {
              query = "@class.outer";
              desc = "Prev [C]lass end";
            };
            "[I" = {
              query = "@conditional.outer";
              desc = "Prev cond[I]tional end";
            };
            "[L" = {
              query = "@loop.outer";
              desc = "Prev [L]oop end";
            };
          };
        };
        swap = {
          enable = true;
          swap_next = {
            "@parameter.inner" = "a";
            "@function.outer" = "m";
            "@class.outer" = "c";
          };
          swap_previous = {
            "@parameter.inner" = "A";
            "@function.outer" = "M";
            "@class.outer" = "C";
          };
        };
      };
    };
  };
}
