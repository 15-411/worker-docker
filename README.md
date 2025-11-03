DockerHub repo: <https://hub.docker.com/r/cmu411/autograder>

This is the repository containing the Dockerfile for the container where student submissions are autograded. The Dockerfile is responsible for installing all the base software; language-specific software, like the OCaml compiler, is installed in the Dockerfiles in the language-specific repos, like `worker-docker-ocaml`.

This GitHub repository is set to continuously deploy to the `cmu411/autograder` repository on DockerHub. (This setting is managed within the `cmu411/autograder` repository on DockerHub.) When you commit and push to this repository, DockerHub will automatically rebuild the `cmu411/autograder:latest` image so that, when students pull the image, they receive the latest version of the image. Likewise, when the autograding VM pulls the image before starting a job, it will run the student submission on the latest version of the image.

DockerHub is set up to cache layers of the image. (Each subsequent command in the Dockerfile creates a new layer.) Therefore, modifying earlier commands in the Dockerfile invalidates the layer cache for all following commands. If you are installing new software, you should prefer adding the installation commands to the end of the file.

DockerHub will NOT trigger re-builds of downstream images as of July 2019; therefore, if you rebuild the `cmu411/autograder` image by pushing this repo to GitHub, you should manually trigger re-builds of all language-specific Docker images that use this repo as a base image. You can do this by manually triggering the rebuild workflow in the GitHub UI.
