{
  lib,
  pkgs,
  pstack-skills,
  superpowers-skills,
  matt-pocock-skills,
  ...
}:
let
  readImmediateSkills = source:
    let
      root = "${source}/skills";
      entries = builtins.readDir root;
    in
    builtins.filter
      (name: entries.${name} == "directory" && builtins.pathExists "${root}/${name}/SKILL.md")
      (builtins.attrNames entries);

  readMattSkills = root:
    let
      entries = builtins.readDir root;
      visit = name:
        let
          path = "${root}/${name}";
          kind = entries.${name};
        in
        if kind != "directory" || name == "in-progress" then
          [ ]
        else if builtins.pathExists "${path}/SKILL.md" then
          [ { inherit name path; } ]
        else
          readMattSkills path;
    in
    lib.concatMap visit (builtins.attrNames entries);

  pstackNames = readImmediateSkills pstack-skills;
  superpowersNames = readImmediateSkills superpowers-skills;
  mattSkills = readMattSkills "${matt-pocock-skills}/skills";
  mattSkillsByName = builtins.listToAttrs (map (skill: {
    name = skill.name;
    value = skill.path;
  }) mattSkills);

  # Poteto's tdd and teach keep their original names. Matt's versions are
  # exposed below as matt-tdd and matt-teach.
  sourceByName =
    builtins.listToAttrs (
      map (name: {
        inherit name;
        value = "${pstack-skills}/skills/${name}";
      }) pstackNames
    )
    // builtins.listToAttrs (
      map (name: {
        inherit name;
        value = "${superpowers-skills}/skills/${name}";
      }) superpowersNames
    )
    // builtins.removeAttrs mattSkillsByName [ "tdd" "teach" ];

  skillNames = builtins.attrNames sourceByName ++ [ "matt-tdd" "matt-teach" ];
  skillsTree = pkgs.runCommand "shared-agent-skills" { } ''
    set -eu
    mkdir -p "$out"
    ${lib.concatMapStringsSep "\n" (name: ''
      cp -R "${sourceByName.${name}}" "$out/${name}"
    '') (builtins.attrNames sourceByName)}

    cp -R --no-preserve=mode "${matt-pocock-skills}/skills/engineering/tdd" "$out/matt-tdd"
    sed -i 's/^name: tdd$/name: matt-tdd/' "$out/matt-tdd/SKILL.md"
    cp -R --no-preserve=mode "${matt-pocock-skills}/skills/productivity/teach" "$out/matt-teach"
    sed -i \
      -e 's/^name: teach$/name: matt-teach/' \
      -e 's#/teach#/matt-teach#g' \
      "$out/matt-teach/SKILL.md"
  '';

  homeSkillLinks = builtins.listToAttrs (map (name: {
    name = ".agents/skills/${name}";
    value = {
      source = "${skillsTree}/${name}";
      force = true;
    };
  }) skillNames);
  claudeSkillLinks = builtins.listToAttrs (map (name: {
    name = ".claude/skills/${name}";
    value = {
      source = "${skillsTree}/${name}";
      force = true;
    };
  }) skillNames);
in
{
  home.username = "ash";
  home.homeDirectory = "/home/ash";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  # Agent CLIs installed by their upstream installers live in these directories.
  # Put them on PATH for every shell type, including login shells.
  home.sessionPath = [
    "/home/ash/.local/bin"
    "/home/ash/.local/npm/bin"
    "/home/ash/.opencode/bin"
  ];
  # Note: .local/bin comes before .local/npm/bin so the standalone codex
  # (newer) wins over the stale npm-installed one.

  # Let home-manager manage .bash_profile/.profile/.bashrc so login shells
  # actually load the session PATH (NixOS only reads /etc/profile otherwise).
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      export PATH="/home/ash/.local/bin:/home/ash/.local/npm/bin:/home/ash/.opencode/bin:$PATH"
    '';
  };

  home.file = homeSkillLinks // claudeSkillLinks // {
    ".config/opencode/opencode.jsonc" = {
      text = builtins.toJSON {
        "$schema" = "https://opencode.ai/config.json";
        skills.paths = [ "/home/ash/.agents/skills" ];
      };
      force = true;
    };
  };
}
