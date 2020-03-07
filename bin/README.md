# Modelos exportados

Os seguintes códigos foram gerados (e modificados) a partir da bilioteca sklearn-porter. A finalidade deles é avaliar o custo de implementação da predição de modelos já treinados em outras plataformas que não suportem Python.

## Exportando modelos

Para exportar modelos, é necessário ao mínimo tê-los salvos em um formato de serialização compatível com a biblioteca. É possível também exportar os modelos e código de predição sem ter os arquivos exportados, mas essa não foi a abordagem seguida nesse documento.

Para exportar os modelos, você pode usar as bibliotecas [pickle](https://docs.python.org/2/library/pickle.html) ou [joblib](https://joblib.readthedocs.io/en/latest/persistence.html). Veja mais detalhes em [Persistência com SKlearn](https://scikit-learn.org/stable/modules/model_persistence.html). Outra possibilidade é utilizar formatos como ONNX ou PMML (não abordados nesse documento).

Uma vez com o arquivo exportado e com o sklearn-porter instalado, você pode executar os seguintes comandos para exportar o modelo.

No caso de exportar para Go:
```
porter ../models/cpc802-20200209-030517-lsvm-word.sav --go --pipe >> model.go
```

No caso de exportar para C:
```
porter ../models/cpc802-20200209-030517-lsvm-word.sav --c --pipe >> model.c
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

## Conclusões

A exportação dos modelos ocorreu conforme esperado, mas a incapacidade de exportar a vetorização utilizada é um ponto de melhora. Para alguns testes e exemplos, tivemos que recorrer ao código em Python para gerar o vetor de teste.