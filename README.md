# Tópicos Especiais em Inteligência Computacional

Esse repositório contempla os códigos utilizados na disciplina CPC802 da COPPE/UFRJ que aborda a execução de um projeto utilizando Inteligência Computacional. A disponibilização do código aqui presente tem o objetivo de facilitar futuras consultas nessa área, assim como auxiliar futuros estudantes da disciplina.

## Trabalho

A disciplina de Tópicos Especiais em Inteligência Computacional possui um trabalho que deve ser desenvolvido como projeto ao longo do período acadêmico. O objetivo do mesmo é ser um trabalho investigativo sobre as tecnologias utilizadas relacionadas com o tema, cujo assunto é de interesse do aluno sob orientação do professor.

Duas propostas de trabalho foram realizadas:
1. Análise de temas em conteúdo não estruturado: dentro de uma amostra de conteúdo não estruturado (comentários, entrevistas), vamos analisar os temas predominantes no seu conteúdo.
2. Busca por abuso em protocolos da web: construir um sistema para determinar se uma comunicação através de um protocolo pode estar sob abuso ou não. A proposta é minimizar as comunicações que precisam ser inspecionadas por um analisador de protocolo (no caso, um Web Application Firewall).

Devido a ausência de dados para seguir com a primeira proposta, o tema desenvolvido nesse trabalho é o segundo: `Busca por abuso em protocolos da web`.

### Preparação dos dados

Uma parte relevante de um trabalho envolvendo Inteligência Computacional decorre da necessidade de dados de boa qualidade para avaliações. Dessa forma, para detectar abusos usando Inteligência Computacional, foi necessário recorrer a uma base de dados de ataques e URLs maliciosas com o objetivo de criar um conjunto de dados que pudesse ser trabalhado na disciplina.

Uma das fontes onde esse conjunto de dados pode ser obtida é através dos eventos registrados em um Web Application Firewall, como o [ModSecurity](https://modsecurity.org/). Essa ferramenta é capaz de gerar eventos quando uma requisição HTTP possui correspondência com critérios previamente definidos em regras. Assim podemos usar um conjunto de regras ([como as padronizadas pela OWASP](https://github.com/SpiderLabs/owasp-modsecurity-crs)) para capturar eventos e montar um conjunto de dados para análise.

Embora o ModSecurity suporte gerar esses eventos em formato estruturado (como JSON), grande parte dos arquivos obtidos para o trabalho se encontravam no formato semi-estuturado. Para utilizar essas informações, foi necessário construir um script que convertia o formato para um mais fácil de trabalhar, no caso JSON.

Para executar o script (se encontra na pasta `scripts`), coloque os múltiplos arquivos com eventos na pasta `dataset/archive` e depois execute:

```
perlbrew exec "carton install"
perlbrew exec "carton exec perl modsecurity-seriallog-to-jsonlog.pl"
```

Quando a execução do script for concluída, uma saída semelhante a mostrada a seguir será retornada:
```
Foram processados 204753 eventos.
True: 46699
False: 168880
```

Serão gerados os arquivos `dataset/goodqueries.json` e `dataset/badqueries.json`. Esses arquivos possuem uma lista de URLs (sem o hostname). Para ter o resultado em JSON ao invés de apenas a linha com a URL, descomente as linhas indicadas no script (189 e 193).

### Testes com sklearn

Umas das primeiras abordagens para o uso de Inteligência Computacional é utilizar classificadores. Como o escopo do problema trabalhado aqui indica que um evento do protocolo pode ser analisado mais de uma vez (pelo classificador e pelo analisador de protocolo), vamos focar em classificadores que podem ser mais performáticos. Dessa forma, vamos trabalhar inicialmente com:
- Regressão logística
- SVM
- Perceptron

Além do uso de classificadores binários, vamos fazer testes com diferentes formas de vetorização das URLs. Dessa forma, vamos trabalhar inicialmente com:
- TF-IDF em caracteres
- TF-IDF em palavras de acordo com separadores usados no protocolo HTTP

### Conjunto de dados públicos

Alguns conjuntos de dados públicos foram utilizados durante os testes e se encontram disponíveis para uso também. A seguir um lista com os dados utilizados e sua respectiva origem:
- dataset/badqueries.txt: https://github.com/hugo-glez/bsidescdmx2019/tree/117e234ae275c7d50568d87b2ef660fcfb056b3b/datasets/Fwaf-ML
- dataset/goodqueries.txt: https://github.com/hugo-glez/bsidescdmx2019/tree/117e234ae275c7d50568d87b2ef660fcfb056b3b/datasets/Fwaf-ML

### Modelos treinados

Alguns modelos foram treinados durante esse trabalho e se encontram disponibilizados aqui como referência. Esses modelos foram exportados utilizando a biblioteca [joblib](https://joblib.readthedocs.io/en/latest/).
Você pode usar o Jupyter Notebook disponível em `models/load_model_from_joblib` para carregar os modelos e testar com seu próprio dataset.

A seguir uma lista com os modelos que se encontram na pasta `models` e a descrição de cada um deles:
- models/cpc802-20200125-210918.sav (modelo sem vetorizador disponível): modelo treinado utilizando um dataset privado com Regressão Logística e vetorização TF-IDF em caracteres. Possui acurácia de 0.9953 no dataset público (`dataset/badqueries.txt` e `dataset/goodqueries.txt`) e 0.9727 no dataset privado.
- models/cpc802-20200125-210051.sav (modelo sem vetorizador disponível): modelo treinado utilizando o dataset público (`dataset/badqueries.txt` e `dataset/goodqueries.txt`) com Regressão Logística e vetorização TF-IDF em caracteres. Possui acurácia de 0.9999 no dataset público (`dataset/badqueries.txt` e `dataset/goodqueries.txt`) e 0.9010 no dataset privado.
- models/cpc802-20200127-220629-word.sav (modelo sem vetorizador disponível): modelo treinado utilizando o dataset público (`dataset/badqueries.txt` e `dataset/goodqueries.txt`) com Regressão Logística e vetorização TF-IDF em palavras (separadores `/`,`=`,`.`,`=`,`&`,`?`). Possui acurácia de 0.9997 no dataset público (`dataset/badqueries.txt` e `dataset/goodqueries.txt`) e 0.9295 no dataset privado.
- models/cpc802-20200127-221847-word.sav (modelo sem vetorizador disponível): modelo treinado utilizando um dataset privado com Regressão Logística e vetorização TF-IDF em palavras (separadores `/`,`=`,`.`,`=`,`&`,`?`). Possui acurácia de 0.9878 no dataset público (`dataset/badqueries.txt` e `dataset/goodqueries.txt`) e 0.9729 no dataset privado.
- models/cpc802-20200128-223107-word.sav (vetorizador `models/cpc802-20200128-223107-word.vectorizer`): modelo treinado utilizando o dataset público (`dataset/badqueries.txt` e `dataset/goodqueries.txt`) com Regressão Logística e vetorização TF-IDF em palavras (separadores `/`,`=`,`.`,`=`,`&`,`?`,` `, `<`, `>`, `(`, `)`, `;`). Possui acurácia de 0.9997 no dataset público (`dataset/badqueries.txt` e `dataset/goodqueries.txt`) e 0.9099 no dataset privado.
- models/cpc802-20200129-223546-word.sav (vetorizador `models/cpc802-20200129-223546-word.vectorizer`): modelo treinado utilizando um dataset privado com Regressão Logística e vetorização TF-IDF em palavras (separadores `/`,`=`,`.`,`=`,`&`,`?`,` `, `<`, `>`, `(`, `)`, `;`). Possui acurácia de 0.9945 no dataset público (`dataset/badqueries.txt` e `dataset/goodqueries.txt`) e 0.9728 no dataset privado.

A seguir, temos modelos treinados usando SVM e char:
- models/cpc802-20200204-002901-lsvm-char.sav (vetorizador `models/cpc802-20200204-002901-lsvm-char.vectorizer`): modelo treinado utilizando o dataset público (`dataset/badqueries.txt` e `dataset/goodqueries.txt`) com Linear SVM e vetorização TF-IDF em caracteres. Possui acurácia de 0.9999 no dataset público (`dataset/badqueries.txt` e `dataset/goodqueries.txt`) e 0.8294 no dataset privado.
- models/cpc802-20200204-003506-lsvm-char.sav (vetorizador `models/cpc802-20200204-003506-lsvm-char.vectorizer`): modelo treinado utilizando um dataset privado com Linear SVM e vetorização TF-IDF em palavras. Possui acurácia de 0.9900 no dataset público (`dataset/badqueries.txt` e `dataset/goodqueries.txt`) e 0.9792 no dataset privado.


A seguir, temos modelos treinados usando SVM e words:
- models/cpc802-20200203-235821-lsvm-word.sav (vetorizador `models/cpc802-20200203-235821-lsvm-word.vectorizer`): modelo treinado utilizando o dataset público (`dataset/badqueries.txt` e `dataset/goodqueries.txt`) com Linear SVM e vetorização TF-IDF em palavras (separadores `/`,`=`,`.`,`=`,`&`,`?`,` `, `<`, `>`, `(`, `)`, `;`). Possui acurácia de 0.9995 no dataset público (`dataset/badqueries.txt` e `dataset/goodqueries.txt`) e 0.8092 no dataset privado.
- models/cpc802-20200203-000837-lsvm-word.sav (vetorizador `models/cpc802-20200203-000837-lsvm-word.vectorizer`): modelo treinado utilizando um dataset privado com Linear SVM e vetorização TF-IDF em palavras (separadores `/`,`=`,`.`,`=`,`&`,`?`,` `, `<`, `>`, `(`, `)`, `;`). Possui acurácia de 0.9894 no dataset público (`dataset/badqueries.txt` e `dataset/goodqueries.txt`) e 0.9811 no dataset privado.

### Resultados consolidados

A seguir ilustramos em uma tabela a acurácia dos modelos levando em conta os datasets que foram utilizados na sua geração. O primeiro valor representa a acurácia levando em conta o dataset de treinamento, o segundo valor, leva em conta a acurácia no outro dataset.

|               | Dataset privado | Dataset público |
|---------------|-----------------|-----------------|
| LogReg + char |  0.9727/0.9953  |  0.9999/0.9010  |
| LogReg + word |  0.9728/0.9945  |  0.9997/0.9099  |
|  LSVM + char  |  0.9792/0.9900  |  0.9999/0.8294  |
|  LSVM + word  |  0.9811/0.9894  |  0.9995/0.8092  |


## Referências

A seguir, algumas referências utilizadas durante o trabalho:
- NARKHEDE, Sarang. Understanding Logistic Regression. Medium. Disponível em: <https://towardsdatascience.com/understanding-logistic-regression-9b02c2aec102>.
- sklearn.linear_model.LogisticRegression — scikit-learn 0.22.1 documentation. Disponível em: <https://scikit-learn.org/stable/modules/generated/sklearn.linear_model.LogisticRegression.html>.
- GONZALEZ, Hugo. Cloud Machine Learning for Cybersecurity. [s.l.]: Github, [s.d.]. Disponível em: <https://github.com/hugo-glez/bsidescdmx2019>.
- BROWNLEE, Jason. Save and Load Machine Learning Models in Python with scikit-learn - Machine Learning Mastery. Machine Learning Mastery. Disponível em: <https://machinelearningmastery.com/save-load-machine-learning-models-python-scikit-learn/>.
- AHMAD, Faizan. Machine Learning driven Web Application Firewall. [s.l.]: Github, [s.d.]. Disponível em: <https://github.com/faizann24/Fwaf-Machine-Learning-driven-Web-Application-Firewall>.
- AHMAD, Faizan. Using machine learning to detect malicious URLs. [s.l.]: Github, [s.d.]. Disponível em: <https://github.com/faizann24/Using-machine-learning-to-detect-malicious-URLs>.