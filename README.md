# backup-xen
### Script de backup de vm no xen

### Descrição
O script de backup para vm em servidor com xenserver ou xcp automatiza o procedimento de backup em combinado com o cron, sendo possível agendar de forma pontual, basta definir no cron. No cenário onde ele foi proposto foi para atender as vms no meu local de trabalho que antes era realizado manual e teria que ser realizado no primeiro final de semana do mês, ocupando todo final de semana para realizar o procedimento, agora em combinado com o cron, foi definido que em certo horário nos primeiros dias do mês, coloquei 7 dias, e com a validação no script do dia da semana, ele faz o backup, por exemplo, no primeiro sábado que pode cair em qualquer dia entre 1 e 7, desde que seja sábado, dessa forma ele vai realizar o procedimento sem intervenção, todos os meses, dentro desse intervalo de horário e dia, facilitando com isso a vida do pessoal de infra.

### Procedimento
* 1 - criar um arquivo dentro do servidor xen ou copiar o arquivo.
* 2 - dar a permissão para execução do script.
* 3 - configurar o cron e descomentar o trecho onde informa o dia da semana.
* 4 - informar no script o nome das vms, para registrar no backup, UUID da mesma, estado se on ou off, informar o diretório de backup.

```
DIRETORIO DE BACKUP
DIR_BACKUP="DIRETORIO ONDE SERÁ FEITO O BACKUP"

NOME DAS VMS QUE PODEM SER REALIZADO O PROCEDIMENTO A QUENTE E DESLIGADA
VM=(
'VM01_EXEMPLO'
'VM02_EXEMPLO'
)

UUID CORRESPONDENTE DO NOME DA VM
VMUUID=(
'5f6e1f7a-121c-290c-d479-733013759e71_UUID_EXEMPLO'
'1cf8b696-2bfc-263a-47ac-5e628d4ca15c_UUID_EXEMPLO'
)

ESTADO QUE SERÁ REALIZADO O BACKUP(on / off), ON SERÁ FEITO A QUENTE E OFF QUANDO NÃO TEM ESPAÇO EM DISCO PARA SNAPSHOT
ESTADO=(
'on'
'off'
)
```

### Obs.
O script pode ser executado manualmente, caso queira monitorar a execução, apenas deixe comentado o trecho onde deve informar o dia da semana para que ele seja executado, condição.

```
PEGANDO O DIA DA SEMANA
DIA_SEMANA=$(date +%w)

A SEMANA VAI DE 0 A 6, ONDE 0 É DOMINGO E 6 É SÁBADO, CASO UTILIZE EM COMBINADO COM CRON
if [ $DIA_SEMANA -eq 6 ]; then
...
fi
```
