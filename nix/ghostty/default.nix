{...}: {
  # ghostty
  home.file.ghosttyconfig = {
    target = "Library/Application\ Support/com.mitchellh.ghostty/config";
    source = ./config;
  };

}
