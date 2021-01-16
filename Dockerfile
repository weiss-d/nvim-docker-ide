FROM ubuntu:20.04

# To defeat 'Configuring tzdata' problem (https://techoverflow.net/2019/05/18/how-to-fix-configuring-tzdata-interactive-input-when-building-docker-images/)
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
      && apt-get install -y --no-install-recommends \
        sudo \
        git \
        curl \
        wget \
        zsh \
        fzf \
        neovim \
        tmux \
        python3-pip \
        # needed for ohmyzsh
        bsdmainutils \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*


# Adding a user, and making him available to do sudo w/o password
RUN useradd -ms /bin/zsh me \
      && usermod -aG sudo me \
      && echo "me ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

COPY configs/* /home/me/
ENV HOME /home/me
RUN chown -R me: /home/me

USER me
WORKDIR /home/me

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN wget "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" -O - | zsh \
      && git clone --depth=1 "https://github.com/romkatv/powerlevel10k.git" ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k \
      && git clone "https://github.com/jimeh/tmux-themepack.git" ~/.tmux-themepack

RUN url -sLf https://spacevim.org/install.sh | bash -s -- --install neovim

CMD ["tmux", "-u", "-2"]
