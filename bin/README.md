# Modelos exportados

Os seguintes códigos foram gerados (e modificados) a partir da bilioteca [sklearn-porter](https://github.com/nok/sklearn-porter). A finalidade deles é avaliar o custo de implementação da predição de modelos já treinados em outras plataformas que não suportem Python. Cada modelo exportado está em uma pasta com o nome da linguagem de destino.

## Exportando modelos

Para exportar modelos, é necessário ao mínimo tê-los salvos em um formato de serialização compatível com a biblioteca. É possível também exportar os modelos e código de predição sem ter os arquivos exportados, mas essa não foi a abordagem seguida nesse documento.

Para exportar os modelos, você pode usar as bibliotecas [pickle](https://docs.python.org/2/library/pickle.html) ou [joblib](https://joblib.readthedocs.io/en/latest/persistence.html). Veja mais detalhes em [Persistência com SKlearn](https://scikit-learn.org/stable/modules/model_persistence.html). Outra possibilidade é utilizar formatos como ONNX ou PMML (não abordados nesse documento).

Uma vez com o arquivo exportado e com o sklearn-porter instalado, você pode executar os seguintes comandos para exportar o modelo.

No caso de exportar para Go:
```
porter ../models/cpc802-20200209-030517-lsvm-word.sav --go --pipe >> golang/model.go
```

No caso de exportar para C:
```
porter ../models/cpc802-20200209-030517-lsvm-word.sav --c --pipe >> cpp/model.c
```

## Adaptando modelos para testes via terminal

Os modelos exportados esperam receber os vetores de entrada como argumentos, separados por espaço. Ou seja, após compilar nosso `model.go` no arquivo `model`, devemos passar os parâmetros da seguinte forma:

```
./model 0.0 0.0 0.0 ... 102902192 ... 0.0 0.0
```

No caso específico do trabalho, nosso modelo possui dezenas de milhares de parâmetros, o que inviabiliza o teste do mesmo. Dessa forma, adaptamos o `model.go` para receber apenas os parâmetros que são diferentes de zero. Dessa forma, você pode passar os parâmetros como mostrado a seguir:

Exemplo compilado em Go, com execução do time para coleta de métricas de tempo.
```
time ./model 16301:0.211400415300064,2:100000
0

real    0m0.013s
user    0m0.004s
sys     0m0.004s
```

Ou apenas:
```
./model 16301:0.211400415300064,2:100000
0
```

O commit 920ce0d16a0c0886cafbe7cd07dc0ef32a7a9e01 mostra as mudanças realizadas no código em Go exportado.

## Benchmark

Para o código em Go, fizemos alguns benchmarks levando em conta o último modelo treinado com `words`, mas também fizemos um teste variando o tamanho do modelo. O teste `BenchmarkPredictFull` calcula o tempo médio para uma classificação utilizando o modelo completo. Os outros testes, `BenchmarkPredictModelSizeN`, calculam o tempo médio para uma classificação utilizando um modelo de tamanho N.

```
Running tool: /usr/local/bin/go test -benchmem -cpu 1,2,3,4 -run=^$ -bench .

goos: darwin
goarch: amd64
BenchmarkPredictFull                       19228             59154 ns/op               0 B/op          0 allocs/op
BenchmarkPredictFull-2                     20666             57023 ns/op               0 B/op          0 allocs/op
BenchmarkPredictFull-3                     20678             56894 ns/op               0 B/op          0 allocs/op
BenchmarkPredictFull-4                     20947             57601 ns/op               0 B/op          0 allocs/op
BenchmarkPredictModelSize10             122611680                9.57 ns/op            0 B/op          0 allocs/op
BenchmarkPredictModelSize10-2           125284780                9.59 ns/op            0 B/op          0 allocs/op
BenchmarkPredictModelSize10-3           124638420                9.57 ns/op            0 B/op          0 allocs/op
BenchmarkPredictModelSize10-4           122735104                9.65 ns/op            0 B/op          0 allocs/op
BenchmarkPredictModelSize100            11594964               103 ns/op               0 B/op          0 allocs/op
BenchmarkPredictModelSize100-2          10961134               102 ns/op               0 B/op          0 allocs/op
BenchmarkPredictModelSize100-3          11680146               123 ns/op               0 B/op          0 allocs/op
BenchmarkPredictModelSize100-4          11684485               102 ns/op               0 B/op          0 allocs/op
BenchmarkPredictModelSize1000            1000000              1143 ns/op               0 B/op          0 allocs/op
BenchmarkPredictModelSize1000-2          1000000              1137 ns/op               0 B/op          0 allocs/op
BenchmarkPredictModelSize1000-3          1000000              1153 ns/op               0 B/op          0 allocs/op
BenchmarkPredictModelSize1000-4          1000000              1136 ns/op               0 B/op          0 allocs/op
BenchmarkPredictModelSize10000            101820             11543 ns/op               0 B/op          0 allocs/op
BenchmarkPredictModelSize10000-2          100446             11824 ns/op               0 B/op          0 allocs/op
BenchmarkPredictModelSize10000-3          100381             11889 ns/op               0 B/op          0 allocs/op
BenchmarkPredictModelSize10000-4           96447             12412 ns/op               0 B/op          0 allocs/op
PASS
ok      _/cpc802/bin/golang  30.553s
Success: Benchmarks passed.
```

Nesse resultado temos que cada elemento no vetor adiciona cerca de 1ns no cálculo da predição. Podemos reparar que o uso de múltiplos cores não influencia o tempo de execução uma vez que o algoritmo é sequencial.

## Conclusões

A exportação dos modelos ocorreu conforme esperado, mas a incapacidade de exportar a vetorização utilizada é um ponto de melhora. Para alguns testes e exemplos, tivemos que recorrer ao código em Python para gerar o vetor de teste.

# Referências

- MORAWIEC, Darius. sklearn-porter. [s.l.]: Github, [s.d.]. Disponível em: <https://github.com/nok/sklearn-porter>.
- pickle — Python object serialization. Python 2.7.17 documentation. Disponível em: <https://docs.python.org/2/library/pickle.html>.
- Persistence. joblib 0.14.1.dev0 documentation. Disponível em: <https://joblib.readthedocs.io/en/latest/persistence.html>. Acesso em: 11 mar. 2020.