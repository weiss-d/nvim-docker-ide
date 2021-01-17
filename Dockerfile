FROM ubuntu:20.10

# To defeat 'Configuring tzdata' problem (https://techoverflow.net/2019/05/18/how-to-fix-configuring-tzdata-interactive-input-when-building-docker-images/)
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
      && apt-get install -y --no-install-recommends \
# Base software set
        sudo \
        git \
        curl \
        wget \
        less \
        zsh \
        fzf \
        neovim \
        tmux \
        pipx \
        ca-certificates \
        locales \
# Python dev dependencies
        make \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        tk-dev \
        libffi-dev \
        liblzma-dev \
# Needed for ohmyzsh
        bsdmainutils \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
# RUN apt-get remove -y locales

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
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh \
      && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k \
# Installing Tmux themes
      && git clone https://github.com/jimeh/tmux-themepack.git ~/.tmux-themepack \
# Installing asdf and Python
      && git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0 \
      && echo ". $HOME/.asdf/asdf.sh" >> .zshrc \
      && echo ". $HOME/.asdf/asdf.sh" >> .bashrc \
      && source $HOME/.asdf/asdf.sh \
      && asdf plugin add python \
      && asdf install python latest:3.8 \
      && asdf global python $(asdf list python) \
# Installing Vim config
      && git clone git://github.com/rafi/vim-config.git ~/.config/nvim \
      && pip install --user --no-cache-dir pynvim PyYAML \
      && cd ~/.config/nvim \
      && make \
# Installing Poetry
      && curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python - \
# Installing some useful stuff from PyPI
      && pip install --no-cache-dir black isort
      # && pipx install bpytop

WORKDIR /home/me

# RUN curl -sLf https://spacevim.org/install.sh | bash -s -- --install neovim

CMD ["tmux", "-u", "-2"]
