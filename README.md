# ⚡ Previsão de Consumo de Energia Elétrica (2004-2023)

Este projeto realiza uma análise comparativa entre métodos estatísticos clássicos e Inteligência Artificial para prever o consumo de energia elétrica (MWh). O estudo abrange dados mensais de **Janeiro de 2004 a Dezembro de 2023**, com foco em identificar sazonalidade e tendências de longo prazo.

## 🛠️ Tecnologias Utilizadas
* **Linguagem**: R
* **Bibliotecas Principais**: `forecast`, `fpp3`, `corrplot`, `nnetar`.

## 📊 Metodologia Estatística

O pipeline de análise foi estruturado nas seguintes etapas:

### 1. Análise Exploratória (EDA)
* **Decomposição STL**: Separação da série temporal em componentes de **Tendência**, **Sazonalidade** e **Resíduo** para isolar o comportamento estocástico.
* **Matriz de Correlação**: Análise de autocorrelação para identificar lags significativos.

### 2. Modelagem Preditiva
Foram implementados e comparados três modelos distintos:

* **ARIMA (AutoRegressive Integrated Moving Average)**: 
  Modelagem baseada na estacionariedade da série, capturando a dinâmica linear.
  $$X_t = c + \epsilon_t + \sum_{i=1}^{p} \phi_i X_{t-i} + \sum_{j=1}^{q} \theta_j \epsilon_{t-j}$$

* **NNAR (Neural Network AutoRegression)**: 
  Utilização de **Redes Neurais Artificiais** (Feed-Forward) para capturar não-linearidades complexas na demanda de energia. O modelo utiliza lags defasados como inputs da rede.

* **Snaive (Seasonal Naive)**: 
  Modelo de base (baseline) que replica a observação da mesma estação do ano anterior, servindo como métrica de comparação de performance.

### 3. Validação (Backtesting)
Os dados foram divididos em:
* **Treino**: Jan/2004 - Dez/2020 (Aprendizado do modelo)
* **Teste**: Jan/2021 - Dez/2023 (Validação "Out-of-sample")

A acurácia foi medida comparando as previsões com os dados reais do conjunto de teste.

## 🚀 Como Executar
1. Clone este repositório.
2. Abra o script `analise_series_temporais.R` no RStudio.
3. Certifique-se de instalar os pacotes necessários:
   ```R
   install.packages(c("fpp3", "corrplot", "readxl", "forecast"))
