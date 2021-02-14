# sf__wordpress_experimental

## Вариант 1


Есть готовые проекты типа https://github.com/vccw-team/vccw-xenial64  
Но просто использовать vcc-team/xenial64 (https://app.vagrantup.com/vccw-team/boxes/xenial64) не спортивно.

Вариант попроще - через docker-compose связать готовый контейнеры с Wordpress и с MySQL/Maria-DB.

Ну или как я обычно делаю - на хосте один контейнер с MariaDB.  
Контейнер - связка nginx+letsencrypt в качестве reverse proxy.  
И несколько индивидуальных контейнеров с Wordpress или других.  

Но в этом задании я пошел долгим путем. Ставить все из пакетов на читую Ubuntu.  
И этот путь  оказался очень долгим :)

## Вариант 2

### Запуск

Настроить переменные в начале Vagrantfile (имена, пароли, порт...)  
`vagrant up`

При желании запустить на Windows с WSL2 и Hyper-V можно поменять

    config.vm.provider "virtualbox" do |vm|  
на

    config.vm.provider "hyperv" do |vm|  


Стартовать (`vagrant up`) тогда следует из командной строки / Powershell, запущенных с правами администратора (Run As Administartor).


## основные проблемы, с которыми столкнулся

### Redirect и SSL

В качестве имени сайта выбрал skfwp.dev  
При подключении браузер перебрасывал на https даже для /phpinfo.php. Т.е. это не вина Wordpress.

Активировал SSL.  
Браузер предупреждал о самоподписанном сертификате, но, в отличие от обычной практики, не предлагал опции "подключиться все равно" по причиние HSTS.

Долго разбирался, как отключить HSTS в браузере (chrome://net-internals/#hsts и прочее).  
Ничего не помогало. В итоге оказалось, что для доменов .dev эта опция не отключаемая.  
Сюрприз...

С именем домена skfwp.local заработало.

### Нестандартый порт

http://skfwp.local:8480/phpinfo.php заработало.  
Но обращение к Wordpress перебрасывало на http://skfwp.local/, и Wordpress Не работал.  

Обычно в меню настраивается полный URL с портом, Но в рамках автоматизации пришлось непосредственно базу данных править.

    update wp_options SET option_value = 'http://skfwp.local:8480' where option_id = 1 and option_name = 'siteurl';
    update wp_options SET option_value = 'http://skfwp.local:8480' where option_id = 2 and option_name = 'home';


### Невозможность установить плагины, темы...

Несмотря на предоставление доступа к /wp-content, при попытке что-то установить Wordpress требовал доступ по FTP.  
Пришлось добавить

    define( 'FS_METHOD', 'direct' );

Обычно это по умолчанию настроено, а wp cli, похоже, не установил его при создании конфига.

# Бэкап на Яндекс.Диск

Для работы через WebDAV регистрирую не API (https://oauth.yandex.ru/), а пароль приложения (https://passport.yandex.ru/profile/)

Из соображений безопасности в скрипт учетные данные передаются как переменные окружения. Например, можно прописать в .bashrc:

    export YA_user=username # имя аккаунта в Яндексе
    export YA_webdavkey=app-secretkey # ключ, показанный при создании пароля приложения

Впрочем, похоже, что  функциональность хранения бэкапов на бесплатном Яндекс Диск урезали (https://qna.habr.com/q/677787),


P.S.  
При желании видеть прогресс загрузки curl (`--progress-bar`) обязатально добавить также `> /dev/null`




