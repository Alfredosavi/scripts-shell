# Script pós-instalação

Script de instalação de programas e configurações para raspberry pi utilizando raspbian como sistema.

## :warning: Script

- Funcionalidades
  - [x] Atualiza (`update`) e instala (`upgrade`) as atualizações antes de iniciar a intalação dos pacotes;
  - [x] Configuração de `name` e `email` do `GIT`;
  - [x] Verifica se o `pacote` já está instalado;
  - [x] Verifica se o `docker` e o `docker-compose` já estão instalados;
  - [x] Ativa a inicialização do `docker`;
  - [x] Verifica se possui `oh-my-zsh` instalado, se tiver é perguntado se deseja reinstalar;
  - [x] Verifica se já possui os plugins `zsh-autosuggestions` e `zsh-syntax-highlighting` antes de instala-lós;
  - [x] Retira a omissão de senha para comandos `sudo`;
  - [x] Finaliza removendo pacotes não necessários (`autoremove`) e limpa o repositório local (`autoclean`);
  - [x] Pergunta se deseja alterar o `shell` padrão para o `zsh`;
  - [x] Pergunta se deseja reinciar a raspberry.
- Pacotes de instalação
  - zsh;
  - ffmpeg;
  - visual studio code;
  - gparted;
  - docker;
  - docker-compose;
  - imagem portainer via docker;
  - oh-my-zsh
  - zsh-autosuggestions plugin;
  - zsh-syntax-highlighting plugin.

## :hammer: Configurações

- Configurações do `GIT`:
  - `GIT_USER_NAME`: Nome de usuário do `GIT`;
  - `GIT_USER_EMAIL`: Email do usuário do `GIT`.
- Configurações da imagem do [PORTAINER](https://www.portainer.io/):
  - `PORTAINER_IMG_LABEL`: Informe a `tag` da imagem para efetuar o download. Para mais informações acesse a [documentação](https://hub.docker.com/r/portainer/portainer/tags) da imagem.
- Configurações `APT`:
  - `INSTALL_PACKAGES`: Lista de bibliotecas para serem instaladas via `APT`;
  - `INSTALL_SOFTS`: Lista de programas para serem instalados via `APT`.

## 🔥 Como usar?

1. Baixe o `script` via git clone ou crie um arquivo e cole o `raw` desse script;
2. Altere as `configurações` do `script`, visto no tópico anteriror;
3. Dê permissão de execução para o script com: `chmod +x nome_do_script`;
4. Execute o `script` com: `./nome_do_script`.
