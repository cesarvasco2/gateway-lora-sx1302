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

# Procura a pasta packet_forwarder
echo "Procurando a pasta packet_forwarder..."
packet_forwarder_dir=$(find "$hal_dir" -type d -name "packet_forwarder" 2>/dev/null)

if [ -z "$packet_forwarder_dir" ]; then
  echo "Erro: Diretório packet_forwarder não encontrado." >&2
  # Listar subdiretórios em $hal_dir para depuração
  echo "Conteúdo do diretório $hal_dir:"
  ls -l "$hal_dir"
  exit 1
else
  echo "Diretório packet_forwarder encontrado: $packet_forwarder_dir"
fi

# Navega para o diretório do packet_forwarder
cd "$packet_forwarder_dir" || { echo "Erro: Não foi possível entrar no diretório packet_forwarder."; exit 1; }

# Localiza o arquivo global_conf.json.sx1250.US915
conf_file="$packet_forwarder_dir/global_conf.json.sx1250.US915"

if [ ! -f "$conf_file" ]; then
  echo "Erro: Arquivo $conf_file não encontrado." >&2
  exit 1
fi

# Torna o script reset_lgw.sh executável
chmod +x reset_lgw.sh

# Cria o arquivo global_conf.json com as configurações desejadas
conf_file="global_conf.json"
{
    echo "{"
    echo "    \"SX130x_conf\": {"
    echo "        \"com_type\": \"SPI\","
    echo "        \"com_path\": \"/dev/spidev0.0\","
    echo "        \"lorawan_public\": true,"
    echo "        \"clksrc\": 0,"
    echo "        \"antenna_gain\": 0,"
    echo "        \"full_duplex\": false,"
    echo "        \"fine_timestamp\": {"
    echo "            \"enable\": false,"
    echo "            \"mode\": \"all_sf\""
    echo "        },"
    echo "        \"sx1261_conf\": {"
    echo "            \"spi_path\": \"/dev/spidev0.1\","
    echo "            \"rssi_offset\": 0,"
    echo "            \"spectral_scan\": {"
    echo "                \"enable\": false,"
    echo "                \"freq_start\": 903900000,"
    echo "                \"nb_chan\": 8,"
    echo "                \"nb_scan\": 2000,"
    echo "                \"pace_s\": 10"
    echo "            },"
    echo "            \"lbt\": {"
    echo "                \"enable\": false"
    echo "            }"
    echo "        },"
    echo "        \"radio_0\": {"
    echo "            \"enable\": true,"
    echo "            \"type\": \"SX1250\","
    echo "            \"freq\": 904300000,"
    echo "            \"rssi_offset\": -215.4,"
    echo "            \"rssi_tcomp\": {\"coeff_a\": 0, \"coeff_b\": 0, \"coeff_c\": 20.41, \"coeff_d\": 2162.56, \"coeff_e\": 0},"
    echo "            \"tx_enable\": true,"
    echo "            \"tx_freq_min\": 923000000,"
    echo "            \"tx_freq_max\": 928000000,"
    echo "            \"tx_gain_lut\":["
    echo "                {\"rf_power\": 12, \"pa_gain\": 0, \"pwr_idx\": 15},"
    echo "                {\"rf_power\": 13, \"pa_gain\": 0, \"pwr_idx\": 16},"
    echo "                {\"rf_power\": 14, \"pa_gain\": 0, \"pwr_idx\": 17},"
    echo "                {\"rf_power\": 15, \"pa_gain\": 0, \"pwr_idx\": 19},"
    echo "                {\"rf_power\": 16, \"pa_gain\": 0, \"pwr_idx\": 20},"
    echo "                {\"rf_power\": 17, \"pa_gain\": 0, \"pwr_idx\": 22},"
    echo "                {\"rf_power\": 18, \"pa_gain\": 1, \"pwr_idx\": 1},"
    echo "                {\"rf_power\": 19, \"pa_gain\": 1, \"pwr_idx\": 2},"
    echo "                {\"rf_power\": 20, \"pa_gain\": 1, \"pwr_idx\": 3},"
    echo "                {\"rf_power\": 21, \"pa_gain\": 1, \"pwr_idx\": 4},"
    echo "                {\"rf_power\": 22, \"pa_gain\": 1, \"pwr_idx\": 5},"
    echo "                {\"rf_power\": 23, \"pa_gain\": 1, \"pwr_idx\": 6},"
    echo "                {\"rf_power\": 24, \"pa_gain\": 1, \"pwr_idx\": 7},"
    echo "                {\"rf_power\": 25, \"pa_gain\": 1, \"pwr_idx\": 9},"
    echo "                {\"rf_power\": 26, \"pa_gain\": 1, \"pwr_idx\": 11},"
    echo "                {\"rf_power\": 27, \"pa_gain\": 1, \"pwr_idx\": 14}"
    echo "            ]"
    echo "        },"
    echo "        \"radio_1\": {"
    echo "            \"enable\": true,"
    echo "            \"type\": \"SX1250\","
    echo "            \"freq\": 905000000,"
    echo "            \"rssi_offset\": -215.4,"
    echo "            \"rssi_tcomp\": {\"coeff_a\": 0, \"coeff_b\": 0, \"coeff_c\": 20.41, \"coeff_d\": 2162.56, \"coeff_e\": 0},"
    echo "            \"tx_enable\": false"
    echo "        },"
    echo "        \"chan_multiSF_All\": {\"spreading_factor_enable\": [ 5, 6, 7, 8, 9, 10, 11, 12 ]},"
    echo "        \"chan_multiSF_0\": {\"enable\": true, \"radio\": 0, \"if\": -400000},"
    echo "        \"chan_multiSF_1\": {\"enable\": true, \"radio\": 0, \"if\": -200000},"
    echo "        \"chan_multiSF_2\": {\"enable\": true, \"radio\": 0, \"if\":  0},"
    echo "        \"chan_multiSF_3\": {\"enable\": true, \"radio\": 0, \"if\":  200000},"
    echo "        \"chan_multiSF_4\": {\"enable\": true, \"radio\": 1, \"if\": -300000},"
    echo "        \"chan_multiSF_5\": {\"enable\": true, \"radio\": 1, \"if\": -100000},"
    echo "        \"chan_multiSF_6\": {\"enable\": true, \"radio\": 1, \"if\":  100000},"
    echo "        \"chan_multiSF_7\": {\"enable\": true, \"radio\": 1, \"if\":  300000},"
    echo "        \"chan_Lora_std\":  {\"enable\": true, \"radio\": 0, \"if\":  300000, \"bandwidth\": 500000, \"spread_factor\": 8, \"implicit_hdr\": false, \"implicit_payload_length\": 17, \"implicit_crc_en\": false},"
    echo "        \"chan_FSK\":       {\"enable\": false, \"radio\": 1, \"if\":  300000, \"bandwidth\": 125000, \"datarate\": 50000}"
    echo "    },"
    echo "    \"gateway_conf\": {"
    echo "        \"gateway_ID\": \"$mac_address\","
    echo "        \"server_address\": \"nam1.cloud.thethings.network\","
    echo "        \"serv_port_up\": 1700,"
    echo "        \"serv_port_down\": 1700,"
    echo "        \"keepalive_interval\": 10,"
    echo "        \"stat_interval\": 30,"
    echo "        \"push_timeout_ms\": 100,"
    echo "        \"forward_crc_valid\": true,"
    echo "        \"forward_crc_error\": false,"
    echo "        \"forward_crc_disabled\": false,"
    echo "        \"gps_tty_path\": \"/dev/ttyS0\","
    echo "        \"ref_latitude\": 0.0,"
    echo "        \"ref_longitude\": 0.0,"
    echo "        \"ref_altitude\": 0,"
    echo "        \"beacon_period\": 0,"
    echo "        \"beacon_freq_hz\": 869525000,"
    echo "        \"beacon_datarate\": \"SF7BW125\","
    echo "        \"beacon_power\": 14,"
    echo "        \"beacon_code\": 0,"
    echo "        \"location_code\": 0,"
    echo "        \"forward\": true,"
    echo "        \"datastore\": false"
    echo "    }"
    echo "}"
} > "$conf_file"

# Exibe uma mensagem de sucesso
echo -e "\nO arquivo global_conf.json foi criado com sucesso em $PWD"

# Cria o serviço systemd
echo "Criando o arquivo de serviço systemd..."

# Criação do arquivo de serviço, referenciando o caminho dinâmico
cat <<EOL | sudo tee /etc/systemd/system/lora-pkt-fwd.service
[Unit]
Description=LoRa Packet Forwarder Service - Cesar
After=network.target

[Service]
User=$(whoami)
WorkingDirectory=$packet_forwarder_dir
ExecStart=$packet_forwarder_dir/lora_pkt_fwd
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

# Exibe o MAC Address formatado em verde no final
echo -e "\n\033[32mGATEWAY EUI: $mac_address\033[0m"

echo "Script concluído com sucesso."
