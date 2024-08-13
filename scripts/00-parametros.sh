#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 10/10/2021
# Data de atualização: 23/09/2023
# Versão: 1.01
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
#
# Parâmetros (variáveis de ambiente) utilizados nos scripts de instalação dos Serviços de Rede
# no Ubuntu Server 20.04.x LTS, antes de modificar esse arquivo, veja os arquivos: BUGS, NEW e
# CHANGELOG para mais informações.
#
#=============================================================================================
#                    VARIÁVEIS GLOBAIS UTILIZADAS EM TODOS OS SCRIPTS                        #
#=============================================================================================
#
# Declarando as variáveis utilizadas na verificação e validação da versão do Ubuntu Server 
#
# Variável da Hora Inicial do Script, utilizada para calcular o tempo de execução do script
# opção do comando date: +%T (Time)
HORAINICIAL=$(date +%T)
#
# Variáveis para validar o ambiente, verificando se o usuário é "Root" e versão do "Ubuntu"
# opções do comando id: -u (user)
# opções do comando: lsb_release: -r (release), -s (short), 
USUARIO=$(id -u)
UBUNTU=$(lsb_release -rs)
#
# Variável do Caminho e Nome do arquivo de Log utilizado em todos os script
# opção da variável de ambiente $0: Nome do comando/script executado
# opção do redirecionador | (piper): Conecta a saída padrão com a entrada padrão de outro comando
# opções do comando cut: -d (delimiter), -f (fields)
LOGSCRIPT="/var/log/$(echo $0 | cut -d'/' -f2)"
#
# Exportando o recurso de Noninteractive do Debconf para não solicitar telas de configuração e
# nenhuma interação durante a instalação ou atualização do sistema via Apt ou Apt-Get. Ele 
# aceita a resposta padrão para todas as perguntas.
export DEBIAN_FRONTEND="noninteractive"
#
#=============================================================================================
#              VARIÁVEIS DE REDE DO SERVIDOR UTILIZADAS EM TODOS OS SCRIPTS                  #
#=============================================================================================
#
# Declarando as variáveis utilizadas nas configurações de Rede do Servidor Ubuntu 
#
# Variável do Usuário padrão utilizado no Servidor Ubuntu desse curso
USUARIODEFAULT="vaamonde"
#
# Variável da Senha padrão utilizado no Servidor Ubuntu desse curso
# OBSERVAÇÃO IMPORTANTE: essa variável será utilizada em outras variáveis desse curso
SENHADEFAULT="pti@2018"
#
# Variável do Nome (Hostname) do Servidor Ubuntu desse curso
NOMESERVER="ptispo01ws01"
#
# Variável do Nome de Domínio do Servidor Ubuntu desse curso
# OBSERVAÇÃO IMPORTANTE: essa variável será utilizada em outras variáveis desse curso
DOMINIOSERVER="pti.intra"
#
# Variável do Nome de Domínio NetBIOS do Servidor Ubuntu desse curso
# OBSERVAÇÃO IMPORTANTE: essa variável será utilizada em outras variáveis desse curso
# opção do redirecionador | (piper): Conecta a saída padrão com a entrada padrão de outro comando
# opções do comando cut: -d (delimiter), -f (fields)
DOMINIONETBIOS="$(echo $DOMINIOSERVER | cut -d'.' -f1)"
#
# Variável do Nome (Hostname) FQDN (Fully Qualified Domain Name) do Servidor Ubuntu desse curso
# OBSERVAÇÃO IMPORTANTE: essa variável será utilizada em outras variáveis desse curso
FQDNSERVER="$NOMESERVER.$DOMINIOSERVER"
#
# Variável do Endereço IPv4 principal (padrão) do Servidor Ubuntu desse curso
IPV4SERVER="172.16.1.20"
#
# Variável do Nome da Interface Lógica do Servidor Ubuntu Server desse curso
# CUIDADO!!! o nome da interface de rede pode mudar dependendo da instalação do Ubuntu Server,
# verificar o nome da interface com o comando: ip address show e mudar a variável INTERFACE com
# o nome correspondente.
INTERFACE="enp0s3"
#
# Variável do arquivo de configuração da Placa de Rede do Netplan do Servidor Ubuntu
# CUIDADO!!! o nome do arquivo de configuração da placa de rede pode mudar dependendo da 
# versão do Ubuntu Server, verificar o conteúdo do diretório: /etc/netplan para saber o nome 
# do arquivo de configuração do Netplan e mudar a variável NETPLAN com o nome correspondente.
NETPLAN="/etc/netplan/00-installer-config.yaml"
#
#=============================================================================================
#                        VARIÁVEIS UTILIZADAS NO SCRIPT: 01-openssh.sh                       #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço de Rede OpenSSH utilizados nesse script
# 01. /etc/netplan/00-installer-config.yaml = arquivo de configuração da placa de rede
# 02. /etc/hostname = arquivo de configuração do Nome FQDN do Servidor
# 03. /etc/hosts = arquivo de configuração da pesquisa estática para nomes de host local
# 04. /etc/nsswitch.conf = arquivo de configuração do switch de serviço de nomes de serviço
# 05. /etc/ssh/sshd_config = arquivo de configuração do Servidor OpenSSH
# 06. /etc/hosts.allow = arquivo de configuração de liberação de hosts por serviço de rede
# 07. /etc/hosts.deny = arquivo de configuração de negação de hosts por serviço de rede
# 08. /etc/issue.net = arquivo de configuração do Banner utilizado pelo OpenSSH no login
# 09. /etc/default/shellinabox = arquivo de configuração da aplicação Shell-In-a-Box
# 10. /etc/neofetch/config.conf = arquivo de configuração da aplicação Neofetch
# 11. /etc/cron.d/neofetch-cron = arquivo de atualização do Banner Motd o Neofetch
# 12. /etc/motd = arquivo de mensagem do dia gerado pelo Neofetch utilizando o CRON
# 13. /etc/rsyslog.d/50-default.conf = arquivo de configuração do Syslog/Rsyslog
#
# Arquivos de monitoramento (log) do Serviço de Rede OpenSSH Server utilizados nesse script
# 01. sudo systemctl status ssh = status do serviço do OpenSSH
# 02. sudo journalctl -t sshd = todas as mensagens referente ao serviço do OpenSSH
# 03. tail -f /var/log/syslog | grep sshd = filtrando as mensagens do serviço do OpenSSH
# 04. tail -f /var/log/auth.log | grep ssh = filtrando as mensagens de autenticação do OpenSSH
# 05. tail -f /var/log/tcpwrappers-allow-ssh.log = filtrando as conexões permitidas do OpenSSH
# 06. tail -f /var/log/tcpwrappers-deny.log = filtrando as conexões negadas do OpenSSH
# 07. tail -f /var/log/cron.log = filtrando as mensagens do serviço do CRON
#
# Variável das dependências do laço de loop do OpenSSH Server
SSHDEP="openssh-server openssh-client"
#
# Variável de instalação dos softwares extras do OpenSSH Server
SSHINSTALL="net-tools traceroute ipcalc nmap tree pwgen neofetch shellinabox"
#
# Variável da porta de conexão padrão do OpenSSH Server
PORTSSH="22"
#
# Variável da porta de conexão padrão do Shell-In-a-Box
PORTSHELLINABOX="4200"
#
#=============================================================================================
#                          VARIÁVEIS UTILIZADAS NO SCRIPT: 02-dhcp.sh                        #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço de Rede ISC DHCP Sever utilizados nesse script
# 01. /etc/dhcp/dhcpd.conf = arquivo de configuração do Servidor ISC DHCP Server
# 02. /etc/netplan/00-installer-config.yaml = arquivo de configuração da placa de rede
# 03. /etc/default/isc-dhcp-server = arquivo de configuração do serviço do ISC DHCP Server
#
# Arquivos de monitoramento (log) do Serviço de Rede ISC DHCP Server utilizados nesse script
# 01. sudo systemctl status isc-dhcp-server = status do serviço do ISC DHCP
# 02. sudo journalctl -t dhcpd = todas as mensagens referente ao serviço do ISC DHCP
# 03. tail -f /var/log/syslog | grep dhcpd = filtrando as mensagens do serviço do ISC DHCP
# 04. tail -f /var/log/dmesg | grep dhcpd = filtrando as mensagens de erros do ISC DHCP
# 05. less /var/lib/dhcp/dhcpd.leases = filtrando os alugueis de endereços IPv4 do ISC DHCP
# 06. sudo dhcp-lease-list = comando utilizado para mostrar os leases dos endereços IPv4 do ISC DHCP
# 07. sudo tcpdump -vv -n -i enp0s3 port bootps or port bootpc = dump dos pacotes do ISC DHCP
#
# Variável de instalação do serviço de rede ISC DHCP Server
DHCPINSTALL="isc-dhcp-server net-tools"
#
# Variável de download do arquivo do IEEE OUI (Organizationally Unique Identifier)
OUI="https://standards-oui.ieee.org/oui/oui.txt"
#
# Variável da porta de conexão padrão do ISC DHCP Server
PORTDHCP="67"
#
#=============================================================================================
#                          VARIÁVEIS UTILIZADAS NO SCRIPT: 03-dns.sh                         #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço de Rede BIND DNS Server utilizados nesse script
# 01. /etc/hostname = arquivo de configuração do Nome FQDN do Servidor
# 02. /etc/hosts = arquivo de configuração da pesquisa estática para nomes de host local
# 03. /etc/nsswitch.conf = arquivo de configuração do switch de serviço de nomes
# 04. /etc/netplan/00-installer-config.yaml = arquivo de configuração da placa de rede
# 05. /etc/bind/named.conf = arquivo de configuração da localização dos Confs do Bind9
# 06. /etc/bind/named.conf.local = arquivo de configuração das Zonas do Bind9
# 07. /etc/bind/named.conf.options = arquivo de configuração do Serviço do Bind9
# 08. /etc/bind/named.conf.default-zones = arquivo de configuração das Zonas Padrão do Bind9
# 09. /etc/bind/rndc.key = arquivo de configuração das Chaves RNDC de integração Bind9 e DHCP
# 10. /var/lib/bind/pti.intra.hosts = arquivo de configuração da Zona de Pesquisa Direta
# 11. /var/lib/bind/172.16.1.rev = arquivo de configuração da Zona de Pesquisa Reversas
# 12. /etc/default/named = arquivo de configuração do Daemon do Serviço do Bind9
# 13. /etc/cron.d/dnsupdate-cron = arquivo de configuração das atualizações de Ponteiros
# 14. /etc/cron.d/rndcupdate-cron = arquivo de configuração das atualizações das Estatísticas
# 15. /etc/logrotate.d/rndcstats = arquivo de configuração do Logrotate das Estatísticas
#
# Arquivos de monitoramento (log) do Serviço de Rede Bind DNS Server utilizados nesse script
# 01. sudo systemctl status bind9 = status do serviço do Bind DNS
# 02. sudo journalctl -t named = todas as mensagens referente ao serviço do Bind DNS
# 03. tail -f /var/log/syslog | grep named = filtrando as mensagens do serviço do Bind DNS
# 04. tail -f /var/log/named/* = vários arquivos de Log's dos serviços do Bind DNS
# 05. tail -f /var/log/cron.log = filtrando as mensagens do serviço do CRON
#
# Declarando as variáveis de Pesquisa Direta do Domínio, Reversa e Subrede do Bind DNS Server
#
# Variável do nome do Domínio do Servidor DNS (veja a linha: 64 desse arquivo)
DOMAIN=$DOMINIOSERVER
#
# Variável do nome da Pesquisa Reversa do Servidor de DNS
DOMAINREV="1.16.172.in-addr.arpa"
#
# Variável do endereço IPv4 da Subrede do Servidor de DNS
NETWORK="172.16.1."
#
# Variável de instalação do serviço de rede Bind DNS Server
DNSINSTALL="bind9 bind9utils bind9-doc dnsutils net-tools"
#
# Variáveis das portas de conexão padrão do Bind DNS Server
PORTDNS="53"
PORTRNDC="953"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 04-dhcpdns.sh                        #
#=============================================================================================
#
# Arquivos de configuração (conf) da integração do Bind9 e do DHCP utilizados nesse script
# 01. tsig.key - arquivo de geração da chave TSIG de integração do Bind9 e do DHCP
# 02. /etc/dhcp/dhcpd.conf = arquivo de configuração do Servidor ISC DHCP Server
# 03. /etc/bind/named.conf.local = arquivo de configuração das Zonas do Bind9
# 04. /etc/bind/rndc.key = arquivo de configuração das Chaves RNDC de integração Bind9 e DHCP
#
# Arquivos de monitoramento (log) dos Serviços de Rede Bind9 e do DHCP utilizados nesse script
# 01. dhcp-lease-list = comando utilizado para mostrar os leases dos endereços IPv4 do ISC DHCP
# 02. less /var/lib/bind/pti.intra.hosts = arquivo de configuração da Zona de Pesquisa Direta
# 03. less /var/lib/bind/172.16.1.rev = arquivo de configuração da Zona de Pesquisa Reversas
#
# Declarando a variável de geração da chave de atualização dos registros do Bind DNS Server 
# integrado no ISC DHCP Server
# 
# Variável da senha em modo texto que está configurada nos arquivos: dhcpd.conf, named.conf.local
# e rndc.key que será substituída pela nova chave criptografada da variável: USERUPDATE
SECRETUPDATE="vaamonde"
#
# Variável da senha utilizada na criação da chave de atualização dos ponteiros do DNS e DHCP
USERUPDATE="vaamonde"
#
# Variável das dependências do laço de loop da integração do Bind DNS e do ISC DHCP Server
DHCPDNSDEP="isc-dhcp-server bind9"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 05-ntp.sh                            #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço de Rede NTP Server utilizados nesse script
# 01. /etc/ntp.conf = arquivo de configuração do serviço de rede NTP Server
# 02. /etc/default/ntp = arquivo de configuração do Daemon do NTP Server
# 03. /var/lib/ntp/ntp.drift = arquivo de configuração do escorregamento de memória do NTP
# 04. /etc/systemd/timesyncd.conf = arquivo de configuração do sincronismo de Data e Hora
# 05. /etc/dhcp/dhcpd.conf = arquivo de configuração do Servidor ISC DHCP Server
#
# Arquivos de monitoramento (log) do Serviço de Rede NTP Server utilizados nesse script
# 01. sudo systemctl status ntp = status do serviço do NTP Server
# 02. sudo journalctl -t ntpd = todas as mensagens referente ao serviço do NTP Server
# 03. tail -f /var/log/syslog | grep ntpd = vários arquivos de Log's dos serviços do NTP Server
# 04. tail -f /var/log/ntpstats/* = vários arquivos de monitoramento de tempo do NTP Server
#
# Declarando as variáveis utilizadas nas configurações do Serviço do NTP Server e Client
#
# Variável de sincronização do NTP Server com o Site ntp.br
NTPSERVER="a.st1.ntp.br"
#
# Variável do Zona de Horário do Ubuntu Server
TIMEZONE="America/Sao_Paulo"
#
# Variável de Configuração do Locale do Ubuntu Server
LOCALE="pt_BR.UTF-8"
#
# Variável das dependências do laço de loop do NTP Server
NTPDEP="isc-dhcp-server"
#
# Variável de instalação do serviço de rede NTP Server e Client
NTPINSTALL="ntp ntpdate"
#
# Variável da porta de conexão padrão do NTP Server
PORTNTP="123"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 06-tftphpa.sh                        #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço de Rede TFTP-HPA utilizados nesse script
# 01. /etc/default/tftpd-hpa = arquivo de configuração do Servidor TFTP-HPA
# 02. /etc/dhcp/dhcpd.conf = arquivo de configuração do Servidor ISC DHCP Server
# 03. /etc/hosts.allow = arquivo de configuração de liberação de hosts por serviço
# 04. /var/lib/tftpboot/pxelinux.cfg/default = arquivo de configuração do Boot GRUB do PXE
#
# Arquivos de monitoramento (log) do Serviço de Rede TFTP-HPA Server utilizados nesse script
# 01. sudo systemctl status tftpd-hpa = status do serviço do TFTP-HPA
# 02. sudo journalctl -t tftpd-hpa = todas as mensagens referente ao serviço do TFTP-HPA
# 03. tail -f /var/log/syslog | grep tftp = filtrando as mensagens do serviço do TFTP-HPA
# 04. tail -f /var/log/tcpwrappers-allow-tftpd.log = filtrando as conexões permitidas do TFTP-HPA
# 05. tail -f /var/log/tcpwrappers-deny.log = filtrando as conexões negadas do TFTP-HPA
#
# Declarando as variáveis utilizadas nas configurações do Serviço do TFTP-HPA Server
#
# Variável de criação do diretório padrão utilizado pelo serviço do TFTP-HPA
PATHTFTP="/var/lib/tftpboot"
PATHPXE="/usr/lib/PXELINUX"
PATHSYSLINUX="/usr/lib/syslinux"
#
# Variável de download do software de teste de memória Memtest86 (Link atualizado em: 21/08/2022)
MEMTEST86="https://www.memtest.org/download/archives/5.31b/memtest86+-5.31b.bin.gz"
MEMTEST86V9="https://www.memtest86.com/downloads/memtest86-usb.zip"
MEMTEST86V4="https://www.memtest86.com/downloads/memtest86-4.3.7-usb.tar.gz"
#
# Variável das dependências do laço de loop do TFTP-HPA Server
TFTPDEP="bind9 bind9utils isc-dhcp-server"
#
# Variável de instalação do serviço de rede TFTP-HPA Server, Syslinux e PXELinux
TFTPINSTALL="tftpd-hpa tftp-hpa syslinux syslinux-utils syslinux-efi pxelinux initramfs-tools"
#
# Variável da porta de conexão padrão do TFTP-HPA Server
PORTTFTP="69"
#
#=============================================================================================
#                          VARIÁVEIS UTILIZADAS NO SCRIPT: 07-nfs.sh                         #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço de Rede NFS Server utilizados nesse script
# 01. /etc/idmapd.conf = arquivo de configuração da identificação do mapeamento do NFS Server
# 02. /etc/exports = arquivo de configuração da exportação dos compartilhamentos do NFS Server
# 03. /etc/default/nfs-kernel-server = arquivo de configuração do serviço do NFS Server
# 04. /etc/hosts.allow = arquivo de configuração de liberação de hosts por serviço
# 05. /etc/systemd/system/nfs-blkmap.service.d/override.conf = módulo do Kernel do NFS Server
#
# Arquivos de monitoramento (log) do Serviço de Rede NFS Server utilizados nesse script
# 01. sudo systemctl status nfs-kernel-server = status do serviço do NFS Server
# 02. sudo journalctl -t nfs-server-generator = todas as mensagens referente ao serviço do NFS Server
# 03. tail -f /var/log/syslog | grep nfs = filtrando as mensagens do serviço do NFS Server
# 04. tail -f /var/log/tcpwrappers-allow-nfs.log = filtrando as conexões permitidas do NFS Server
# 05. sudo nfsstat -sv = exibe estatísticas mantidas sobre a atividade do cliente e do NFS Server
# 06. sudo nfswatch = monitora todo o tráfego de rede de entrada para um servidor de arquivos NFS Server
# 07. sudo nfstrace = ferramenta de rastreamento/monitoramento/captura/análise de NFS Server e CIFS/SMB
#
# Variável de criação do diretório padrão utilizado pelo serviço do NFS Server
PATHNFS="/mnt/nfs/"
#
# Variável de instalação dos softwares extras do NFS Server
NFSINSTALL="nfs-common nfs-kernel-server nfstrace nfswatch"
#
# Variáveis das portas de conexão padrão do NFS Server
PORTNFSRPC="2049"
PORTNFSPORTMAPPER="111"
#
#=============================================================================================
#                        VARIÁVEIS UTILIZADAS NO SCRIPT: 08-lamp.sh                          #
#=============================================================================================
# 
# Arquivos de configuração (conf) do Serviço de Rede LAMP Server utilizados nesse script
# 01. /etc/apache2/apache2.conf = arquivo de configuração do Servidor Apache2
# 02. /etc/apache2/ports.conf = arquivo de configuração das portas do Servidor Apache2
# 03. /etc/apache2/envvars = arquivo de configuração das variáveis do Servidor Apache2
# 04. /etc/apache2/sites-available/000-default.conf = arquivo de configuração do site padrão HTTP
# 05. /etc/apache2/conf-available/charset.conf = arquivo de configuração do UTF-8 do Apache2
# 06. /etc/php/7.4/apache2/php.ini = arquivo de configuração do PHP
# 07. /etc/mysql/mysql.conf.d/mysqld.cnf = arquivo de configuração do Servidor MySQL
# 08. /etc/hosts.allow = arquivo de configuração de liberação de hosts por serviço
# 09. /var/www/html/phpinfo.php = arquivo de geração da documentação do PHP
# 10. /var/www/html/teste.html = arquivo de teste de páginas HTML
# 11. /etc/awstats/awstats.pti.intra.conf = arquivo de configuração do serviço AWStats
# 12. /etc/cron.d/awstatsupdate-cron = arquivo de atualização das estatísticas do AWStats
#
# Arquivos de monitoramento (log) do Serviço de Rede LAMP Server utilizados nesse script
# 01. sudo systemctl status apache2 = status do serviço do Apache2
# 02. sudo journalctl -t apache2.postinst = todas as mensagens referente ao serviço do Apache2
# 03. tail -f /var/log/apache2/* = vários arquivos de Log's do serviço do Apache2
# 04. sudo systemctl status mysql = status do serviço do Oracle MySQL
# 05. tail -f /var/log/mysql/* = vários arquivos de Log's do serviço do MySQL
# 06. tail -f /var/log/tcpwrappers-allow-mysql.log = filtrando as conexões permitidas do MySQL
# 07. tail -f /var/log/tcpwrappers-deny.log = filtrando as conexões negadas do MySQL
# 08. sudo journalctl -t phpmyadmin = todas as mensagens referente ao serviço do PhpMyAdmin
# 09. tail -f /var/log/cron.log = filtrando as mensagens do serviço do CRON
#
# Declarando as variáveis utilizadas nas configurações dos Serviços do LAMP-Server
#
# Variável do usuário padrão do MySQL (Root do Mysql, diferente do Root do GNU/Linux)
USERMYSQL="root"
#
# Variáveis da senha e confirmação da senha do usuário Root do Mysql 
SENHAMYSQL=$SENHADEFAULT
AGAINMYSQL=$SENHAMYSQL
#
# Variáveis de configuração e liberação da conexão remota para o usuário Root do MySQL
# opções do comando CREATE: create (criar), user (criação de usuário), user@'%' (usuário @ localhost), 
# identified by (identificado por - senha do usuário)
# opções do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou 
# tabela), *.* (todos os bancos/tabelas) to (para), user@'%' (usuário @ localhost), 
# opções do comando ALTER: alter (alterar, user (alteração de usuário), root@localhost (usuário @localhost),
# identified by (identificado por - senha do usuário), with (com suporte)
# opção do comando FLUSH: privileges (recarregar as permissões de privilégios)
CREATEUSER="CREATE USER '$USERMYSQL'@'%' IDENTIFIED BY '$SENHAMYSQL';"
ALTERUSER="ALTER USER '$USERMYSQL'@'localhost' IDENTIFIED WITH mysql_native_password BY '$SENHAMYSQL';"
GRANTALL="GRANT ALL ON *.* TO '$USERMYSQL'@'localhost';"
FLUSH="FLUSH PRIVILEGES;"
SELECTUSER="SELECT user,host FROM user;"
#
# Variável de configuração do usuário padrão de administração do PhpMyAdmin (Root do MySQL)
ADMINUSER=$USERMYSQL
#
# Variáveis da senha do usuário Root do MySQL e senha de administração o PhpMyAdmin
ADMIN_PASS=$SENHAMYSQL
APP_PASSWORD=$SENHAMYSQL
APP_PASS=$SENHAMYSQL
#
# Variável de configuração do serviço de hospedagem de site utilizado pelo PhpMyAdmin
WEBSERVER="apache2"
#
# Variável das dependências do laço de loop do LAMP Server
LAMPDEP="bind9 bind9utils"
#
# Variável de instalação do serviço de rede LAMP Server 
# opção do caractere: ^ (circunflexo): expressão regular referente ao Tasksel, o uso do caractere ^ 
# significa que o que precede é um Metapacote. Ao instalar meta pacotes, vários outros pacotes também 
# serão instalados automaticamente.
# opção do caractere: \ (contra barra): utilizado para quebra de linha em comandos grandes
LAMPINSTALL="lamp-server^ perl python apt-transport-https awstats libgeo-ip-perl libgeo-ipfree-perl \
libnet-ip-perl libgeoip1"
#
# Variável de instalação do serviço de rede PhpMyAdmin
PHPMYADMININSTALL="phpmyadmin php-bcmath php-mbstring php-pear php-dev php-json libmcrypt-dev pwgen"
#
# Variáveis de localização do diretório de Configuração e do Webapp do Tomcat9
PATHAPACHE2="/var/www/html/"
#
# Variáveis das portas de conexão padrão do Apache2 Server
PORTAPACHE="80"
PORTAPACHESSL="443"
#
# Variável da porta de conexão padrão do MySQL Server
PORTMYSQL="3306"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 09-vsftpd.sh                         #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço de Rede VSFTPd utilizados nesse script
# 01. /etc/vsftpd.conf = arquivo de configuração do servidor VSFTPd
# 02. /etc/vsftpd.allowed_users = arquivo de configuração da base de dados de usuários do VSFTPd
# 03. /etc/shells = arquivo de configuração do shells válidos
# 04. /bin/ftponly = arquivo de configuração da mensagem (banner) do VSFTPd
# 05. /etc/rsyslog.d/50-default.conf = arquivo de configuração do Syslog/Rsyslog
# 06. /etc/hosts.allow = arquivo de configuração de liberação de hosts por serviço
#
# Arquivos de monitoramento (log) do Serviço de Rede VSFTPd Server utilizados nesse script
# 01. sudo systemctl status vsftpd = status do serviço do VSFTPd Server
# 02. sudo journalctl -t vsftpd = todas as mensagens referente ao serviço do VSFTPd Server
# 03. tail -f /var/log/vsftpd.log = arquivo de Log's principal do serviço do VSFTPd Server
# 04. tail -f /var/log/syslog | grep vsftpd = filtrando as mensagens do serviço do VSFTPd Server
# 05. tail -f /var/log/tcpwrappers-allow-vsftpd.log = filtrando as conexões permitidas do VSFTPd
#
# Declarando as variáveis utilizadas nas configurações do Serviço do VSFTPd Server
#
# Variável de criação do Grupo dos Usuários de acesso ao VSFTPd Server
GROUPFTP="ftpusers"
#
# Variável de criação do Usuário de acesso ao VSFTPd Server
USERFTP="ftpuser"
#
# Variável da senha do Usuário de VSFTPd Server
PASSWORDFTP=$SENHADEFAULT
#
# Variável das dependências do laço de loop do VSFTPd Server
FTPDEP="bind9 bind9utils apache2 openssl"
#
# Variável de instalação do serviço de rede VSFTPd Server
FTPINSTALL="vsftpd lftp"
#
# Variáveis das portas de conexão padrão do VSFTPd Server
PORTFTPDATA="20"
PORTFTP="21"
PORTFTPSSL="990"
#
#=============================================================================================
#                        VARIÁVEIS UTILIZADAS NO SCRIPT: 10-tomcat.sh                        #
#=============================================================================================
#
# Arquivos de configuração (conf) do Servidor Apache Tomcat utilizados nesse script
# 01. /etc/tomcat9/tomcat-users.xml = arquivo de configuração dos usuários do Tomcat
# 02. /etc/tomcat9/server.xml = arquivo de configuração do servidor Tomcat
#
# Arquivos de monitoramento (log) do Serviço de Rede Tomcat Server utilizados nesse script
# 01. sudo systemctl status tomcat9 = status do serviço do Tomcat Server
# 02. sudo journalctl -t tomcat9 = todas as mensagens referente ao serviço do Tomcat9
# 03. tail -f /var/log/syslog | grep tomcat9 = filtrando as mensagens do serviço do Tomcat9
# 04. tail -f /var/log/tomcat9/* = vários arquivos de Log's do serviço do Tomcat9
#
# Declarando as variáveis utilizadas nas configurações do Serviço do Apache Tomcat9 Server
#
# Variável das dependências do laço de loop do Apache Tomcat9 Server
TOMCATDEP="bind9 bind9utils mysql-server mysql-common apache2 php vsftpd"
#
# Variável de instalação das dependências do Java do Apache Tomcat Server
TOMCATDEPINSTALL="openjdk-11-jdk openjdk-11-jre default-jdk"
#
# Variável de instalação do serviço de rede Apache Tomcat Server
# opção do caractere: \ (contra barra): utilizado para quebra de linha em comandos grandes
TOMCATINSTALL="tomcat9 tomcat9-admin tomcat9-common tomcat9-docs tomcat9-examples tomcat9-user \
libapr1-dev libssl-dev libtcnative-1"
#
# Variáveis de localização do diretório de Configuração e do Webapp do Tomcat9
PATHTOMCAT9="/usr/share/tomcat9/"
PATHWEBAPPS="/var/lib/tomcat9/webapps"
#
# Variáveis das portas de conexão padrão do Apache Tomcat Server
PORTTOMCAT="8080"
PORTTOMCATSSL="8443"
#
# Variável de download da aplicação Agenda de Contatos em Java feita pelo Prof. José de Assis
# Github do projeto: https://github.com/professorjosedeassis/javaEE (Link atualizado em: 11/01/2022)
# YouTUBE do projeto: https://www.youtube.com/playlist?list=PLbEOwbQR9lqz9AnwhrrOLz9cz1-TxoiUg
AGENDAJAVAEE="https://github.com/professorjosedeassis/javaEE/raw/main/agendaVaamonde.war"
#
# Variáveis de criação da Base de Dados da Agenda de Contatos no MySQL
# opções do comando CREATE: create (criação), database (base de dados), base (banco de dados)
# opções do comando CREATE: create (criação), user (usuário), identified by (identificado por
# senha do usuário), password (senha)
# opções do comando GRANT: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/
# tabelas), to (para), user (usuário), identified by (identificado por - senha do usuário), 
# password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou 
# tabela), *.* (todos os bancos/tabelas), to (para), user@'%' (usuário @ localhost), identified 
# by (identificado por - senha do usuário), password (senha)
# opções do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
# opções do domando CREATE: create (criação), table (tabela), colunas da tabela, primary key
# (coluna da chave primária)
#
# OBSERVAÇÃO: NO SCRIPT: 10-TOMCAT.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA
# DO ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 366 até 371, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHAS: 261 até 262
NAME_DATABASE_JAVAEE="dbagenda"
USERNAME_JAVAEE=$NAME_DATABASE_JAVAEE
PASSWORD_JAVAEE=$NAME_DATABASE_JAVAEE
CREATE_DATABASE_JAVAEE="CREATE DATABASE dbagenda;"
CREATE_USER_DATABASE_JAVAEE="CREATE USER 'dbagenda' IDENTIFIED BY 'dbagenda';"
GRANT_DATABASE_JAVAEE="GRANT USAGE ON *.* TO 'dbagenda';"
GRANT_ALL_DATABASE_JAVAEE="GRANT ALL PRIVILEGES ON dbagenda.* TO 'dbagenda';"
FLUSH_JAVAEE="FLUSH PRIVILEGES;"
CREATE_TABLE_JAVAEE="CREATE TABLE contatos (
	idcon int NOT NULL AUTO_INCREMENT,
	nome varchar(50) NOT NULL,
	fone varchar(15) NOT NULL,
	email varchar(50) DEFAULT NULL,
	PRIMARY KEY (idcon)
);"
#
#=============================================================================================
#                     VARIÁVEIS UTILIZADAS NO SCRIPT: 11-A-openssl-ca.sh                     #
#                     VARIÁVEIS UTILIZADAS NO SCRIPT: 11-B-openssl-apache.sh                 #
#                     VARIÁVEIS UTILIZADAS NO SCRIPT: 11-C-openssl-vsftpd.sh                 #
#                     VARIÁVEIS UTILIZADAS NO SCRIPT: 11-D-openssl-tomcat.sh                 #
#                     VARIÁVEIS UTILIZADAS NO SCRIPT: 11-E-openssl-mysql.sh                  #
#                     VARIÁVEIS UTILIZADAS NO SCRIPT: 11-F-openssl-grafana.sh                #
#=============================================================================================
#
# Arquivos de configuração (conf) da Unidade Certificado Raiz Confiável do OpenSSL
# 01. /etc/ssl/index.txt = arquivo de configuração da base de dados do OpenSSL
# 02. /etc/ssl/index.txt.attr = arquivo de configuração dos atributos da base de dados do OpenSSL
# 03. /etc/ssl/serial = arquivo de configuração da geração serial dos certificados
# 04. /etc/ssl/ca.conf = arquivo de configuração de Unidade Certificadora Raiz Confiável da CA
#
# Arquivos de configuração (conf) da Geração do Certificado do Apache2 Server
# 01. /etc/ssl/apache2.conf = arquivo de configuração do certificado do Apache2
# 02. /etc/apache2/sites-available/default-ssl.conf = arquivo de configuração do HTTPS do Apache2
#
# Arquivos de configuração (conf) da Geração do Certificado do VSFTPd Server
# 01. /etc/ssl/vsftpd.conf = arquivo de configuração do certificado do VSFTPd
# 02. /etc/vsftpd.conf = arquivo de configuração do VSFTPd Server
#
# Arquivos de configuração (conf) da Geração do Certificado do Tomcat9 Server
# 01. /etc/ssl/tomcat9.conf = arquivo de configuração do certificado do Tomcat9
# 02. /etc/tomcat9/server.xml = arquivo de configuração do Tomcat9 Server
#
# Arquivos de configuração (conf) da Geração do Certificado do MySQL Server
# 01. /etc/ssl/mysql.conf = arquivo de configuração do certificado do MySQL
# 02. /etc/mysql/mysql.conf.d/mysqld.cnf = arquivo de configuração do MySQL Server
# 03. /etc/mysql/mysql.conf.d/mysql.cnf = arquivo de configuração do MySQL Client
#
# Arquivos de configuração (conf) da Geração do Certificado do Grafana Server
# 01. /etc/ssl/grafana.conf = arquivo de configuração do certificado do Grafana
# 02. /etc/grafana/grafana-server = arquivo de configuração do Grafana Server
#
# Arquivos de monitoramento (log) do Serviço de Certificado OpenSSL utilizados nesse script
# 01. cat /etc/ssl/index.txt = arquivo de configuração da base de dados do OpenSSL
# 02. cat /etc/ssl/index.txt.attr = arquivo de configuração dos atributos da base de dados do OpenSSL
# 03. cat /etc/ssl/serial = arquivo de configuração da geração serial dos certificados
# 04. ls -lh /etc/ssl/ = vários arquivos de configuração dos certificados do OpenSSL
# 05. ls -lh /etc/ssl/certs/pti-ca.pem = unidade certificada raiz confiável do OpenSSL
#
# Variáveis utilizadas na geração das chaves privadas/públicas dos certificados do OpenSSL
#
# Variável da senha utilizada na geração das chaves privadas/públicas da CA e dos certificados
PASSPHRASE="vaamonde"
#
# Variável do tipo de criptografia da chave privada com as opções de: -aes128, -aes192, -aes256, 
# -camellia128, -camellia192, -camellia256, -des, -des3 ou -idea, padrão utilizado: -aes256
CRIPTOKEY="aes256" 
#
# Variável do tamanho da chave privada utilizada em todas as configurações dos certificados,
# opções de: 1024, 2048, 3072 ou 4096, padrão utilizado: 2048
BITS="2048" 
#
# Variável da assinatura da chave de criptografia privada com as opções de: md5, -sha1, sha224, 
# sha256, sha384 ou sha512, padrão utilizado: sha256
CRIPTOCERT="sha256" 
#
# Variável do diretório de download da CA para instalação nos Desktops Windows e GNU/Linux
DOWNLOADCERT="/var/www/html/download/"
#
# Variável das dependências do laço de loop do OpenSSL
SSLDEPCA="openssl bind9 apache2"
#
#=============================================================================================
#                        VARIÁVEIS UTILIZADAS NO SCRIPT: 12-webdav.sh                        #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço de Webdav utilizados nesse script
# 01. /etc/apache2/webdav/users.password = banco de dados de usuários e senhas do Webdav
# 02. /etc/apache2/sites-available/webdav.conf = arquivo do virtual host do Webdav no Apache2
#
# Arquivos de monitoramento (log) do Site do Webdav utilizado nesse script
# 01. tail -f /var/log/apache2/access-webdav.log = log de acesso ao Webdav
# 02. tail -f /var/log/apache2/error-webdav.log = log de erro de acesso ao Webdav
#
# Variável de criação do diretório padrão utilizado pelo serviço do Webdav
PATHWEBDAV="/var/www/webdav/"
#
# Variável de criação do diretório padrão da diretiva do DAVLockDB
PATHDAVLOCK="/var/www/davlockdb"
#
# Variável de criação do diretório padrão do banco de dados do Webdav
PATHWEBDAVUSERS="/etc/apache2/webdav"
#
# Variável das dependências do laço de loop do Webdav
WEBDAVDEP="bind9 apache2 apache2-utils openssl"
#
# Variável do Nome REAL do Grupo de acesso ao Webdav
REALWEBDAV="webdav"
#
# Variável da criação do usuário de acesso ao Webdav
USERWEBDAV=$USUARIODEFAULT
#
# Variável da criação da senha do usuário de acesso ao Webdav
PASSWORDWEBDAV=$SENHADEFAULT
#
#=============================================================================================
#                      VARIÁVEIS UTILIZADAS NO SCRIPT: 13-wordpress.sh                       #
#=============================================================================================
#
# Arquivos de configuração (conf) do Site CMS Wordpress utilizados nesse script
# 01. /var/www/wp/wp-config.php = arquivo de configuração do site Wordpress
# 02. /var/www/wp/.htaccess = arquivo de segurança de páginas e diretórios do Wordpress
# 03. /etc/vsftpd.allowed_users = arquivo de configuração da base de dados de usuários do VSFTPd
# 04. /etc/apache2/sites-available/wordpress.conf = arquivo de configuração do Virtual Host
#
# Arquivos de monitoramento (log) do Site do Wordpress utilizado nesse script
# 01. tail -f /var/log/apache2/access-wordpress.log = log de acesso ao Wordpress
# 02. tail -f /var/log/apache2/error-wordpress.log = log de erro de acesso ao Wordpress
#
# Declarando as variáveis utilizadas nas configurações do Site do Wordpress
#
# Variável de localização da instalação do diretório do Wordpress
PATHWORDPRESS="/var/www/wp"
#
# Variável do download do Wordpress (Link atualizado em: 11/01/2022)
WORDPRESS="https://br.wordpress.org/latest-pt_BR.zip"
#
# Variável do download do Wordpress Salt (Link atualizado em: 11/01/2022)
WORDPRESSSALT="https://api.wordpress.org/secret-key/1.1/salt/"
#
# Declarando as variáveis para criação da Base de Dados do Wordpress
# opções do comando CREATE: create (criação), database (base de dados), base (banco de dados)
# opções do comando CREATE: create (criação), user (usuário), identified by (identificado por
# senha do usuário), password (senha)
# opções do comando GRANT: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/
# tabelas), to (para), user (usuário), identified by (identificado por - senha do usuário), 
# password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou 
# tabela), *.* (todos os bancos/tabelas), to (para), user@'%' (usuário @ localhost), identified 
# by (identificado por - senha do usuário), password (senha)
# opções do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
#
# OBSERVAÇÃO: NO SCRIPT: 13-WORDPRESS.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA
# DO ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 366 até 371, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHAS: 261 até 262
CREATE_DATABASE_WORDPRESS="CREATE DATABASE wordpress;"
CREATE_USER_DATABASE_WORDPRESS="CREATE USER 'wordpress' IDENTIFIED BY 'wordpress';"
GRANT_DATABASE_WORDPRESS="GRANT USAGE ON *.* TO 'wordpress';"
GRANT_ALL_DATABASE_WORDPRES="GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress';"
FLUSH_WORDPRESS="FLUSH PRIVILEGES;"
#
# Variáveis de usuário e senha do FTP para acessar o diretório raiz da instalação do Wordpress
USERFTPWORDPRESS="wordpress"
PASSWORDFTPWORDPRESS=$SENHADEFAULT
#
# Variável da instalação das dependências do Wordpress
# opção do caractere: \ (contra barra): utilizado para quebra de linha em comandos grandes
WORDPRESSDEPINSTALL="unzip ghostscript libapache2-mod-php php-bcmath php-curl php-imagick \
php-intl php-json php-mbstring php-mysql php-xml php-zip php-soap zlibc zlib1g-dev"
#
# Variável das dependências do laço de loop do Wordpress
WORDPRESSDEP="mysql-server mysql-common apache2 php vsftpd bind9 openssl"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 14-webmin.sh                         #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema Webmin e Usermin utilizados nesse script
# 01. /etc/apt/sources.list.d/webmin.list = arquivo de configuração do source list do Apt
#
# Arquivos de monitoramento (log) do Serviço do Webmin e do Usermin utilizados nesse script
# 01. sudo systemctl status webmin = status do serviço do Webmin
# 02. sudo systemctl status usermin = status do serviço do Usermin
# 03. sudo journalctl -t webmin = todas as mensagens referente ao serviço do Webmin
# 04. tail -f /var/webmin/* = vários arquivos de Log's do serviço do Webmin
# 05. tail -f /var/usermin/* = vários arquivos de Log's do serviço do Usermin
#
# Declarando as variáveis utilizadas nas configurações do Webmin e do Usermin
# 
# Variável de download da Chave GPG do Webmin (Link atualizado no dia 30/11/2021)
WEBMINPGP="http://www.webmin.com/jcameron-key.asc"
#
# Variável da instalação das dependências do Webmin e do Usermin
# opção do caractere: \ (contra barra): utilizado para quebra de linha em comandos grandes
WEBMINDEP="perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl \
apt-show-versions python unzip apt-transport-https software-properties-common"
#
# Variável de instalação do serviço de rede Webmin e Usermin
WEBMININSTALL="webmin usermin"
#
# Variáveis das portas de conexão padrão do Webmin e Usermin
PORTWEBMIN="10000"
PORTUSERMIN="20000"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 15-netdata.sh                        #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema Netdata utilizados nesse script
# 01. /usr/lib/netdata/conf.d/python.d/apache.conf = arquivo de monitoramento do Apache2
# 02. /usr/lib/netdata/conf.d/python.d/bind_rndc.conf = arquivo de monitoramento do Bind DNS
# 03. /usr/lib/netdata/conf.d/python.d/docker.conf = arquivo de monitoramento do Docker
# 04. /usr/lib/netdata/conf.d/python.d/elasticsearch.conf = arquivo de monitoramento do ElasticSearch
# 05. /usr/lib/netdata/conf.d/python.d/isc_dhcpd.conf = arquivo de monitoramento do ISC DHCP
# 06. /usr/lib/netdata/conf.d/python.d/mongodb.conf = arquivo de monitoramento do MongoDB
# 07. /usr/lib/netdata/conf.d/python.d/mysql.conf = arquivo de monitoramento do MySQL
# 08. /usr/lib/netdata/conf.d/python.d/redis.conf = arquivo de monitoramento do Redis
# 09. /usr/lib/netdata/conf.d/python.d/tomcat.conf = arquivo de monitoramento do Tomcat
# 10. /etc/netdata/apps_groups.conf = arquivo de configuração dos Aplicativos de Grupos do Netdata
# 11. /etc/netdata/netdata.conf = arquivo de configuração do serviço do Netdata Server
# 12. /etc/apache/sites-available/netdata-ssl.conf = arquivo do Virtual Host do Netdata Server
# 13. /etc/netdata/.htpasswd = arquivo de usuário e senha do Proxy do Apache utilizado no Netdata
#
# Arquivos de monitoramento (log) do Serviço do Netdata utilizados nesse script
# 01. sudo systemctl status netdata = status do serviço do Netdata
# 02. sudo journalctl -t netdata = todas as mensagens referente ao serviço do Netdata
# 03. tail -f /var/log/syslog | grep netdata = filtrando as mensagens do serviço do Netdata
# 04. tail -f /var/log/netdata/* = vários arquivos de Log's do serviço do Netdata
# 05. tail -f /var/log/apache2/netdata-error.log = log de erro de acesso ao Proxy do Netdata
# 06. tail -f /var/log/apache2/netdata-access.log - log de acesso ao Proxy do Netdata
#
# Declarando as variáveis utilizadas nas configurações do sistema de monitoramento Netdata
#
# Variável de download do Netdata (Link atualizado no dia 10/07/2022)
# opção do comando git clone --depth=100: Cria um clone superficial com um histórico truncado 
# para o número especificado de confirmações (somente os últimos commit geral do repositório)
NETDATA="https://github.com/netdata/netdata --depth=100"
#
# Variável das dependências do laço de loop do Netdata
NETDATADEP="mysql-server mysql-common apache2 php vsftpd bind9 isc-dhcp-server ntp"
#
# Variável de instalação das dependências do Netdata
# opção do caractere: \ (contra barra): utilizado para quebra de linha em comandos grandes
NETDATAINSTALL="zlib1g-dev gcc make git autoconf autogen automake pkg-config uuid-dev python3 \
python3-mysqldb python3-pip python3-dev libmysqlclient-dev python-ipaddress libuv1-dev netcat \
libwebsockets15 libwebsockets-dev libjson-c-dev libbpfcc-dev liblz4-dev libjudy-dev libelf-dev \
libmnl-dev autoconf-archive curl cmake protobuf-compiler protobuf-c-compiler lm-sensors \
python3-psycopg2 python3-pymysql"
#
# Variável da porta de conexão padrão do Netdata
PORTNETDATA="19999"
#
# Declarando as variáveis para criação do usuário de monitoramento do Netdata no MySQL
# opções do comando CREATE: create (criação), user (usuário)
# opções do comando GRANT: grant (permissão), usage (uso em | uso na), replication cliente (),
# *.* (todos os bancos/tabelas), to (para), user (usuário)
# opções do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
#
# OBSERVAÇÃO: NO SCRIPT: 15-NETDATA.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA
# DO ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 366 até 371, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHAS: 261 até 262
CREATE_USER_NETDATA="CREATE USER 'netdata'@'localhost';"
GRANT_USAGE_NETDATA="GRANT USAGE, REPLICATION CLIENT ON *.* TO 'netdata'@'localhost';"
FLUSH_NETDATA="FLUSH PRIVILEGES;"
#
#=============================================================================================
#                     VARIÁVEIS UTILIZADAS NO SCRIPT: 16-loganalyzer.sh                      #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema LogAnalyzer utilizados nesse script
# 01. /etc/rsyslog.conf = arquivo de configuração do serviço de rede Rsyslog
# 02. /etc/rsyslog.d/mysql.conf = arquivo de configuração da base de dados do Rsyslog
# 03. /etc/apache2/sites-available/loganalyzer.conf = arquivo de configuração do Virtual host
#
# Arquivos de monitoramento (log) do Serviço do LogAnalyzer utilizados nesse script
# 01. sudo journalctl -t rsyslogd = todas as mensagens referente ao serviço do Rsyslogd
# 02. tail -f /var/log/syslog = todos os Log's de serviços do Rsyslog
# 03. tail -f /var/log/apache2/access-loganalyzer.log = log de acesso ao LogAnalyzer
# 04. tail -f /var/log/apache2/error-loganalyzer.log = log de erro de acesso ao LogAnalyzer
#
# Declarando as variáveis utilizadas nas configurações do sistema de monitoramento LogAnalyzer
#
# Variável de localização da instalação do diretório do LogAnalyzer
PATHLOGANALYZER="/var/www/log"
#
# Variável de download do LogAnalyzer (atualizada no dia: 04/12/2022)
LOGANALYZER="https://download.adiscon.com/loganalyzer/loganalyzer-4.1.13.tar.gz"
#
# Variável de download do Plugin de Tradução PT-BR do LogAnalyzer (atualizada no dia: 02/11/2021)
LOGPTBR="https://loganalyzer.adiscon.com/plugins/files/translations/loganalyzer_lang_pt_BR_3.2.3.zip"
#
# Declarando as variáveis para criação da Base de Dados do Rsyslog
# opções do comando CREATE: create (criação), database (base de dados), base (banco de dados)
# opções do comando CREATE: create (criação), user (usuário), identified by (identificado por
# senha do usuário), password (senha)
# opções do comando GRANT: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/
# tabelas), to (para), user (usuário), identified by (identificado por - senha do usuário), 
# password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou 
# tabela), *.* (todos os bancos/tabelas), to (para), user@'%' (usuário @ localhost), identified 
# by (identificado por - senha do usuário), password (senha)
# opções do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
#
# OBSERVAÇÃO: NO SCRIPT: 14-LOGANALYZER.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA
# DO ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 366 até 371, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHAS: 261 até 262
CREATE_DATABASE_SYSLOG="CREATE DATABASE syslog;"
CREATE_USER_DATABASE_SYSLOG="CREATE USER 'syslog' IDENTIFIED BY 'syslog';"
GRANT_DATABASE_SYSLOG="GRANT USAGE ON *.* TO 'syslog';"
GRANT_ALL_DATABASE_SYSLOG="GRANT ALL PRIVILEGES ON syslog.* TO 'syslog';"
FLUSH_SYSLOG="FLUSH PRIVILEGES;"
DATABASE_NAME_SYSLOG="syslog"
INSTALL_DATABASE_SYSLOG="/usr/share/dbconfig-common/data/rsyslog-mysql/install/mysql"
#
# Declarando as variáveis para criação da Base de Dados do LogAnalyzer
# opções do comando CREATE: create (criação), database (base de dados), base (banco de dados)
# opções do comando CREATE: create (criação), user (usuário), identified by (identificado por
# senha do usuário), password (senha)
# opções do comando GRANT: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/
# tabelas), to (para), user (usuário), identified by (identificado por - senha do usuário), 
# password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou 
# tabela), *.* (todos os bancos/tabelas), to (para), user@'%' (usuário @ localhost), identified 
# by (identificado por - senha do usuário), password (senha)
# opções do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
#
# OBSERVAÇÃO: NO SCRIPT: 16-LOGANALYZER.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA
# DO ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 366 até 371, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHAS: 261 até 262
CREATE_DATABASE_LOGANALYZER="CREATE DATABASE loganalyzer;"
CREATE_USER_DATABASE_LOGANALYZER="CREATE USER 'loganalyzer' IDENTIFIED BY 'loganalyzer';"
GRANT_DATABASE_LOGANALYZER="GRANT USAGE ON *.* TO 'loganalyzer';"
GRANT_ALL_DATABASE_LOGANALYZER="GRANT ALL PRIVILEGES ON loganalyzer.* TO 'loganalyzer';"
FLUSH_LOGANALYZER="FLUSH PRIVILEGES;"
#
# Variável das dependências do laço de loop do LogAnalyzer
LOGDEP="mysql-server mysql-common apache2 php bind9"
#
# Variável de instalação das dependências do LogAnalyzer
LOGINSTALL="rsyslog-mysql"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 17-A-glpi-9.sh                       #
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 17-B-glpi-10.sh                      #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema GLPI Help Desk v9 utilizados nesse script
# 01. /etc/apache2/conf-available/glpi9.conf = arquivo de configuração do GLPI
# 02. /etc/apache2/sites-available/glpi9.conf = arquivo de configuração do Virtual Host do GLPI
# 03. /etc/cron.d/glpi9-cron = arquivo de configuração do agendamento do CRON do GLPI
#
# Arquivos de configuração (conf) do sistema GLPI Help Desk v10 utilizados nesse script
# 01. /etc/apache2/conf-available/glpi10.conf = arquivo de configuração do GLPI
# 02. /etc/apache2/sites-available/glpi10.conf = arquivo de configuração do Virtual Host do GLPI
# 03. /etc/cron.d/glpi10-cron = arquivo de configuração do agendamento do CRON do GLPI
#
# Arquivos de monitoramento (log) do Serviço do GLPI Help Desk utilizados nesse script
# 01. tail -f /var/log/apache2/access-glpi*.log = log de acesso ao GLPI Help Desk
# 02. tail -f /var/log/apache2/error-glpi*.log = log de erro de acesso ao GLPI Help Desk
# 03. tail -f /var/log/syslog | grep -i glpi = filtrando as mensagens do serviço do GLPI Help Desk
# 04. tail -f /var/log/cron.log = filtrando as mensagens do serviço do CRON
#
# Declarando as variáveis utilizadas nas configurações do sistema de Help Desk GLPI
#
# Variável de localização da instalação do diretório do GLPI Help Desk
PATHGLPI9="/var/www/glpi9"
PATHGLPI10="/var/www/glpi10"
#
# Variável de download do GLPI (atualizada no dia: 25/07/2023 - Última versão da série 9.5.13)
GLPI9="https://github.com/glpi-project/glpi/releases/download/9.5.13/glpi-9.5.13.tgz"
GLPI10="https://github.com/glpi-project/glpi/releases/download/10.0.9/glpi-10.0.9.tgz"
#
# Variáveis de download do GLPI Agent (atualizada no dia: 25/07/2023 - Suporte para a versão 10.x)
AGENTGLPIWINDOWS32="https://github.com/glpi-project/glpi-agent/releases/download/1.5/GLPI-Agent-1.5-x86.msi"
AGENTGLPIWINDOWS64="https://github.com/glpi-project/glpi-agent/releases/download/1.5/GLPI-Agent-1.5-x64.msi"
AGENTGLPIMAC="https://github.com/glpi-project/glpi-agent/releases/download/1.5/GLPI-Agent-1.5_x86_64.dmg"
AGENTGLPILINUX="https://github.com/glpi-project/glpi-agent/releases/download/1.5/glpi-agent_1.5-1_all.deb"
AGENTGLPILINUXNETWORK="https://github.com/glpi-project/glpi-agent/releases/download/1.5/glpi-agent-task-network_1.5-1_all.deb"
AGENTGLPILINUXCOLLECT="https://github.com/glpi-project/glpi-agent/releases/download/1.5/glpi-agent-task-collect_1.5-1_all.deb"
AGENTGLPILINUXDEPLOY="https://github.com/glpi-project/glpi-agent/releases/download/1.5/glpi-agent-task-deploy_1.5-1_all.deb"
#
# Variável do diretório de Download dos Agentes e arquivos de configuração do Inventário do GLPI
DOWNLOADAGENTGLPI="/var/www/html/agentesglpi"
#
# Declarando as variáveis para criação da Base de Dados do GLPI
# opções do comando CREATE: create (criação), database (base de dados), base (banco de dados)
# opções do comando CREATE: create (criação), user (usuário), identified by (identificado por
# senha do usuário), password (senha)
# opções do comando GRANT: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/
# tabelas), to (para), user (usuário), identified by (identificado por - senha do usuário), 
# password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou 
# tabela), *.* (todos os bancos/tabelas), to (para), user@'%' (usuário @ localhost), identified 
# by (identificado por - senha do usuário), password (senha)
# opções do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
#
# OBSERVAÇÃO: NO SCRIPT: 17-*-GLPI.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA
# DO ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 366 até 371, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHAS: 261 até 262
CREATE_DATABASE_GLPI9="CREATE DATABASE glpi9;"
CREATE_USER_DATABASE_GLPI9="CREATE USER 'glpi9' IDENTIFIED BY 'glpi9';"
GRANT_DATABASE_GLPI9="GRANT USAGE ON *.* TO 'glpi9';"
GRANT_ALL_DATABASE_GLPI9="GRANT ALL PRIVILEGES ON glpi9.* TO 'glpi9';"
FLUSH_GLPI9="FLUSH PRIVILEGES;"
#
CREATE_DATABASE_GLPI10="CREATE DATABASE glpi10;"
CREATE_USER_DATABASE_GLPI10="CREATE USER 'glpi10' IDENTIFIED BY 'glpi10';"
GRANT_DATABASE_GLPI10="GRANT USAGE ON *.* TO 'glpi10';"
GRANT_ALL_DATABASE_GLPI10="GRANT ALL PRIVILEGES ON glpi10.* TO 'glpi10';"
FLUSH_GLPI10="FLUSH PRIVILEGES;"
#
# Variável das dependências do laço de loop do GLPI Help Desk
GLPIDEP="mysql-server mysql-common apache2 php bind9"
#
# Variável de instalação das dependências do GLPI Help Desk v9.x
# opção do caractere: \ (contra barra): utilizado para quebra de linha em comandos grandes
GLPIINSTALL9="php-curl php-gd php-intl php-pear php-imagick php-imap php-memcache php-pspell \
php-mysql php-tidy php-xmlrpc php-mbstring php-ldap php-cas php-apcu php-json php-xml php-cli \
libapache2-mod-php xmlrpc-api-utils xz-utils bzip2 unzip curl php-soap php-common php-bcmath \
php-zip php-bz2"
#
# Variável de instalação das dependências do GLPI Help Desk v10.x
# opção do caractere: \ (contra barra): utilizado para quebra de linha em comandos grandes
GLPIINSTALL10="php-curl php-gd php-intl php-pear php-imagick php-imap php-memcache php-pspell \
php-mysql php-tidy php-xmlrpc php-mbstring php-ldap php-cas php-apcu php-json php-xml php-cli \
libapache2-mod-php xmlrpc-api-utils xz-utils bzip2 unzip curl php-soap php-common php-bcmath \
php-zip php-bz2"
#
# Variável de instalação das dependências do Agent do GLPI Help Desk v10.x
# opção do caractere: \ (contra barra): utilizado para quebra de linha em comandos grandes
AGENTGLPILINUXINSTALL10="libfile-which-perl liblwp-useragent-determined-perl libnet-ip-perl \
libtext-template-perl libuniversal-require-perl libxml-treepp-perl libcpanel-json-xs-perl \
libcompress-raw-zlib-perl libio-compress-perl libhttp-daemon-perl libio-socket-ssl-perl \
liblwp-protocol-https-perl libproc-daemon-perl libproc-pid-file-perl libnet-cups-perl \
libparse-edid-perl libdatetime-perl libthread-queue-any-perl libnet-nbname-perl libnet-snmp-perl \
libcrypt-des-perl libnet-write-perl libarchive-extract-perl libdigest-sha-perl \
libfile-copy-recursive-perl libjson-pp-perl liburi-escape-xs-perl libnet-ping-external-perl \
libparallel-forkmanager-perl dmidecode lspci hdparm monitor-get-edid-using-vbe monitor-get-edid \
get-edid ssh-keyscan arp 7zip"
#
#=============================================================================================
#                  VARIÁVEIS UTILIZADAS NO SCRIPT: 18-A-fusioninventory-9.sh                 #
#                  VARIÁVEIS UTILIZADAS NO SCRIPT: 18-B-fusioninventory-10.sh                #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema FusionInventory utilizados nesse script
# 01. /etc/fusioninventory/agent.cfg = arquivo de configuração do agent do FusionInventory
#
# Arquivos de monitoramento (log) do Serviço do FusionInventory utilizados nesse script
# 01. sudo systemctl status fusioninventory-agent = status do serviço do FusionInventory Agent
# 02. sudo journalctl -t fusioninventory-agent = todas as mensagens referente ao serviço do FusionInventory
# 03. tail -f /var/log/fusioninventory-agent/fusioninventory.log = arquivo de log do agent do FusionInventory
# 04. tail -f /var/log/syslog | grep -i fusioninventory = filtrando as mensagens do serviço do FusionInventory
#
# Declarando as variáveis utilizadas nas configurações do sistema de inventário FusionInventory
#
# Variável de download do FusionInventory Server e Agent (atualizada no dia: 08/08/2022)
# OBSERVAÇÃO: O FusionInventory depende do GLPI para funcionar corretamente, é recomendado sempre 
# manter o GLPI é o FusionInventory atualizados para as últimas versões compatíveis no site.
FUSIONSERVER="https://github.com/fusioninventory/fusioninventory-for-glpi/releases/download/glpi9.5%2B4.2/fusioninventory-9.5+4.2.tar.bz2"
FUSIONAGENT="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent_2.6-1_all.deb"
FUSIONCOLLECT="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent-task-collect_2.6-1_all.deb"
FUSIONNETWORK="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent-task-network_2.6-1_all.deb"
FUSIONDEPLOY="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent-task-deploy_2.6-1_all.deb"
AGENTWINDOWS32="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent_windows-x86_2.6.exe"
AGENTWINDOWS64="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent_windows-x64_2.6.exe"
AGENTMACOS="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/FusionInventory-Agent-2.6-2.dmg"
#
# Variável das dependências do laço de loop do FusionInventory Server
FUSIONDEP="mysql-server mysql-common apache2 php bind9"
#
# Variável de instalação das dependências do FusionInventory Agent
# opção do caractere: \ (contra barra): utilizado para quebra de linha em comandos grandes
AGENTINSTALL="dmidecode hwdata ucf hdparm perl libuniversal-require-perl libwww-perl \
libparse-edid-perl libproc-daemon-perl libfile-which-perl libhttp-daemon-perl libxml-treepp-perl \
libyaml-perl libnet-cups-perl libnet-ip-perl libdigest-sha-perl libsocket-getaddrinfo-perl \
libtext-template-perl libxml-xpath-perl libyaml-tiny-perl libio-socket-ssl-perl libnet-ssleay-perl \
libcrypt-ssleay-perl"
#
# Variável de instalação das dependências do FusionInventory Task Network
NETWORKINSTALL="libnet-snmp-perl libcrypt-des-perl libnet-nbname-perl"
#
# Variável de instalação das dependências do FusionInventory Task Deploy 
DEPLOYINSTALL="libfile-copy-recursive-perl libparallel-forkmanager-perl"
#
# Variável de instalação das dependências do FusionInventory Task WakeOnLan
WAKEINSTALL="libnet-write-perl libyaml-shell-perl"
#
# Variável de instalação das dependências do FusionInventory SNMPv3
SNMPINSTALL="libdigest-hmac-perl"
#
# Variável do diretório de Download dos Agentes e arquivos de configuração do FusionInventory
DOWNLOADAGENTFS="/var/www/html/agentesfusion"
#
# Variável da porta de conexão padrão do FusionInventory Server
PORTFUSION="62354"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 19-zoneminder.sh                     #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema ZoneMinder utilizados nesse script
# 01. /etc/mysql/mysql.conf.d/mysqld.cnf = arquivo de configuração do Servidor MySQL
# 02. /etc/php/7.4/apache2/php.ini = arquivo de configuração do PHP
#
# Arquivos de monitoramento (log) do Serviço do ZoneMinder utilizados nesse script
# 01. sudo systemctl status zoneminder = status do serviço do ZoneMinder Server
# 02. tail -f /var/log/syslog | grep -i zoneminder = filtrando as mensagens do serviço do ZoneMinder
# 03. tail -f /var/log/zm/* = vários arquivos de Log's do serviço do ZoneMinder
#
# Declarando as variáveis utilizadas nas configurações do sistema de Câmeras ZoneMinder
#
# Variável do PPA (Personal Package Archive) do ZoneMinder (Link atualizado no dia 05/10/2022)
#ZONEMINDER="ppa:iconnor/zoneminder-proposed"   #versões => 1.36.x
ZONEMINDER="ppa:iconnor/zoneminder-master"      #versões => 1.37.x
#
# Declarando as variáveis para criação da Base de Dados do ZoneMinder
# opções do comando GRANT: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/
# tabelas), to (para), user (usuário), identified by (identificado por - senha do usuário), 
# password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou 
# tabela), *.* (todos os bancos/tabelas), to (para), user@'%' (usuário @ localhost), identified 
# by (identificado por - senha do usuário), password (senha)
# opções do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
#
# OBSERVAÇÃO: NO SCRIPT: 15-ZONEMINDER.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA
# DO ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 366 até 371, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHAS: 261 até 262
DROP_DATABASE_ZONEMINDER="DROP DATABASE zm;"
CREATE_TABLE_ZONEMINDER="/usr/share/zoneminder/db/zm_create.sql"
ALTER_USER_DATABASE_ZONEMINDER="ALTER USER 'zmuser'@localhost IDENTIFIED BY 'zmpass';"
GRANT_DATABASE_ZONEMINDER="GRANT USAGE ON *.* TO 'zmuser'@'localhost';"
GRANT_ALL_DATABASE_ZONEMINDER="GRANT ALL PRIVILEGES ON zm.* TO 'zmuser'@'localhost' WITH GRANT OPTION;"
FLUSH_ZONEMINDER="FLUSH PRIVILEGES;"
#
# Variável de instalação do serviço de rede ZoneMinder
ZONEMINDERINSTALL="zoneminder msmtp tzdata gnupg ffmpeg"
#
# Variável das dependências do laço de loop do ZoneMinder
ZONEMINDERDEP="apache2 mysql-server mysql-common software-properties-common php bind9"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 20-guacamole.sh                      #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema Guacamole utilizados nesse script
# 01. /etc/guacamole/guacamole.properties = arquivo de configuração do serviço do Guacamole Server
# 02. /etc/guacamole/user-mapping.xml = arquivo de configuração do usuário e acesso remoto
# 03. /etc/default/tomcat9 = arquivo de configuração do serviço do Apache Tomcat
#
# Arquivos de monitoramento (log) do Serviço do Guacamole utilizados nesse script
# 01. sudo systemctl status tomcat9 = status do serviço do Tomcat Server
# 02. sudo systemctl status guacd = status do serviço do Guacamole Server
# 03. sudo journalctl -t guacd = todas as mensagens referente ao serviço do Guacamole
# 04. tail -f /var/log/syslog | grep -i guacamole = filtrando as mensagens do serviço do Guacamole
# 05. tail -f /var/log/syslog | grep -i guacd = filtrando as mensagens do serviço do Guacamole
#
# Declarando as variáveis utilizadas nas configurações do sistema de acesso remoto Guacamole
#
# Variável de download do Apache Guacamole (Links atualizados no dia 14/09/2023)
GUACAMOLESERVER="https://archive.apache.org/dist/guacamole/1.5.5/source/guacamole-server-1.5.5.tar.gz"
GUACAMOLECLIENT="https://archive.apache.org/dist/guacamole/1.5.5/binary/guacamole-1.5.5.war"
GUACAMOLEJDBC="https://archive.apache.org/dist/guacamole/1.5.5/binary/guacamole-auth-jdbc-1.5.5.tar.gz"
GUACAMOLETOTP="https://archive.apache.org/dist/guacamole/1.5.5/binary/guacamole-auth-totp-1.5.5.tar.gz"
GUACAMOLEHISTORY="https://archive.apache.org/dist/guacamole/1.5.5/binary/guacamole-history-recording-storage-1.5.5.tar.gz"
#
# Variável de download do Conector do MySQL em Java do Apache Guacamole (Link atualizado no dia 14/09/2023)
# Link para pesquisar a versão: https://dev.mysql.com/downloads/connector/j/ 
# Link das versões antigas: https://downloads.mysql.com/archives/c-j/
GUACAMOLEMYSQL="https://cdn.mysql.com//Downloads/Connector-J/mysql-connector-j_8.0.33-1ubuntu20.04_all.deb"
#
# OBSERVAÇÃO: NO SCRIPT: 15-GUACAMOLE.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA
# DO ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 366 até 371, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHAS: 261 até 262
DATABASE_GUACAMOLE="guacamole"
CREATE_DATABASE_GUACAMOLE="CREATE DATABASE guacamole;"
CREATE_USER_DATABASE_GUACAMOLE="CREATE USER 'guacamole' IDENTIFIED BY 'guacamole';"
GRANT_DATABASE_GUACAMOLE="GRANT USAGE ON *.* TO 'guacamole';"
GRANT_ALL_DATABASE_GUACAMOLE="GRANT ALL PRIVILEGES ON guacamole.* TO 'guacamole';"
FLUSH_GUACAMOLE="FLUSH PRIVILEGES;"
#
# Variável das dependências do laço de loop do Guacamole Server e Client
GUACAMOLEDEP="tomcat9 tomcat9-admin tomcat9-user bind9 mysql-server mysql-common"
#
# Variável de instalação das dependências do Guacamole Server
# opção do caractere: \ (contra barra): utilizado para quebra de linha em comandos grandes
GUACAMOLEINSTALL="libcairo2-dev libjpeg-dev libpng-dev libtool-bin libossp-uuid-dev \
libavcodec-dev libavformat-dev libavutil-dev libswscale-dev freerdp2-dev libpango1.0-dev \
libssh2-1-dev libtelnet-dev libvncserver-dev libwebsockets-dev libpulse-dev libssl-dev \
libvorbis-dev libwebp-dev gcc-10 g++-10 make libfreerdp2-2 freerdp2-x11 libjpeg8-dev \
libjpeg-turbo8-dev build-essential"
#
# Variável do usuário de serviço do Guacamole Server
GUACAMOLEUSER="guacd"
GUACAMOLELIB="/var/lib/guacd/"
#
# Variável da porta de conexão padrão do Guacamole Server
PORTGUACAMOLE="4822"
#
#=============================================================================================
#                        VARIÁVEIS UTILIZADAS NO SCRIPT: 21-grafana.sh                       #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema Grafana Server utilizados nesse script
# 01. /etc/default/grafana-server = arquivo de configuração do serviço do Grafana Server
# 02. /etc/default/grafana.ini = arquivo de configuração de inicialização do serviço do Grafana
#
# Arquivos de monitoramento (log) do Serviço do Guacamole utilizados nesse script
# 01. sudo systemctl status grafana-server = status do serviço do Grafana Server
# 02. sudo journalctl -t grafana-server = todas as mensagens referente ao serviço do Grafana Server
# 03. tail -f /var/log/grafana/grafana.log = arquivo de Log do serviço do Grafana Server
# 04. tail -f /var/log/syslog | grep -i grafana = filtrando as mensagens do serviço do Grafana
#
# Declarando as variáveis utilizadas nas configurações do sistema de gráficos Grafana 
#
# Variável da Chave GPG do Repositório do Grafana Server (Links atualizados no dia 09/12/2021)
GRAFANAGPGKEY="https://packages.grafana.com/gpg.key"
GRAFANAAPT="deb https://packages.grafana.com/oss/deb stable main"
#
# Variável das dependências do laço de loop do Grafana Server
GRAFANADEP="mysql-server mysql-common bind9 apt-transport-https software-properties-common"
#
# Variável de instalação do serviço do Grafana Server
GRAFANAINSTALL="grafana"
#
# Variável da porta de conexão padrão do Grafana Server
PORTGRAFANA="3000"
#
#=============================================================================================
#                      VARIÁVEIS UTILIZADAS NO SCRIPT: 22-prometheus.sh                      #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema Prometheus utilizados nesse script
# 01. /etc/prometheus/prometheus.yml = arquivo de configuração do serviço do Prometheus
#
# Arquivos de monitoramento (log) do sistema Prometheus utilizados nesse script
# 01. sudo systemctl status prometheus = status do serviço do Prometheus 
# 02. sudo journalctl -u prometheus -f --no-pager = todas as mensagens de Log do Prometheus
#
# Declarando as variáveis utilizadas nas configurações do sistema de Prometheus
#
# Link de download do Projeto do Prometheus (Link atualizado no dia 14/09/2023)
PROMETHEUS="https://github.com/prometheus/prometheus/releases/download/v2.47.0/prometheus-2.47.0.linux-amd64.tar.gz"
#
# Variável das dependências do laço de loop do Prometheus
PROMETHEUSDEP="bind9 grafana"
#
# Variável da porta do Prometheus
PORTPROMETHEUS="9091"
#
# Variáveis de criação do Grupo e Usuário de Sistema do Prometheus
GROUPPROMETHEUS="prometheus"
USERPROMETHEUS="prometheus"
#
#=============================================================================================
#                         VARIÁVEIS UTILIZADAS NO SCRIPT: 23-zabbix.sh                       #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema Zabbix Server utilizados nesse script
# 01. /etc/zabbix/zabbix_server.conf = arquivo de configuração do serviço do Zabbix Server
# 02. /etc/zabbix/apache.conf = arquivo de configuração do Virtual host e PHP do Zabbix Server
# 03. /etc/zabbix/zabbix_agentd.conf = arquivo de configuração do serviço do Zabbix Agent
#
# Arquivos de monitoramento (log) do Serviço do Zabbix Server utilizados nesse script
# 01. sudo systemctl status zabbix-server = status do serviço do Zabbix Server
# 02. sudo systemctl status zabbix-agent = status do serviço do Zabbix Agent
# 03. tail -f /var/log/zabbix/zabbix_server.log = arquivo de Log do serviço do Zabbix Server
# 04. tail -f /var/log/zabbix/zabbix_agentd.log = arquivo de Log do serviço do Zabbix Agent
# 05. tail -f /var/log/syslog | grep -i zabbix = filtrando as mensagens do serviço do Zabbix
#
# Declarando as variáveis utilizadas nas configurações do sistema de monitoramento Zabbix Server
#
# Variável de download do Repositório do Zabbix Server (Link atualizado no dia 25/01/2023)
ZABBIXIREP="wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu20.04_all.deb"
#
# Variável de instalação do Zabbix Server e suas Dependências.
ZABBIXINSTALL="install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-agent \
zabbix-sql-scripts traceroute nmap snmp snmpd snmp-mibs-downloader"
#
# Declarando as variáveis para criação da Base de Dados do Zabbix Server
# opção do comando create: create (criação), database (base de dados), base (banco de dados), 
# character set (conjunto de caracteres), collate (comparar)
# opção do comando create: create (criação), user (usuário), identified by (identificado por - 
# senha do usuário), password (senha)
# opção do comando grant: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/tabelas),
# to (para), user (usuário), identified by (identificado por - senha do usuário), password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou tabela), 
# *.* (todos os bancos/tabelas) to (para), user@'%' (usuário @ localhost), identified by (identificado 
# por - senha do usuário), password (senha)
# opção do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
#
# OBSERVAÇÃO: NO SCRIPT: 20-ZABBIX.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA
# DO ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 366 até 371, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHAS: 261 até 262
CREATE_DATABASE_ZABBIX="CREATE DATABASE zabbix CHARACTER SET utf8mb4 collate utf8mb4_bin;"
CREATE_USER_DATABASE_ZABBIX="CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'zabbix';"
GRANT_DATABASE_ZABBIX="GRANT USAGE ON *.* TO 'zabbix'@'localhost';"
GRANT_ALL_DATABASE_ZABBIX="GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';"
SET_GLOBAL_ZABBIX="SET GLOBAL log_bin_trust_function_creators = 1;"
FLUSH_ZABBIX="FLUSH PRIVILEGES;"
CREATE_TABLE_ZABBIX="/usr/share/zabbix-sql-scripts/mysql/server.sql.gz"
#
# Variável das dependências do laço de loop do Zabbix Server
ZABBIXDEP="mysql-server mysql-common apache2 php bind9 apt-transport-https software-properties-common"
#
# Variáveis das portas de conexão padrão do Zabbix Server e Agent
PORTZABBIX1="10050"
PORTZABBIX2="10051"
#
#=============================================================================================
#                         VARIÁVEIS UTILIZADAS NO SCRIPT: 24-docker.sh                       #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema Docker e do Portainer utilizados nesse script
# 01. /etc/systemd/system/portainer.service = arquivo de configuração do serviço do Portainer
#
# Arquivos de monitoramento (log) do Serviço do Docker e do Portainer utilizados nesse script
# 01. sudo systemctl status docker = status do serviço do Docker Server
# 02. sudo systemctl status portainer = status do serviço do Portainer
# 03. sudo journalctl -t docker = todas as mensagens referente ao serviço do Docker
# 04. tail -f /var/log/syslog | grep -i docker = filtrando as mensagens do serviço do Docker
# 05. tail -f /var/log/syslog | grep -i portainer = filtrando as mensagens do serviço do Portainer
#
# Declarando as variáveis utilizadas nas configurações do sistema de container Docker e Portainer
#
# Variável de download da chave GPG do Docker Community (Link atualizado no dia 15/12/2021)
DOCKERGPG="https://download.docker.com/linux/ubuntu/gpg"
DOCKERKEY="0EBFCD88"
DOCKERREP="deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
#
# Variável de download do Docker Compose (Link atualizado no dia 14/09/2023)
DOCKERCOMPOSE="https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-linux-x86_64"
#
# Variável das dependências do laço de loop do Docker Community 
DOCKERDEP="bind9"
#
# Variável de instalação das Dependências do Docker Community, Docker Compose e Portainer.io
# opção do caractere: \ (contra barra): utilizado para quebra de linha em comandos grandes
DOCKERINSTALLDEP="apt-transport-https ca-certificates curl software-properties-common \
linux-image-generic linux-image-extra-virtual python3-dev python3-pip libffi-dev gcc \
libc-dev cargo make"
#
# Variável de instalação do Docker Community CE.
DOCKERINSTALL="docker-ce cgroup-lite"
#
# Variáve da porta de conexão padrão do Portainer.io
PORTPORTAINER="9000"
#
#=============================================================================================
#                        VARIÁVEIS UTILIZADAS NO SCRIPT: 25-ansible.sh                       #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema Ansible e Rundeck utilizados nesse script
# 01. /etc/rundeck/rundeck-config.properties = arquivo de configuração do serviço do Rundeck
#
# Arquivos de monitoramento (log) do Serviço do Ansible e Rundeck utilizados nesse script
# 01. sudo systemctl status rundeckd = status do serviço do Rundeck Server
# 02. sudo journalctl -t rundeckd = todas as mensagens referente ao serviço do Rundeck
# 03. tail -f /var/log/rundeck/*.log = vários arquivos de Logs do serviço do Rundeck
# 04. tail -f /var/log/syslog | grep -i rundeck = filtrando as mensagens do serviço do Rundeck
#
# Declarando as variáveis utilizadas nas configurações do sistema de DevOps Ansible e Rundec
#
# Variável do PPA (Personal Package Archive) do Ansible (Link atualizado no dia 16/12/2021)
ANSIBLEPPA="ppa:ansible/ansible"
#
# Variável de download do Rundeck (Link atualizado no dia 14/09/2023)
RUNDECKINSTALL="https://packagecloud.io/pagerduty/rundeck/packages/any/any/rundeck_4.16.0.20230825-1_all.deb/download.deb?distro_version_id=35"
#
# Variável de download do Plugin do Ansible para o Rundeck (Link atualizado no dia 14/09/2023)
PLUGINANSIBLE="https://github.com/rundeck-plugins/ansible-plugin/releases/download/v3.2.7/ansible-plugin-3.2.7.jar"
#
# Variável de instalação do Ansible
ANSIBLEINSTALL="ansible"
#
# Variável das dependências do laço de loop do Rundeck
RUNDECKDEP="bind9 software-properties-common openjdk-11-jdk openjdk-11-jre default-jdk"
#
RUNDECKDEPINSTALL="python openjdk-11-jdk-headless"
#
# Variável da porta de conexão padrão do Rundeck
PORTRUNDECK="4440"
#
#=============================================================================================
#                         VARIÁVEIS UTILIZADAS NO SCRIPT: 26-ntopng.sh                       #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema NTop-NG utilizados nesse script
# 01. /etc/ntopng/ntopng.conf = arquivo de configuração do serviço do NTop-NG
# 02. /etc/ntopng/ntopng.start = arquivo de inicialização do serviço do NTop-NG
#
# Arquivos de monitoramento (log) do Serviço do NTop-NG utilizados nesse script
# 01. sudo systemctl status ntopng = status do serviço do NTop-NG Server
# 02. sudo systemctl status redis-server = status do serviço do Redis Server
# 03. sudo journalctl -t ntopng = todas as mensagens referente ao serviço do NTop-NG
# 04. tail -f /var/log/syslog | grep -i ntopng = filtrando as mensagens do serviço do NTop-NG
#
# Declarando as variáveis utilizadas nas configurações do sistema de monitoramento NTop-NG
#
# Variável de download do Repositório do NTop-NG (Link atualizado no dia 16/12/2021)
NTOPNGREP="https://packages.ntop.org/apt-stable/20.04/all/apt-ntop-stable.deb"
#
# Variável das dependências do laço de loop do NTop-NG
NTOPNGDEP="bind9 software-properties-common"
#
# Variável de instalação do NTop-NG.
NTOPNGINSTALL="ntopng ntopng-data"
#
# Variável da porta de conexão padrão do NTop-NG
PORTNTOPNG="3001"
#
#=============================================================================================
#                        VARIÁVEIS UTILIZADAS NO SCRIPT: 27-openfire.sh                      #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema OpenFire utilizados nesse script
# 01. /etc/openfire/openfire.xml = arquivo de configuração do OpenFire (gerado na configuração)
#
# Arquivos de monitoramento (log) do Serviço do OpenFire utilizados nesse script
# 01. sudo systemctl status openfire = status do serviço do OpenFire Server
# 02. sudo journalctl -t openfire = todas as mensagens referente ao serviço do OpenFire
# 03. tail -f /var/log/openfire/* = vários arquivos de Logs do serviço do OpenFire
# 04. tail -f /var/log/syslog | grep -i openfire = filtrando as mensagens do serviço do OpenFire
#
# Declarando as variáveis utilizadas nas configurações do sistema de mensageria OpenFire
#
# Variável de download do instalador do OpenFire (Link atualizado no dia 25/07/2023).
OPENFIREINSTALL="https://www.igniterealtime.org/downloadServlet?filename=openfire/openfire_4.7.5_all.deb"
#
# Variável da instalação das dependências do OpenFire
OPENFIREINSTALLDEP="openjdk-11-jdk openjdk-11-jre default-jdk openjdk-11-jdk-headless"
#
# Declarando as variáveis para criação da Base de Dados do OpenFire
# opção do comando create: create (criação), database (base de dados), base (banco de dados), 
# character set (conjunto de caracteres), collate (comparar)
# opção do comando create: create (criação), user (usuário), identified by (identificado por - 
# senha do usuário), password (senha)
# opção do comando grant: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/tabelas),
# to (para), user (usuário), identified by (identificado por - senha do usuário), password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou tabela), 
# *.* (todos os bancos/tabelas) to (para), user@'%' (usuário @ localhost), identified by (identificado 
# por - senha do usuário), password (senha)
# opção do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
#
# OBSERVAÇÃO: NO SCRIPT: 24-OPENFIRE.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA
# DO ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 366 até 371, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHAS: 261 até 262
DATABASE_OPENFIRE="openfire"
CREATE_DATABASE_OPENFIRE="CREATE DATABASE openfire;"
CREATE_USER_DATABASE_OPENFIRE="CREATE USER 'openfire' IDENTIFIED BY 'openfire';"
GRANT_DATABASE_OPENFIRE="GRANT USAGE ON *.* TO 'openfire';"
GRANT_ALL_DATABASE_OPENFIRE="GRANT ALL PRIVILEGES ON openfire.* TO 'openfire';"
FLUSH_OPENFIRE="FLUSH PRIVILEGES;"
CREATE_TABLE_OPENFIRE="/usr/share/openfire/resources/database/openfire_mysql.sql"
#
# Variável das dependências do laço de loop do OpenFire
OPENFIREDEP="bind9 mysql-server mysql-common"
#
# Variável da porta de conexão padrão do OpenFire
PORTOPENFIRE="9090"
#
#=============================================================================================
#                        VARIÁVEIS UTILIZADAS NO SCRIPT: 28-owncloud.sh                      #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema ownCloud utilizados nesse script
# 01. /var/www/html/own/config/config.php = arquivo de configuração do ownCloud (gerado na instalação)
# 02. /etc/apache2/sites-available/owncloud.conf = arquivo de configuração do Virtual Host do ownCloud
#
# Arquivos de monitoramento (log) do Serviço do ownCloud utilizados nesse script
# 01. /var/log/apache2/access-owncloud.log = arquivo de Log de acesso ao ownCloud
# 02. /var/log/apache2/error-owncloud.log = arquivo de Log de erro de acesso ao ownCloud
#
# Declarando as variáveis utilizadas nas configurações do sistema de cloud ownCloud
#
# Variável de download do instalador do ownCloud (Link atualizado no dia 13/01/2022).
OWNCLOUDINSTALL="https://download.owncloud.org/community/owncloud-latest.tar.bz2"
#
# Variável da instalação das dependências do ownCloud
# opção do caractere: \ (contra barra): utilizado para quebra de linha em comandos grandes
OWNCLOUDINSTALLDEP="software-properties-common php-cli php-common php-mbstring php-gd php-intl \
php-xml php-mysql php-zip php-curl php-xmlrpc"
#
# Declarando as variáveis para criação da Base de Dados do ownCloud
# opção do comando create: create (criação), database (base de dados), base (banco de dados), 
# character set (conjunto de caracteres), collate (comparar)
# opção do comando create: create (criação), user (usuário), identified by (identificado por - 
# senha do usuário), password (senha)
# opção do comando grant: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/tabelas),
# to (para), user (usuário), identified by (identificado por - senha do usuário), password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou tabela), 
# *.* (todos os bancos/tabelas) to (para), user@'%' (usuário @ localhost), identified by (identificado 
# por - senha do usuário), password (senha)
# opção do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
#
# OBSERVAÇÃO: NO SCRIPT: 25-OWNCLOUD.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA
# DO ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 366 até 371, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHAS: 261 até 262
CREATE_DATABASE_OWNCLOUD="CREATE DATABASE owncloud;"
CREATE_USER_DATABASE_OWNCLOUD="CREATE USER 'owncloud' IDENTIFIED BY 'owncloud';"
GRANT_DATABASE_OWNCLOUD="GRANT USAGE ON *.* TO 'owncloud';"
GRANT_ALL_DATABASE_OWNCLOUD="GRANT ALL PRIVILEGES ON owncloud.* TO 'owncloud' WITH GRANT OPTION;"
FLUSH_OWNCLOUD="FLUSH PRIVILEGES;"
#
# Variável das dependências do laço de loop do ownCloud
OWNCLOUDDEP="bind9 mysql-server mysql-common apache2 php"
#
#=============================================================================================
#                      VARIÁVEIS UTILIZADAS NO SCRIPT: 29-ocsinventory.sh                    #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema OCS Inventory utilizados nesse script
# 01. /etc/apache2/conf-available/z-ocsinventory-server.conf = arquivo do virtual host do OCS Inventory
# 02. /etc/apache2/conf-available/zz-ocsinventory-restapi.conf = arquivo do RestAPI do OCS Inventory
# 03. /etc/apache2/conf-available/ocsinventory-reports.conf = arquivo do Reports do OCS Inventory
# 04. /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php = arquivo do Database do OCS Inventory
# 05. /etc/ocsinventory-agent/ocsinventory-agent.cfg = arquivo de configuração do OCS Inventory Agent
# 06. /etc/ocsinventory-agent/modules.conf = arquivo de configuração dos módulos do OCS Inventory Agent
# 07. /etc/cron.d/ocsinventory-agent = arquivo de configuração do CRON do OCS Inventory Agent
#
# Arquivos de monitoramento (log) do Serviço do OCS Inventory utilizados nesse script
# 01. /var/log/ocs_server_setup.log = arquivo de log da instalação do OCS Inventory
# 02. /var/log/ocsinventory-server/activity.log = arquivo de log do Servidor OCS Inventory
# 03. /var/log/ocsinventory-agent/ocsagent.log = arquivo de log do Agent OCS Inventory
# 04. tail -f /var/log/cron.log = filtrando as mensagens do serviço do CRON
#
# Declarando as variáveis utilizadas nas configurações do sistema de inventário OCS Inventory
#
# Variável de download do instalador do OCS Inventory Server (Link atualizado no dia 25/07/2023).
OCSINVENTORYSERVERINSTALL="https://github.com/OCSInventory-NG/OCSInventory-ocsreports/releases/download/2.12.2/OCSNG_UNIX_SERVER-2.12.2.tar.gz"
#
# Variável de download do instalador do OCS Inventory Agent (Link atualizado no dia 04/12/2022).
OCSINVENTORYAGENTINSTALL="https://github.com/OCSInventory-NG/UnixAgent/releases/download/v2.10.2/Ocsinventory-Unix-Agent-2.10.2.tar.gz"
#
# Variável de verificação do Chip Gráfico da NVIDIA
# opção do comando lshw: -class display (lista as informações da placa de vídeo)
# opção do comando cut: -d':' (delimitador) -f2 (mostrar segunda coluna)
# opção do redirecionador | piper: Conecta a saída padrão com a entrada padrão de outro comando
OCSINVENTORYAGENTNVIDIA=$(lshw -class display | grep NVIDIA | cut -d':' -f2 | cut -d' ' -f2)
#
# Variável da instalação das dependências do OCS Inventory Server
# opção do caractere: \ (contra barra): utilizado para quebra de linha em comandos grandes
OCSINVENTORYINSTALLDEP="gcc make autoconf autogen automake pkg-config uuid-dev net-tools pciutils \
smartmontools read-edid nmap ipmitool dmidecode samba samba-common samba-testsuite snmp \
snmp-mibs-downloader snmpd unzip hwdata perl-modules python-dev python3-dev python3-pip \
apache2-dev mysql-client python3-pymssql python3-mysqldb"
#
# Variável de instalação das dependências do PHP do OCS Inventory Server
# opção do caractere: \ (contra barra): utilizado para quebra de linha em comandos grandes
OCSINVENTORYINSTALLPHP="php-snmp php-mysql php-dev php-soap php-apcu php-xmlrpc php-zip php-gd \
php-mysql php-pclzip php-json php-mbstring php-curl php-imap php-ldap zlib1g-dev php-cas php-curl"
#
# Variável de instalação das dependências do Perl do OCS Inventory Server
# opção do caractere: \ (contra barra): utilizado para quebra de linha em comandos grandes
OCSINVENTORYINSTALLPERL="libc6-dev libcompress-raw-zlib-perl libwww-perl libdigest-md5-file-perl \
libnet-ssleay-perl libcrypt-ssleay-perl libnet-snmp-perl libproc-pid-file-perl libproc-daemon-perl \
libarchive-zip-perl libnet-cups-perl libmysqlclient-dev libapache2-mod-perl2 libapache2-mod-php \
libnet-netmask-perl libio-compress-perl libxml-simple-perl libdbi-perl libdbd-mysql-perl \
libapache-dbi-perl libsoap-lite-perl libnet-ip-perl libmodule-build-perl libmodule-install-perl \
libfile-which-perl libfile-copy-recursive-perl libuniversal-require-perl libtest-http-server-simple-perl \
libhttp-server-simple-authen-perl libhttp-proxy-perl libio-capture-perl libipc-run-perl \
libnet-telnet-cisco-perl libtest-compile-perl libtest-deep-perl libtest-exception-perl \
libtest-mockmodule-perl libtest-mockobject-perl libtest-nowarnings-perl libxml-treepp-perl \
libparallel-forkmanager-perl libparse-edid-perl libdigest-sha-perl libtext-template-perl \
libsocket-getaddrinfo-perl libcrypt-des-perl libnet-nbname-perl libyaml-perl libyaml-shell-perl \
libyaml-libyaml-perl libdata-structure-util-perl liblwp-useragent-determined-perl libio-socket-ssl-perl \
libdatetime-perl libthread-queue-any-perl libnet-write-perl libarchive-extract-perl libjson-pp-perl \
liburi-escape-xs-perl liblwp-protocol-https-perl libnmap-parser-perl libmojolicious-perl libswitch-perl \
libplack-perl libdigest-hmac-perl libossp-uuid-perl libperl-dev libsnmp-perl libsnmp-dev libsoap-lite-perl"
#
# Variável de alteração de senha do OCS Inventory Reports no Banco de Dados do MySQL
# 'ocs'@'localhost' usuário de administração do banco de dados do OCS Inventory
# PASSWORD('pti@2018') nova senha do usuário ocs
# CUIDADO!!!!: essa senha será utilizada nos arquivos de configuração do OCS Inventory: dbconfig.inc.php, 
# z-ocsinventory-server.conf e zz-ocsinventory-restapi.conf
# opção do comando create: create (criação), database (base de dados), base (banco de dados), 
# character set (conjunto de caracteres), collate (comparar)
# opção do comando create: create (criação), user (usuário), identified by (identificado por - 
# senha do usuário), password (senha)
# opção do comando grant: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/tabelas),
# to (para), user (usuário), identified by (identificado por - senha do usuário), password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou tabela), 
# *.* (todos os bancos/tabelas) to (para), user@'%' (usuário @ localhost), identified by (identificado 
# por - senha do usuário), password (senha)
# opção do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
#
# OBSERVAÇÃO: NO SCRIPT: 26-OCSINVENTORY.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA
# DO ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 366 até 371, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHAS: 261 até 262
CREATE_USER_DATABASE_OCSINVENTORY="CREATE USER 'ocsweb' IDENTIFIED BY 'ocsweb';"
GRANT_DATABASE_OCSINVENTORY="GRANT USAGE ON *.* TO 'ocsweb';"
GRANT_ALL_DATABASE_OCSINVENTORY="GRANT ALL PRIVILEGES ON ocsweb.* TO 'ocsweb' WITH GRANT OPTION;"
FLUSH_OCSINVENTORY="FLUSH PRIVILEGES;"
#
# Variável das dependências do laço de loop do OCS Inventory Server
OCSINVENTORYDDEP="bind9 mysql-server mysql-common apache2 php"
#
#=============================================================================================
#                         VARIÁVEIS UTILIZADAS NO SCRIPT: 30-bacula.sh                       #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema Bacula Server e Baculum utilizados nesse script
# 01. /etc/sudoers.d/baculum-api = arquivo de configuração de liberação do SUDOERS da API do Bacula
# 02. /etc/hosts.allow = arquivo de configuração de liberação de hosts por serviço de rede 
#
# Arquivos de monitoramento (log) do Serviço do Bacula Server e Baculum utilizados nesse script
# 01. sudo systemctl status bacula-fd = status do serviço do Bacula-FD Server
# 02. sudo systemctl status bacula-sd = status do serviço do Bacula-SD Server
# 03. sudo systemctl status bacula-dir = status do serviço do Bacula-DIR Server
# 04. /var/log/bacula/* = arquivos de Log do serviço do Bacula
# 05. tail -f /var/log/syslog | grep -i bacula = filtrando as mensagens do serviço do Bacula
# 06. /var/log/apache2/baculum*.log = vários arquivos de Log do serviço do Baculum-Web
#
# Declarando as variáveis utilizadas nas configurações do sistema de backup Bacula e Baculum
#
# Variável de download da chave de autenticação do repositório do Bacula Server
BACULAKEY="https://www.bacula.org/downloads/Bacula-4096-Distribution-Verification-key.asc"
#
# Variável de download da chave de autenticação do repositório do Baculum WEP/API
BACULUMKEY="http://bacula.org/downloads/baculum/baculum.pub"
#
# Variável de instalação do Bacula Server
BACULAINSTALL="bacula-client bacula-common bacula-mysql bacula-console"
#
# Variável de instalação do Baculum WEB
BACULUMWEBINSTALL="baculum-web baculum-web-apache2"
#
# Variável de instalação do Baculum API
BACULUMAPIINSTALL="baculum-common baculum-api-apache2"
#
# Variável das dependências do laço de loop do Bacula Server
BACULUMDEP="bind9 mysql-server mysql-common apache2 php python2.7 python3 apt-transport-https"
#
#=============================================================================================
#                         VARIÁVEIS UTILIZADAS NO SCRIPT: 31-graylog.sh                      #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema Graylog Server utilizados nesse script
# 01. /etc/elasticsearch/elasticsearch.yml = arquivo de configuração do serviço do ElasticSearch
# 02. /etc/elasticsearch/jvm.options = arquivo de configuração do Java do ElasticSearch
# 03. /etc/graylog/server/server.conf = arquivo de configuração do Graylog Server
#
# Arquivos de monitoramento (log) do Serviço do Graylog Server utilizados nesse script
# 01. sudo systemctl status graylog = status do serviço do Graylog Server
# 02. /var/log/graylog-server/server.log = arquivo de Log do serviço de rede Graylog Server
#
# Declarando as variáveis utilizadas nas configurações do sistema de Log Graylog Server 
#
# Variável da chave do repositório do MongoDB Server (Link atualizado no dia 02/02/2022)
KEYSRVMONGODB="https://www.mongodb.org/static/pgp/server-4.4.asc"
#
# Variável da instalação do MongoDB Server
MONGODBINSTALL="mongodb-org"
#
# Variável da chave GPG do repositório do ElastickSearch (Link atualizado no dia 02/02/2022)
GPGKEYELASTICSEARCH="https://artifacts.elastic.co/GPG-KEY-elasticsearch"
#
# Variável da instalação do ElasticSearch
ELASTICSEARCHINSTALL="elasticsearch-oss"
#
# Variável do download do repositório do Graylog Server (Link atualizado no dia 25/01/2023)
REPGRAYLOG="https://packages.graylog2.org/repo/packages/graylog-5.0-repository_latest.deb"
#
# Variável do usuário do serviço do Graylog Server
USERGRAYLOG="graylog"
#
# Variável da senha do usuário de serviço do Graylog Server
# opção do comando pwgen: -N (num passwords), -s (secure)
SECRETGRAYLOG=$(pwgen -N 1 -s 96)
#
# Variável do HASH da senha do usuário de serviço do Graylog Server
# opção do comando tr: -d (delete)
# opção do comando cut: -d (delimiter), -f (fields)
# opção do redirecionador | piper: Conecta a saída padrão com a entrada padrão de outro comando
SHA2GRAYLOG=$(echo $USERGRAYLOG | tr -d '\n' | sha256sum | cut -d" " -f1)
#
# Variável da instalação das dependências do Graylog Server
# opção do caractere: \ (contra barra): utilizado para quebra de linha em comandos grandes
GRAYLOGINSTALLDEP="apt-transport-https openjdk-11-jdk openjdk-11-jre openjdk-11-jre-headless \
default-jdk default-jre ca-certificates-javaopenjdk-11-jre-headless uuid-runtime pwgen gnupg \
curl dirmngr"
#
# Variável da instalação do Graylog Server
# opção do caractere: \ (contra barra): utilizado para quebra de linha em comandos grandes
GRAYLOGINSTALL="graylog-server graylog-enterprise-plugins graylog-integrations-plugins \
graylog-enterprise-integrations-plugins"
#
# Variável das dependências do laço de loop do Graylog Server
GRAYLOGDEP="apt-transport-https pwgen"
#
# Variáveis das portas de serviço do Graylog, MongoDB e do ElasticSearch
GRAYLOGPORT="19000"
MONGODBPORT="27017"
ELASTICSEARCHPORT="9200"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 32-postgresl.sh                      #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço do PostgreSQL Server utilizados nesse script
# 01. /etc/postgresql/14/main/postgresql.conf = arquivo de configuração do Servidor PostgreSQL
# 02. /etc/postgresql/14/main/pg_hba.conf = arquivo de liberação de rede do Servidor PostgreSQL
#
# Arquivos de monitoramento (log) do Serviço do PostgreSQL Server utilizados nesse script
# 01. sudo systemctl status postgresql-14 = status do serviço do PostgreSQL Server
# 02. /var/log/postgresql/postgresql-14-main.log = arquivo de Log do Servidor PostgreSQL
# 03. tail -f /var/log/syslog | grep -i postgresql = filtrando as mensagens do serviço do PostgreSQL
# 04. /var/log/pgadmin/pgadmin4.log = arquivo de Log do Serviço via Web PgAdmin4
#
# Declarando as variáveis utilizadas nas configurações do sistema de Database PostgreSQL Server
#
# Variável de download da chave de autenticação do repositório do PostgreSQL Server
KEYPOSTGRESQL="https://www.postgresql.org/media/keys/ACCC4CF8.asc"
#
# Variável do nome do usuário padrão do PostgreSQL Server
USERPOSTGRESQL="postgres"
#
# Variável da senha do usuário padrão do PostgreSQL Server
PASSWORDPOSTGRESQL="postgres"
#
# Variável da instalação das dependências do PostgreSQL Server
# opção do caractere: \ (contra barra): utilizado para quebra de linha em comandos grandes
POSTGRESQLDEPINSTALL="build-essential libssl-dev libffi-dev libgmp3-dev virtualenv python3-pip \
libpq-dev python-dev apache2-utils libapache2-mod-wsgi libexpat1 ssl-cert"
#
# Variável da instalação do PostgreSQL Server
POSTGRESQLINSTALL="postgresql postgresql-contrib postgresql-client"
#
# Variável de download da chave de autenticação do repositório do PgAdmin4
KEYPGADMIN4="https://www.pgadmin.org/static/packages_pgadmin_org.pub"
#
# Variável do email do usuário de autenticação padrão do PgAdmin4
EMAILPGADMIN="$USERPOSTGRESQL@$DOMINIOSERVER"
#
# Variável da senha do email do usuário de autenticação padrão do PgAdmin4
EMAILPASSPGADMIN=$PASSWORDPOSTGRESQL
#
# Variável das dependências do laço de loop do PgAdmin4
PGADMIN4DEP="apache2 php python2.7 python3"
#
# Variável da instalação do PgAdmin4
PGADMININSTALL="pgadmin4 pgadmin4-web"
#
# Variável da porta padrão do PostgreSQL Server
POSTGRESQLPORT="5432"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 33-nextcloud.sh                      #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema Nextcloud utilizados nesse script
# 01. /etc/apache2/sites-available/nextcloud.conf = arquivo de configuração do Virtual Host
#
# Arquivos de monitoramento (log) do Serviço do Nextcloud utilizados nesse script
# 01. /var/log/apache2/access-nextcloud.log = arquivo de Log de acesso ao Nextcloud
# 02. /var/log/apache2/error-nextcloud.log = arquivo de Log de erro de acesso ao Nextcloud
#
# Declarando as variáveis utilizadas nas configurações do sistema de cloud Nextcloud
#
# Variável de download do instalador do Nextcloud (Link atualizado no dia 14/09/2023).
NEXTCLOUDINSTALL="https://download.nextcloud.com/server/releases/nextcloud-27.0.2.tar.bz2"
#
# Variável da instalação das dependências do Nextcloud
# opção do caractere: \ (contra barra): utilizado para quebra de linha em comandos grandes
NEXTCLOUDINSTALLDEP="software-properties-common php-cli php-common php-xmlrpc libapache2-mod-php \
php-gd php-mysql php-curl php-mbstring php-intl php-gmp php-bcmath php-imagick php-xml php-zip"
#
# Declarando as variáveis para criação da Base de Dados do Nextcloud
# opção do comando create: create (criação), database (base de dados), base (banco de dados), 
# character set (conjunto de caracteres), collate (comparar)
# opção do comando create: create (criação), user (usuário), identified by (identificado por - 
# senha do usuário), password (senha)
# opção do comando grant: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/tabelas),
# to (para), user (usuário), identified by (identificado por - senha do usuário), password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou tabela), 
# *.* (todos os bancos/tabelas) to (para), user@'%' (usuário @ localhost), identified by (identificado 
# por - senha do usuário), password (senha)
# opção do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
#
# OBSERVAÇÃO: NO SCRIPT: 32-NEXTCLOUD.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA
# DO ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 366 até 371, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHAS: 261 até 262
CREATE_DATABASE_NEXTCLOUD="CREATE DATABASE nextcloud;"
CREATE_USER_DATABASE_NEXTCLOUD="CREATE USER 'nextcloud' IDENTIFIED BY 'nextcloud';"
GRANT_DATABASE_NEXTCLOUD="GRANT USAGE ON *.* TO 'nextcloud';"
GRANT_ALL_DATABASE_NEXTCLOUD="GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud' WITH GRANT OPTION;"
FLUSH_NEXTCLOUD="FLUSH PRIVILEGES;"
#
# Variável das dependências do laço de loop do Nextcloud
NEXTCLOUDDEP="bind9 mysql-server mysql-common apache2 php"
#
#=============================================================================================
#                        VARIÁVEIS UTILIZADAS NO SCRIPT: 34-asterisk.sh                      #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema de VoIP Asterisk utilizados nesse script
# 01. /etc/default/asterisk = arquivo de configuração do Daemon do Asterisk
# 02. /etc/asterisk/asterisk.conf = arquivo de configuração do Serviço do Asterisk
# 03. /etc/asterisk/modules.conf = arquivo de configuração dos Módulos do Asterisk
# 04. /etc/asterisk/extensions.conf = arquivo de configurações das extensões dos Ramais
# 05. /etc/asterisk/sip.conf = arquivo de configuração do protocolo SIP do Asterisk
#
# Arquivos de monitoramento (log) do Serviço de VoIP Asterisk utilizados nesse script
# 01. 
#
# Declarando as variáveis utilizadas nas configurações do sistema de VoIP Asterisk
#
# Variáveis de Download do Asterisk e pacotes Extras (Link atualizado no dia 12/12/2022)
DAHDIINSTALL="git://git.asterisk.org/dahdi/linux"
DAHDITOOLSINSTALL="git://git.asterisk.org/dahdi/tools"
LIBPRIINSTALL="https://gerrit.asterisk.org/libpri"
ASTERISKINSTALL="http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz"
SOUNDPTBRCORE="https://www.asterisksounds.org/sites/asterisksounds.org/files/sounds/pt-BR/download/asterisk-sounds-core-pt-BR-3.8.3.zip"
SOUNDPTBREXTRA="https://www.asterisksounds.org/sites/asterisksounds.org/files/sounds/pt-BR/download/asterisk-sounds-extra-pt-BR-1.11.10.zip"
#
# Variável da instalação das dependências do Asterisk
# opção do comando uname: -r (kernel-release)
# opção do caractere: \ (contra barra): utilizado para quebra de linha em comandos grandes
ASTERISKINSTALLDEP="build-essential libssl-dev libelf-dev libncurses5-dev libnewt-dev libxml2-dev \
linux-headers-$(uname -r) libsqlite3-dev uuid-dev subversion libjansson-dev sqlite3 autoconf \
automake libtool libedit-dev flex bison libtool-bin unzip sox openssl zlib1g-dev unixodbc pkg-config \
unixodbc-dev"
#
# Variável da criação do diretório de Sons Português/Brasil do Asterisk
SOUNDSPATH="/var/lib/asterisk/sounds/pt_BR"
#
# Variável da instalação das dependências do ILBC utilizando o debconf-set-selections
COUNTRYCODE="55"
#
# Variável da porta de conexão do Protocolo SIP (Session Initiation Protocol)
PORTSIP="5060"
#
#=============================================================================================
#                        VARIÁVEIS UTILIZADAS NO SCRIPT: 35-netdisco.sh                      #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema de Rede Netdisco utilizados nesse script
# 01. /home/netdisco/environments/deployment.yml = arquivo de instalação do Netdisco Server
#
# Arquivos de monitoramento (log) do Serviço de Rede Netdisco utilizados nesse script
# 01. 
#
# Declarando as variáveis utilizadas nas configurações do sistema de Rede Netdisco
#
# Variáveis de Download do Netdisco (Link atualizado no dia 06/02/2022)
NETDISCOINSTALL="https://cpanmin.us/ | perl - --notest --local-lib ~/perl5 App::Netdisco"
#
# Variável da instalação das dependências do Netdisco
# opção do caractere: \ (contra barra): utilizado para quebra de linha em comandos grandes
NETDISCOINSTALLDEP="libdbd-pg-perl libsnmp-perl libssl-dev libio-socket-ssl-perl curl \
build-essential"
#
# Variável das dependências do laço de loop do Netdisco
NETDISCODEP="postgresql postgresql-contrib postgresql-client"
#
# Variáveis do Usuários e Senha padrão do Netdisco
NETDISCOUSER="netdisco"
NETDISCOPASSWORD="netdisco"
#
# Variáveis da criação do Banco de Dados no PostgreSQL do Netdisco
DATABASE_NETDISCO="netdisco"
#
# Variável da porta de conexão do Netdisco
PORTNETDISCO="5000"
#
#=============================================================================================
#                      VARIÁVEIS UTILIZADAS NO SCRIPT: 36-openproject.sh                     #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema OpenProject utilizados nesse script
# 01. /etc/apt/sources.list.d/openproject.list = arquivo de configuração das Lista do Apt
# 02. /etc/openproject/installer.dat = arquivo de parâmetros da instalação do OpenProject
#
# Arquivos de monitoramento (log) do sistema OpenProject utilizados nesse script
# 01. 
#
# Declarando as variáveis utilizadas nas configurações do sistema de OpenProject
#
# # Variável da chave GPG do repositório do OpenProject (Link atualizado no dia 14/05/2022)
GPGOPENPROJECT="https://dl.packager.io/srv/opf/openproject/key"
#
# Variável das dependências do laço de loop do OpenProject
OPENPROJECTDEP="bind9 apache2 php postgresql postgresql-contrib postgresql-client"
#
# Variável de instalação do OpenProject.
OPENPROJECTINSTALL="openproject"
#
