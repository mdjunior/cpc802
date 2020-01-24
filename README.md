# Tópicos Especiais em Inteligência Computacional

Esse repositório contempla os códigos utilizados na disciplina CPC802 da COPPE/UFRJ que aborda a execução de um projeto utilizando Inteligência Computacional. A disponibilização do código aqui presente tem o objetivo de facilitar futuras consultas nessa área, assim como auxiliar futuros estudantes da disciplina.

## Trabalho

A disciplina de Tópicos Especiais em Inteligência Computacional possui um trabalho que deve ser desenvolvido como projeto ao longo do período acadêmico. O objetivo do mesmo é ser um trabalho investigativo sobre as tecnologias utilizadas relacionadas com o tema, cujo assunto é de interesse do aluno sob orientação do professor.

Duas propostas de trabalho foram realizadas:
1. Análise de temas em conteúdo não estruturado: dentro de uma amostra de conteúdo não estruturado (comentários, entrevistas), vamos analisar os temas predominantes no seu conteúdo.
2. Busca por abuso em protocolos da web: construir um sistema para determinar se uma comunicação através de um protocolo pode estar sob abuso ou não. A proposta é minimizar as comunicações que precisam ser inspecionadas por um analisador de protocolo (no caso, um Web Application Firewall).

Devido a ausência de dados para seguir com a primeira proposta, o tema desenvolvido nesse trabalho é o segundo `Busca por abuso em protocolos da web`.

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