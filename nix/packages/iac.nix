{pkgs,...}: {
  home.packages = with pkgs; [
    unstable.opentofu
    ansible
    kubectl
    kubernetes-helm
    runpodctl

    # cloud
    unstable.awscli2 #<- This was annoying and broke all help text
    localstack

  ];
}
