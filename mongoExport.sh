#!/bin/sh

# This code was developed and is maintained by Gabriel Fiamete da Rosa.

# VARIÁVEIS GLOBAIS
echo 'Coloque o ID do S3 aqui:'
read USER
echo 'Coloque o Token do S3 aqui:'
read TOKEN
echo 'Digite o endereço da API S3 do seu Mnio abaixo:'
read S3
echo 'Digite o diretório S3 do seu Minio abaixo:'
read DIR_S3
# CONFIGURA AS CREDENCIAIS DO S3 PARA ARMAZENAMENTO.
if [ $USER ]; then
    aws configure set aws_access_key_id $USER && aws configure set aws_secret_access_key $TOKEN
else 
    echo "USUÁRIO NÃO ESTÁ PRESENTE NO ARQUIVO. PORFAVOR ADICIONE O USUÁRIO E TOKEN NAS RESPECTIVAS VARIÁVEIS!"
    exit 2
fi
# MOSTRA CONTAINERS ATIVOS
docker ps -a

echo 'Digite o nome do container do Banco de Dados abaixo:'
read CONTAINER

echo 'Digite o caminho do diretório que deseja mover o backup:'
read DIR_BKP

# VERIFICA SE O CONTAINER SOLICITADO PARA EXTRAÇÃO EXISTE.
if [ $CONTAINER ] && [ $DIR_BKP ]; then
        docker exec -u root $CONTAINER sh -c "mongodump --archive" > $DIR_BKP/db_bkp.dump
else
    echo "O nome do container não pode estar em branco e o diretório deve existir! Por favor, tente novamente!"
    exit 2
fi

# VERIFICA SE O ARQUIVO FOI CRIADO e IMPORTA PARA O S3.
if [ -f $DIR_BKP/db_bkp.dump ]; 
then
    aws --endpoint-url $S3 s3 cp $DIR_BKP/db.dump $DIR_S3
fi

echo 'Procedimento finalizado com sucesso!'
exit 0
