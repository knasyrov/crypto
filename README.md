# README

## Примечание
- Все операция выполняется в **sat (Satoshi - 0.00000001 BTC)**
- Операция выполяняется в тестовом режими в сети - **signet**
- Используется гем - **[bitcoinrb](https://github.com/chaintope/bitcoinrb)** 
- Для получения данных по транзакция используется **[mempool.space](https://mempool.space/signet)**


# Запуск

## .env файл по умолчанию

```
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_HOST=localhost
POSTGRES_PORT=5432

ADMIN_LOGIN=admin
ADMIN_PASSWORD=admin
```


## для разработки

Тестовая БД
```
docker compose -f ./docker-compose.dev.yml
```
Затем устанавливаем само приложение
```
ruby-install ruby-3.3.5
chruby 3.3.5
bundle install
rake db:reset db:setup
bin/dev
```

для создания 'кошелька' (по умолчанию)

```
rake crypto:create_wallet
```

это создаст в корневом каталоге wallet.json, пример:

```json
{
    "master_key": "vpub...35RE8k",
    "wif": "cPxQF5L.....1jfE",
    "ext_pub": "021153.....ac3f1da",
    "words": [
        "add",
        "crucial",
        ...
        "jacket"
    ],
    "in_addr": [
        {
            "addr": "tb1qfvguf5gxfs6mq8n7fvxg8gsz98czlks8d4qqk0",
            "wif": "p2wpkh:cNhGvsnmQz2icVBZEvMa6epheEgBhBZiHeKd7ckMsq2SFSFav8mS"
        },
        ...
    ],
    "out_addr": [
        {
            "addr": "tb1qy5hs9xva79amr7xr29y9pnpyzh0tjd0erfdvfg",
            "wif": "p2wpkh:cT9Fb2MynUZEcKmv3SXqXRTCo9tmVjbAsc679jdfWfKYNb2ZLthz"
        },
        ...
    ]
}
```
**можно пользоваться )**



## Запуск postgres для разработки
```
docker compose -f ./docker-compose.dev.yml start
```


## используя docker
```
docker compost up
docker exec -it `docker ps -f name=crypto-web -q` /bin/bash
bundle exec rake crypto:create_wallet
```


# Таблицы
Используеются **postgresql**

## addresses
- **eid** адрес кошелька (primary key)
- **balance** сумма входящих-исходящих транзакция - остаток на счету
- **path** - derivation path - префикс **m/84/0'/0'** + путь (**/0/N** - для приема, **/1/N** - для сдачи) 
- **direction** - 0 для приема, 1 для отправки
- **wif** - WIF ключ
- **created_at**
- **updated_at**

## transactions 
- **in_value** - сумма транзакции
- **in_addr** - откуда списать (вход)
- **out_addr** - куда зачислить (выход)
- **change_addr** - сдача (выход)
- **fee_value** - Комиссия в sat (3% от суммы транзакции) 
- **txid** - 
- **state** - состояние (nil, 0 - создана, 1 - отправлена, 2 - ошибка, 3 - успешно)
- **hex** - hex для отправки
- **created_at**
- **updated_at**

# Интерфейс

Слева меню
- Адреса
- Транзакции
- Новая транзакция
- Админка