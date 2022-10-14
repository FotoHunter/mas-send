#!/usr/bin/bash

# Нумерованый заголовок письма для тестирования работы скрипта
rm /tmp/mas-mail.txt
touch /tmp/mas-mail.txt
# Тестовый json запрос
rm /tmp/mas-mail.json
touch /tmp/mas-mail.json

# Количество получателей
declare -i Lcount="2"
# Поиск первого получателя
declare -i Lto="0"
# Отработка списка получателей
declare -i Lrcpt="0"
# Отправитель
declare -i Lfrom="0"
# Дата
declare -i Ldate="0"
# MIME - первый заголовок после получателей
declare -i Lmime="0"
# Наличией адреса в списке получателей
declare -i Lad="0"
# Номер строки заголовка письма
declare -i n="1"
# Номер получателя
declare -i Ann="1"
# Массив, список получателей
declare -a At

    cat "$@" | while read line ; do
    echo "$n : $line" >> /tmp/mas-mail.txt
	Lto=`echo "$line" | grep -c 'To: '`
	Lfrom=`echo "$line" | grep -c 'From: '`
	Ldate=`echo "$line" | grep -c 'Date: '`
	Lmime=`echo "$line" | grep -c 'MIME-Version: '`
	Lad=`echo "$line" | grep -c '@'`
	if [ $Lmime -ne 0 ];
	    then
	    ((Ann--))
	    if (( Ann >= Lcount ));
		then
		Ato[$Ann]=`echo ${Ato[$Ann]//>,/>}`
###############################################################################
# Пишем текст JSON в файл для теста или для отдачи в CURL из файла
###############################################################################
		echo '{' \
		'"title":"Count of recipient ower '"$Lcount"'",' \
		'"Date":"'"$Adate"'",' \
		'"From":"'"$Afrom"'",' \
		'"To":"'["${Ato[@]}"]'",' \
		'"Count of to":"'"$Ann"'" }' > /tmp/mas-mail.json
###############################################################################
###############################################################################
# Пересылка текстом из скрипта
# -u 'username:password' - если нужно
# -X POST - метод передачи запрса
# YOUR-SERVER - заменить на адрес сервера и путь до формы ввода
###############################################################################
#		curl -u 'username:password' \
#		-d '{' \
#		'"title":"Count of recipient ower '"$Lcount"'",' \
#		'"Date":"'"$Adate"'",' \
#		'"From":"'"$Afrom"'",' \
#		'"To":"'["${Ato[@]}"]'",' \
#		'"Count of to":"'"$Ann"'"' \
#		'}' \
#		-X POST https://YOUR-SERVER
###############################################################################
# Пересылка текстом из файла - в качестве примера, после отладки закоментить
###############################################################################
		curl \
		-H "accept: application/json; charset=utf8" \
		-o result.json \
		-d @/tmp/mas-mail.json \
		-X POST "https://YOUR-SERVER/post"
###############################################################################
# test CURL - Проверка отправляемых данных, лучше тестировать отдельно от почтовика с тестовым файлом
###############################################################################
#		curl \
#		-H "accept: application/json; charset=utf8" \
#		-o result.json \
#		-d @/tmp/mas-mail.json \
#		-X POST "https://httpbin.org/post"
###############################################################################
	    fi
	    break
	fi
	if [ $Ldate -ne 0 ];
	    then
	    Adate=`echo $line | sed 's/Date: //'`
	fi
	if [ $Lfrom -ne 0 ];
	    then
	    Afrom=`echo $line | sed 's/From: //'|awk '{print $2}'`
	fi
	if [ $Lto -ne 0 ];
	    then
	    Lrcpt=1
	fi
	if [ $Lrcpt -ne 0 ];
	    then
		if [ $Lad -ne 0 ];
		    then
		    Ato[$Ann]=`echo $line | sed 's/To: //'|sed 's/Cc: //'|sed 's/Bcc: //'|sed 's/,//'|awk '{print $2}'|sed 's/>/>,/'`
		    ((Ann++))
		fi
	fi
	((n++))
done
exit 0
