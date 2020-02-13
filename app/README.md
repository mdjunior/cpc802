# Aplicação de avaliação

A seguinte aplicação é um serviço web em Python 3, utilizando Flask que faz uso dos modelos treinados para responder `200` ou `403` de acordo com a URI chamada. Além de responder com o código de estado, a aplicação responde um JSON com o resultado de cada modelo.

```
{
    "lgs":1,
    "lsvm":1,
    "percep":1,
    "uri":"/404.php?url=1%3Cscript%3Ealert(%27openvas-vt%27)%3C/script%3E"
}
```

## Configuração para desenvolvimento

Para desenvolver a aplicação nessa pasta, você precisará configurar um ambiente virtual Python 3 no seu computador. A seguir temos um passo a passo compatível com sistemas *NIX. É esperado que você esteja dentro da pasta `app`.

```
sudo pip3 install virtualenv
source ENV/usr/local/bin/activate
pip3 install -r requirements.txt
```

Para inicializar a aplicação, execute:

```
python app.py
```

Como a aplicação inicia na porta 8888, você pode testar a mesma passando uma URL de teste:

```
curl -v 'http://127.0.0.1:8888/404.php?url=1%3Cscript%3Ealert(%27openvas-vt%27)%3C/script%3E'

< HTTP/1.0 403 FORBIDDEN
< Content-Type: application/json
< Content-Length: 101
< Server: Werkzeug/1.0.0 Python/3.7.3
< Date: Sun, 01 Mar 2020 04:46:49 GMT
<
{"lgs":1,"lsvm":1,"percep":1,"uri":"/404.php?url=1%3Cscript%3Ealert(%27openvas-vt%27)%3C/script%3E"}
```

Após terminar o desenvolvimento, para sair do ambiente virtual, execute:

```
deactivate
```

Caso você tenha inserido dependências adicionais, execute o seguinte comando para atualizar o arquivo `requirements.txt` com as novas dependências.

```
pip freeze > requirements.txt
```