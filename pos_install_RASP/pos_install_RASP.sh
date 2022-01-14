#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

# ----------------------------- VARIÁVEIS ----------------------------- #
# PPA_LIBRATBAG="ppa:libratbag-piper/piper-libratbag-git"
# URL_GOOGLE_CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

GIT_USER_NAME="Alfredo Savi" # Nome de usuário do Git
GIT_USER_EMAIL="alfredosavi@hotmail.com" # Email do usuário do Git

DIRETORIO_DOWNLOADS="$HOME/Downloads/programas"
PORTAINER_IMG_LABEL=":linux-arm" # Label para o container do portainer 
PATH_OH_MY_ZSH="$HOME/.oh-my-zsh" # Diretorio padrão do Oh My Zsh

INSTALL_PACKAGES=( # Lista de pacotes que são pre-requisitos para os programas
  raspberrypi-kernel # Docker
  raspberrypi-kernel-headers # Docker
  libffi-dev # Docker-Compose
  libssl-dev # Docker-Compose
  python3-dev # Docker-Compose
  python3 # Docker-Compose
  python3-pip # Docker-Compose
)

INSTALL_SOFTS=( # Lista de programas que serão instalados
  zsh
  ffmpeg
  code # Visual Studio Code
  gparted
)


function installOhMyZsh() { # Função para instalar o Oh My Zsh
  echo -e "\033[01;32m [INFO]\033[0m Instalando Oh-My-Zsh ..."
  echo y | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

# ----------------------------- REQUISITOS ----------------------------- #
## Removendo travas eventuais do apt ##
sudo rm -f /var/lib/dpkg/lock-frontend
sudo rm -f /var/cache/apt/archives/lock


# ----------------------------- EXECUÇÃO ----------------------------- #
## Atualizando o repositório depois da adição de novos repositórios ##
sudo apt update && sudo apt upgrade -y

## Download e instalaçao de programas externos ##
mkdir -p "$DIRETORIO_DOWNLOADS"
# wget -c "$URL_GOOGLE_CHROME"       -P "$DIRETORIO_DOWNLOADS"


## Instalando pacotes .deb baixados na sessão anterior ##
if find DIRETORIO_DOWNLOADS -mindepth 1 | read; then
  sudo dpkg -i $DIRETORIO_DOWNLOADS/*.deb
else
  echo -e "\033[01;32m [INFO]\033[0m Nenhum pacote .deb foi encontrado ..."
fi


# Instalar pacotes de dependencias via APT
for nome_do_pacote in ${INSTALL_PACKAGES[@]}; do
  if ! dpkg -l | grep -q $nome_do_pacote; then # Só instala se já não estiver instalado
    sudo apt install "$nome_do_pacote" -y
  else
    echo -e "\033[01;32m [INFO]\033[0m $nome_do_pacote [OK]"
  fi
done


# Instalar programas via APT
for nome_do_programa in ${INSTALL_SOFTS[@]}; do
  if ! dpkg -l | grep -q $nome_do_programa; then # Só instala se já não estiver instalado
    sudo apt install "$nome_do_programa" -y
  else
    echo -e "\033[01;32m [INFO]\033[0m $nome_do_programa [OK]"
  fi
done


# ---------------------INSTALANDO DOCKER------------------------ #
if [ -x "$(command -v docker)" ]; then
    echo -e "\033[01;32m [INFO]\033[0m Docker já instalado ..."
else
  curl -sSL https://get.docker.com | sh
  sudo usermod -aG docker pi
  echo -e "\033[01;32m [INFO]\033[0m Docker instalado com sucesso!"
fi


## Instalando o Docker-Compose ##
if [ -x "$(command -v docker-compose)" ]; then
    echo -e "\033[01;32m [INFO]\033[0m Docker Compose já instalado ..."
else
  sudo pip3 install docker-compose
  echo -e "\033[01;32m [INFO]\033[0m Docker Compose instalado com sucesso!"
fi
sudo systemctl enable docker # Start Docker on boot

## Instalando Portainer
if [ "$(sudo docker ps -l | grep portainer)" ]; then
   echo -e "\033[01;32m [INFO]\033[0m Portainer já instalado ..."
else
  sudo docker pull portainer/portainer-ce"$PORTAINER_IMG_LABEL"
  sudo docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
  echo -e "\033[01;32m [INFO]\033[0m Portainer listening on port 9000"
fi


# -----------------CONFIGURANDO ZSH----------------------- #
if [ -e "$PATH_OH_MY_ZSH/oh-my-zsh.sh" ]; then
  read -p "O Oh-My-Zsh já foi instalado, deseja reinstalar? [Y/n] " -e -n 1 ynzsh
  case $ynzsh in
    [Yy]*|"" ) rm -rf $PATH_OH_MY_ZSH; installOhMyZsh ;;
    * ) echo "Abort." ;;
  esac
else
  installOhMyZsh
fi

## Plugins ZSH
cd "$PATH_OH_MY_ZSH/plugins"

if [ -e "zsh-autosuggestions" ]; then
  echo -e "\033[01;32m [INFO]\033[0m zsh-autosuggestions já instalado ..."
else
  git clone https://github.com/zsh-users/zsh-autosuggestions # zsh-autosuggestions

  zsh -c "echo source $PATH_OH_MY_ZSH/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh >> ${ZDOTDIR:-$HOME}/.zshrc"
  zsh -c "source $HOME/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [ -e "zsh-syntax-highlighting" ]; then
  echo -e "\033[01;32m [INFO]\033[0m zsh-syntax-highlighting já instalado ..." 
else
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git # zsh-synstax-highlighting 
 
  zsh -c "echo source $PATH_OH_MY_ZSH/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh >> ${ZDOTDIR:-$HOME}/.zshrc"
  zsh -c "source $HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
# su -s /usr/bin/zsh -c 'command' $USER

# ----------------------RETIRANDO PASSWORD ROOT------------------------ #
sudo rm -f /etc/sudoers.d/010-pi-nopasswd
sudo adduser pi sudo


# ----------------------CONFIGURAÇÕES GIT------------------------ #
git config --global user.name $GIT_USER_NAME
git config --global user.email $GIT_USER_EMAIL

# Finalização, atualização e limpeza##
echo "Atualizando e limpeza..."
sudo apt update && sudo apt dist-upgrade -y
sudo apt autoclean
sudo apt autoremove -y

rm -rf $DIRETORIO_DOWNLOADS # Limpando arquivos baixados que ja não são mais necessários

read -p "Deseja alterar o shell padrão para zsh? [Y/n] " -e -n 1 yn
case $yn in
  [Yy]*|"" ) chsh -s /bin/zsh pi; echo "Done." ;;
  * ) echo -e "Abort."; exit 0 ;;
esac

read -p "Deseja reiniciar agora? [Y/n] " -e -n 1 yn
case $yn in
  [Yy]*|"" ) echo "See you later ..."; sleep 1; sudo reboot ;;
  * ) echo -e "Abort."; exit 0 ;;
esac

echo "Script finalizado com sucesso!"
