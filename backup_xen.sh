#!/bin/bash

<<comment
### SCRIPT PARA BACKUP A QUENTE DAS MÁQUINAS VIRTUAIS XENSERVER ###
AUTOR: NATHANIEL F.
DATA: 11/10/2022
VERSÃO: 1.1
DESCRIÇÃO: SCRIPT PARA BACKUP TANTO QUENTE COMO DESLIGADA AS VM XENSERVER, 
DEVE SER COPIADO E EXECUTADO INTERNAMENTE NO SERVIDOR XEN, CRIANDO-SE UM SCRIPT
DANDO A PERMISSÃO DE EXECUÇÃO E COMBINANDO ELE AO CRON TORNA O PROCEDIMENTO
AUTOMATICO, SEM A NECESSIDADE DE INTERVENÇÃO PARA O BACKUP.
comment

# MENSAGEM
MSG_01="Erro ao definir estado 'on' para executar o backup a quente ou 'off' para executar o backup com a vm desligada"
MSG_01='VM está desligada'

# DATA ATUAL
DATA_ATUAL=$(date +%d%b%Y)

# DIRETORIO DE BACKUP
DIR_BACKUP="DIRETORIO ONDE SERÁ FEITO O BACKUP"

# NOME DAS VMS QUE PODEM SER REALIZADO O PROCEDIMENTO A QUENTE E DESLIGADA
VM=(
'VM01_EXEMPLO'
'VM02_EXEMPLO'
)

# UUID CORRESPONDENTE DO NOME DA VM
VMUUID=(
'5f6e1f7a-121c-290c-d479-733013759e71_UUID_EXEMPLO'
'1cf8b696-2bfc-263a-47ac-5e628d4ca15c_UUID_EXEMPLO'
)

# ESTADO QUE SERÁ REALIZADO O BACKUP(on / off), ON SERÁ FEITO A QUENTE E OFF QUANDO NÃO TEM ESPAÇO EM DISCO PARA SNAPSHOT
ESTADO=(
'on'
'off'
)

# TIME EM SEGUNDOS PARA SLEEP
TIME='60'

# PEGANDO O DIA DA SEMANA
#DIA_SEMANA=$(date +%w)

# A SEMANA VAI DE 0 A 6, ONDE 0 É DOMINGO E 6 É SÁBADO, CASO UTILIZE EM COMBINADO COM CRON
#if [ $DIA_SEMANA -eq 6 ]; then

# LOOP DE BACKUP
for i in $(seq ${#VM[@]})
do

	if [ ${ESTADO[$i-1]} == 'on' ]; then
		# ESPERAR EM SEGUNDOS
		sleep $TIME
	
		# AVISO
		echo "-------- BACKUP REALIZADO COM VM LIGADA(ON) -> $DATA_ATUAL -----------" >> /var/log/backup_vm.log

		# VARIAVEL PARA CRIAR SNAPSHOT
		SNAPUUID=$(xe vm-snapshot uuid="${VMUUID[$i-1]}" new-name-label="${VMUUID[$i-1]}-$DATE")

		# AVISO
		echo "Iniciando backup da VM: ${VM[$i-1]}-$DATA_ATUAL" >> /var/log/backup_vm.log 

		# NOMEAR O SNAPSHOT
		SNAPSHOT="${VM[$i-1]}-$DATA_ATUAL"

		# COMANDO PARA CRIAR UM TEMPLATE
		xe template-param-set is-a-template=false ha-always-run=false uuid=${SNAPUUID}
		
		# EXPORTAR SNAPSHOT
		xe vm-export vm=${SNAPUUID} filename="$DIR_BACKUP/$SNAPSHOT.xva"

        # VALIDAÇÃO DO COMANDO ACIMA, CASO A EXPORTAÇÃO TENHA SUCESSO
        if [ $? -eq 0 ]; then
                echo "Backup realizado com sucesso de ${VM[$i-1]}-$DATA_ATUAL" >> /var/log/backup_vm.log
        else
                echo "Erro ao realizado o backup de ${VM[$i-1]}-$DATA_ATUAL" >> /var/log/backup_vm.log
        fi

		# EXCLUIR O SNAPSHOT
		xe snapshot-uninstall snapshot-uuid=${SNAPUUID} force=true
	
	elif [ ${ESTADO[$i-1]} == 'off' ]; then
		# ESPERAR EM SEGUNDOS
		sleep $TIME
	
		# AVISO
		echo "-------- BACKUP REALIZADO COM VM DESLIGADA(OFF) -> $DATA_ATUAL -----------" >> /var/log/backup_vm.log
		
		# AVISO
		echo "Iniciando backup da VM: ${VM[$i-1]}-$DATA_ATUAL" >> /var/log/backup_vm.log 

		# CAPTURANDO ESTADO DA VM
		xe vm-list power-state=running | grep ${VMUUID[$i-1]}

		# VALIDANDO ESTADO ATUAL DA VM
		if [ $? -eq 0 ]; then
			echo 'Desligando VM'
			
			# DESLIGANDO VM *VM WINDOWS DEVE SER DESLIGADA MANUALMENTE
			xe vm-shutdown uuid=${VMUUID[$i-1]} force=true
		else
			echo $MSG_02
			
		fi
		
		# VARIAVEL PARA EXPORTAR
		xe vm-export uuid=${VMUUID[$i-1]} filename="$DIR_BACKUP/${VM[$i-1]}-$DATA_ATUAL.xva"
		
		# VALIDAÇÃO DO COMANDO ACIMA, CASO A EXPORTAÇÃO TENHA SUCESSO
		if [ $? -eq 0 ]; then
			echo "Backup realizado com sucesso de ${VM[$i-1]}-$DATA_ATUAL" >> /var/log/backup_vm.log 
		else
			echo "Erro ao realizado o backup de ${VM[$i-1]}-$DATA_ATUAL" >> /var/log/backup_vm.log 
		fi
		
		# AVISO
		echo "Ligando a VM: ${VM[$i-1]}" 
		
		# LIGANDO A VM
		xe vm-start uuid=${VMUUID[$i-1]}
		
	else
	
		echo $MSG_01
	
	fi
done

#fi
