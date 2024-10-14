# LoRa Packet Forwarder Setup

Este script foi desenvolvido e testado em um Raspberry Pi 3B+ rodando **Debian Bullseye**. Ele configura o Raspberry Pi para funcionar como um gateway LoRa, instalando e configurando o LoRa Packet Forwarder.

## Requisitos

- Raspberry Pi 3B+ ou compativel
- Sistema operacional **Debian Bullseye** (não testado com **Debian “bookworm”**)
- Conexão com a internet
- HAT e modulo concentrador Elecrow LR1302 LoRaWAN (SPI)

## Instruções de Instalação

### Passo 1: Instalar o Git

Caso o Git ainda não esteja instalado no seu Raspberry Pi, você pode instalá-lo executando o comando abaixo:

```bash
sudo apt update
sudo apt install git -y
```

### Passo 2: Clonar o Repositório

```bash
git clone https://github.com/cesarvasco2/gateway-lora-sx1302.git
```
### Passo 3: Executar o Script de Instalação

```bash
cd gateway-lora-sx1302
sudo chmod +x install.sh
sudo ./install.sh
```

### Passo 4: Verificar o Status do Serviço

```bash
systemctl status lora_pkt_fwd
```
### Personalização do arquivo global_conf.json
- O arquivo de configuração global_conf.json é gerado automaticamente, mas você pode personalizá-lo para se adequar às suas necessidades. Ele está localizado em:

```bash
~/lora_pkt_fwd/lora_gateway/global_conf.json
```
- Edite este arquivo se for necessário alterar a configuração de canais ou outras configurações específicas do gateway.

### Verifique os logs do sistema com:

```bash
journalctl -u lora_pkt_fwd -f
```

- Esse comando permitirá acompanhar o funcionamento do serviço em tempo real.


