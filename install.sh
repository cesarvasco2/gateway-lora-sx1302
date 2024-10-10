#!/bin/bash

# Verifica se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
  echo "Este script precisa ser executado como root." >&2
  exit 1
fi

# Instala o figlet para gerar arte ASCII
echo "Instalando figlet..."
apt install -y figlet

# Exibe "CESAR" em ASCII
echo ""
figlet "CESAR"
echo ""

# Atualiza a lista de pacotes
echo "Atualizando a lista de pacotes..."
apt update

# Faz o upgrade dos pacotes instalados
echo "Fazendo o upgrade dos pacotes..."
apt upgrade -y

# Instala o Git
echo "Instalando o Git..."
apt install -y git

# Clona o repositório LR1302_loraWAN, se ainda não estiver clonado
if [ ! -d "/home/LR1302_loraWAN" ]; then
  echo "Clonando o repositório LR1302_loraWAN..."
  cd /home
  git clone https://github.com/Elecrow-RD/LR1302_loraWAN.git
else
  echo "Repositório já existe, pulando clonagem."
fi

# Procura o diretório sx1302_hal dinamicamente a partir de /home
echo "Procurando o diretório sx1302_hal..."
hal_dir=$(find /home -type d -name "sx1302_hal" 2>/dev/null)

if [ -z "$hal_dir" ]; then
  echo "Erro: Diretório sx1302_hal não encontrado." >&2
  exit 1
else
  echo "Diretório sx1302_hal encontrado: $hal_dir"
fi

# Move para a pasta correta e compila
echo "Movendo para a pasta $hal_dir e compilando..."
cd "$hal_dir"
make

# Obtém o MAC address da interface eth0
mac_address=$(cat /sys/class/net/eth0/address | tr -d ':')

# Garante que o MAC tenha 16 caracteres
mac_address=$(printf '%016s' "$mac_address" | tr ' ' '0')

# Printa o MAC address ajustado
echo "MAC Address formatado: $mac_address"

# Procura a pasta lora_pkt_fwd
lora_pkt_fwd_dir=$(find "$hal_dir" -type d -name "lora_pkt_fwd" 2>/dev/null)

if [ -z "$lora_pkt_fwd_dir" ]; then
  echo "Erro: Diretório lora_pkt_fwd não encontrado." >&2
  exit 1
else
  echo "Diretório lora_pkt_fwd encontrado: $lora_pkt_fwd_dir"
fi

# Localiza o arquivo global_conf.json.sx1250.US915
conf_file="$lora_pkt_fwd_dir/global_conf.json.sx1250.US915"

if [ ! -f "$conf_file" ]; then
  echo "Erro: Arquivo $conf_file não encontrado." >&2
  exit 1
fi

# Edita o arquivo global_conf.json.sx1250.US915
echo "Editando o arquivo $conf_file..."

# Usa jq para editar o JSON, garantindo que ele esteja no formato correto
sudo apt install -y jq  # Instala o jq se não estiver instalado
jq --arg mac "$mac_address" '.gateway_conf.gateway_ID = $mac |
    .gateway_conf.server_address = "nam1.cloud.thethings.network" |
    .gateway_conf.serv_port_up = 1700 |
    .gateway_conf.serv_port_down = 1700' "$conf_file" > "$conf_file.tmp" && mv "$conf_file.tmp" "$conf_file"

echo "Arquivo $conf_file editado com sucesso."

# Cria o serviço systemd
echo "Criando o arquivo de serviço systemd..."

# Criação do arquivo de serviço, referenciando o caminho dinâmico
cat <<EOL | sudo tee /etc/systemd/system/lora-pkt-fwd.service
[Unit]
Description=LoRa Packet Forwarder Service - Cesar
After=network.target

[Service]
User=$(whoami)
WorkingDirectory=$lora_pkt_fwd_dir
ExecStart=$lora_pkt_fwd_dir/lora_pkt_fwd
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOL

# Recarrega o systemd para reconhecer o novo serviço
echo "Recarregando o systemd..."
sudo systemctl daemon-reload

# Inicia o serviço
echo "Iniciando o serviço lora-pkt-fwd..."
sudo systemctl start lora-pkt-fwd.service

# Habilita o serviço para iniciar automaticamente no boot
echo "Habilitando o serviço lora-pkt-fwd para iniciar no boot..."
sudo systemctl enable lora-pkt-fwd.service

# Remove pacotes desnecessários
echo "Removendo pacotes desnecessários..."
apt autoremove -y

# Limpa arquivos de pacotes
echo "Limpando arquivos de pacotes desnecessários..."
apt clean

echo "Script concluído com sucesso."
