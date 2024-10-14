#!/bin/bash

# Verifica se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
  echo "Este script precisa ser executado como root." >&2
  exit 1
fi

# Verifica se o sistema é baseado no Debian antes de usar apt
if ! command -v apt > /dev/null; then
  echo "Este script só suporta sistemas baseados no Debian." >&2
  exit 1
fi

# Função para verificar se o comando foi bem-sucedido
check_command() {
  if [ $? -ne 0 ]; then
    echo "Erro: $1 falhou." >&2
    exit 1
  fi
}

# Instala figlet se não estiver instalado
if ! command -v figlet > /dev/null; then
  echo "Instalando figlet..."
  apt install -y figlet
  check_command "Instalação do figlet"
else
  echo "Figlet já está instalado, pulando."
fi

# Exibe "CESAR" em ASCII
echo ""
figlet "CESAR VASCO"
echo ""

# Atualiza a lista de pacotes
echo "Atualizando a lista de pacotes..."
apt update
check_command "Atualização da lista de pacotes"

# Faz o upgrade dos pacotes instalados
echo "Fazendo o upgrade dos pacotes..."
apt upgrade -y
check_command "Upgrade dos pacotes"

# Instala Git se não estiver instalado
if ! command -v git > /dev/null; then
  echo "Instalando o Git..."
  apt install -y git
  check_command "Instalação do Git"
else
  echo "Git já está instalado, pulando."
fi

# Clona o repositório LR1302_loraWAN, se ainda não estiver clonado
if [ ! -d "/home/LR1302_loraWAN" ]; then
  echo "Clonando o repositório LR1302_loraWAN..."
  git clone https://github.com/Elecrow-RD/LR1302_loraWAN.git /home/LR1302_loraWAN
  check_command "Clonagem do repositório LR1302_loraWAN"
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
cd "$hal_dir" && make
check_command "Compilação do sx1302_hal"

# Obtém o MAC address da interface eth0
mac_address=$(cat /sys/class/net/eth0/address | tr -d ':')

# Verifica se o MAC address foi encontrado corretamente
if [ -z "$mac_address" ]; then
  echo "Erro: Não foi possível obter o MAC address." >&2
  exit 1
fi

# Garante que o MAC tenha 16 caracteres
mac_address=$(printf '%016s' "$mac_address" | tr ' ' '0')

# Printa o MAC address ajustado
echo "MAC Address formatado: $mac_address"

# Procura a pasta packet_forwarder
echo "Procurando a pasta packet_forwarder..."
packet_forwarder_dir=$(find "$hal_dir" -type d -name "packet_forwarder" 2>/dev/null)

if [ -z "$packet_forwarder_dir" ]; then
  echo "Erro: Diretório packet_forwarder não encontrado." >&2
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
cat <<EOL > global_conf.json
{
    "SX130x_conf": {
        "com_type": "SPI",
        "com_path": "/dev/spidev0.0",
        "lorawan_public": true,
        "clksrc": 0,
        "antenna_gain": 0,
        "full_duplex": false,
        "fine_timestamp": {
            "enable": false,
            "mode": "all_sf"
        },
        "sx1261_conf": {
            "spi_path": "/dev/spidev0.1",
            "rssi_offset": 0,
            "spectral_scan": {
                "enable": false,
                "freq_start": 903900000,
                "nb_chan": 8,
                "nb_scan": 2000,
                "pace_s": 10
            },
            "lbt": {
                "enable": false
            }
        },
        "radio_0": {
            "enable": true,
            "type": "SX1250",
            "freq": 904300000,
            "rssi_offset": -215.4,
            "rssi_tcomp": {
                "coeff_a": 0,
                "coeff_b": 0,
                "coeff_c": 20.41,
                "coeff_d": 2162.56,
                "coeff_e": 0
            },
            "tx_enable": true,
            "tx_freq_min": 923000000,
            "tx_freq_max": 928000000,
            "tx_gain_lut": [
                {
                    "rf_power": 12,
                    "pa_gain": 0,
                    "pwr_idx": 15
                },
                {
                    "rf_power": 13,
                    "pa_gain": 0,
                    "pwr_idx": 16
                },
                {
                    "rf_power": 14,
                    "pa_gain": 0,
                    "pwr_idx": 17
                },
                {
                    "rf_power": 15,
                    "pa_gain": 0,
                    "pwr_idx": 19
                },
                {
                    "rf_power": 16,
                    "pa_gain": 0,
                    "pwr_idx": 20
                },
                {
                    "rf_power": 17,
                    "pa_gain": 0,
                    "pwr_idx": 22
                },
                {
                    "rf_power": 18,
                    "pa_gain": 1,
                    "pwr_idx": 1
                },
                {
                    "rf_power": 19,
                    "pa_gain": 1,
                    "pwr_idx": 2
                },
                {
                    "rf_power": 20,
                    "pa_gain": 1,
                    "pwr_idx": 3
                },
                {
                    "rf_power": 21,
                    "pa_gain": 1,
                    "pwr_idx": 4
                },
                {
                    "rf_power": 22,
                    "pa_gain": 1,
                    "pwr_idx": 5
                },
                {
                    "rf_power": 23,
                    "pa_gain": 1,
                    "pwr_idx": 6
                },
                {
                    "rf_power": 24,
                    "pa_gain": 1,
                    "pwr_idx": 7
                },
                {
                    "rf_power": 25,
                    "pa_gain": 1,
                    "pwr_idx": 9
                },
                {
                    "rf_power": 26,
                    "pa_gain": 1,
                    "pwr_idx": 11
                },
                {
                    "rf_power": 27,
                    "pa_gain": 1,
                    "pwr_idx": 14
                }
            ]
        },
        "radio_1": {
            "enable": true,
            "type": "SX1250",
            "freq": 905000000,
            "rssi_offset": -215.4,
            "rssi_tcomp": {
                "coeff_a": 0,
                "coeff_b": 0,
                "coeff_c": 20.41,
                "coeff_d": 2162.56,
                "coeff_e": 0
            },
            "tx_enable": false
        },
        "chan_multiSF_All": {
            "spreading_factor_enable": [
                5,
                6,
                7,
                8,
                9,
                10,
                11,
                12
            ]
        },
        "chan_multiSF_0": {
            "enable": true,
            "radio": 0,
            "if": -400000
        },
        "chan_multiSF_1": {
            "enable": true,
            "radio": 0,
            "if": -200000
        },
        "chan_multiSF_2": {
            "enable": true,
            "radio": 0,
            "if": 0
        },
        "chan_multiSF_3": {
            "enable": true,
            "radio": 0,
            "if": 200000
        },
        "chan_multiSF_4": {
            "enable": true,
            "radio": 1,
            "if": -300000
        },
        "chan_multiSF_5": {
            "enable": true,
            "radio": 1,
            "if": -100000
        },
        "chan_multiSF_6": {
            "enable": true,
            "radio": 1,
            "if": 100000
        },
        "chan_multiSF_7": {
            "enable": true,
            "radio": 1,
            "if": 300000
        },
        "chan_Lora_std": {
            "enable": true,
            "radio": 0,
            "if": 300000,
            "bandwidth": 500000,
            "spread_factor": 8,
            "implicit_hdr": false,
            "implicit_payload_length": 17,
            "implicit_crc_en": false,
            "implicit_coderate": 1
        },
        "chan_FSK": {
            "enable": false,
            "radio": 1,
            "if": 300000,
            "bandwidth": 125000,
            "datarate": 50000
        }
    },
    "gateway_conf": {
        "gateway_ID": "$mac_address",
        "server_address": "nam1.cloud.thethings.network",
        "serv_port_up": 1700,
        "serv_port_down": 1700,
        "keepalive_interval": 10,
        "stat_interval": 30,
        "push_timeout_ms": 100,
        "forward_crc_valid": true,
        "forward_crc_error": false,
        "forward_crc_disabled": false,
        "gps_tty_path": "/dev/ttyS0",
        "ref_latitude": 0,
        "ref_longitude": 0,
        "ref_altitude": 0,
        "beacon_period": 0,
        "beacon_freq_hz": 869525000,
        "beacon_datarate": 9,
        "beacon_bw_hz": 125000,
        "beacon_power": 14,
        "beacon_infodesc": 0
    },
    "debug_conf": {
        "ref_payload": [
            {
                "id": "0xCAFE1234"
            },
            {
                "id": "0xCAFE2345"
            }
        ],
        "log_file": "loragw_hal.log"
    }
}
EOL

check_command "Criação do arquivo global_conf.json"

# Cria o serviço systemd
echo "Criando serviço systemd..."
cat <<EOL > /lib/systemd/system/lora_pkt_fwd.service
[Unit]
Description=LoRa Packet Forwarder - Cesar 
After=multi-user.target

[Service]
User=root
ExecStart=$packet_forwarder_dir/lora_pkt_fwd
Restart=on-failure
WorkingDirectory=$packet_forwarder_dir

[Install]
WantedBy=multi-user.target
EOL

check_command "Criação do serviço systemd"

# Recarrega o daemon do systemd
systemctl daemon-reload
check_command "Recarregamento do systemd"

# Habilita e inicia o serviço
echo "Habilitando e iniciando o serviço lora_pkt_fwd..."
systemctl enable lora_pkt_fwd
check_command "Habilitação do serviço"

systemctl start lora_pkt_fwd
check_command "Início do serviço"

echo "Serviço lora_pkt_fwd iniciado com sucesso."

# Limpa pacotes desnecessários
echo "Limpando pacotes não necessários..."
apt autoremove -y
apt clean
# Exibe o MAC Address formatado em verde no final
echo -e "\n\033[32mGateway EUI: $mac_address\033[0m"
echo "Instalação e configuração concluídas com sucesso!"
