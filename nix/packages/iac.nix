{pkgs,...}: {
  home.packages = with pkgs; [
    opentofu
    stable.ansible
    kubectl
    kubernetes-helm
    runpodctl

    # cloud
    awscli2 #<- This was annoying and broke all help text
    localstack

  ];
}
