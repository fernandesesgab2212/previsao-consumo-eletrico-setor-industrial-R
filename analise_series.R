#-------------------------------------------------------#
# /Project Gabriel  ====
# /Time series ====
# Script detalhado (ARIMA & NNAR models)
#-------------------------------------------------------#
rm(list=ls())

# ==== Diretório dos dados ====
setwd("C:/data science/ic")

# ==== Pacotes ====
library("fpp3")
library(corrplot)
library(RColorBrewer)
library(readxl)
library(fable)
library(feasts)
library(forecast)  

# ==== Base de dados ====
df = read.csv2('dados.csv', header = T, check.names = F, sep = ";", dec = ",", skip = 0)

# ==== Transformando em série temporal ===
ts.dados = ts(df$Consumo, start = c(2004,1), end= c(2023,12), frequency = 12)

# ==== Análise Exploratória ====
x11();
plot(ts.dados, main = '', ylab = 'Consumo de energia elétrica (MWh)', xlab = 'Tempo',
     xlim = c(2004, 2024), type = "l", col = 'blue', lwd = 2)

summary(ts.dados)

# ==== Boxplots por ano e por mês ====
df.ts1 <- window(ts.dados, start = 2004, end = c(2023,12))
dados_tabulado <- matrix(data = df.ts1, nrow = 12, ncol = 20)
for(i in 1:20) {
  dados_tabulado[,i] <- df.ts1[(12*(i-1)+1):(12*i)]
}
dados_tabulado1 <- as.data.frame(dados_tabulado)
colnames(dados_tabulado1) <- seq(2004, 2023)

x11(); par(cex.lab=1.2, cex.axis=1.4)
boxplot(dados_tabulado1, axes = T, las = 3, xlab = '', ylab = 'Consumo de energia elétrica (MWh)', main = '')

x11()
layout(1:2)
plot(aggregate(ts.dados), ylab='Consumo de energia elétrica (MWh)', xlab = "Tempo", main = '')
boxplot(ts.dados ~ cycle(ts.dados), ylab='Consumo de energia elétrica (MWh)', xlab = "Meses", main = '')

# ==== Matriz de Correlação ====
M <- cor(dados_tabulado1[,1:20])
x11(); corrplot(M, type="upper", order="hclust", col=brewer.pal(n=8, name="RdYlBu"))

# ==== Decomposição ====
decomp <- stl(ts.dados, s.window = "periodic")
trend <- decomp$time.series[, "trend"]
seasonal <- decomp$time.series[, "seasonal"]
remainder <- decomp$time.series[, "remainder"]

x11(); par(mfrow = c(3, 1))
plot(trend, main = "Componente de Tendência", col = "blue", ylab = "Valor", xlab = "Tempo")
plot(seasonal, main = "Componente Sazonal", col = "red", ylab = "Valor", xlab = "Tempo")
plot(remainder, main = "Componente de Resíduo", col = "brown", ylab = "Valor", xlab = "Tempo")

# ==== ACF ====
x11()
acf(ts.dados,lag.max = 12, main = "Função de Autocorrelação da Série Temporal")

# ==== Conjunto de treino e teste ====
treino = window(ts.dados, start = c(2004,1), end = c(2020, 12))
teste = window(ts.dados, start = c(2021, 1), end = c(2023, 12))

x11(); plot(treino)

# ==== MODELOS ====
# Modelo Ingênuo Sazonal
modelo_ingenuo_sazonal <- snaive(treino, h = length(teste))

# Modelo ARIMA
modelo_ajustado_arima <- auto.arima(treino)
print(modelo_ajustado_arima)        # Detalhes completos do ARIMA
print(modelo_ajustado_arima$arma)   # Vetor dos parâmetros

modelo_arima <- forecast(modelo_ajustado_arima, h = length(teste))

# Modelo NNAR
modelo_nnar <- nnetar(treino)
print(modelo_nnar)                  # Detalhes do modelo NNAR
modelo_nnar_forecast <- forecast(modelo_nnar, h = length(teste))

# ==== Acurácia ====
accuracy(modelo_ingenuo_sazonal, teste) %>% round(3)
accuracy(modelo_arima, teste) %>% round(3)
accuracy(modelo_nnar_forecast, teste) %>% round(3)

# ==== Previsões como séries temporais ====
ts_data_nnar <- ts(modelo_nnar_forecast$mean, start=c(2021, 1), end = c(2023, 12), frequency=12)
ts_data_sazonal <- ts(modelo_ingenuo_sazonal$mean, start=c(2021, 1), frequency=12)
ts_data_arima <- ts(modelo_arima$mean, start=c(2021, 1), frequency=12)

# ==== PLOTS ====
# Treino e Teste
x11()
plot(treino, main = "Conjunto de Treino e Teste", col = 'blue', type='l', ylab = "Consumo", xlab = "Ano")
lines(teste, col = 'red', type='l', lty=1, lwd = 2)
legend("topleft", legend = c("Treino", "Teste"), col = c("blue", "red"), lwd = 2)

# Previsões dos modelos
x11()
plot(ts.dados, main = '', ylab = 'Consumo de energia elétrica (MWh)', xlab = 'Tempo (Meses)', 
     xlim = c(2021, 2024), type = "l", col = 'blue', lwd = 1, cex.lab = 1.5, cex.axis = 1.2)
lines(ts_data_nnar , col = "red", lwd = 2, lty = 1)
lines(ts_data_arima , col = "green", lwd = 2, lty = 1)
lines(ts_data_sazonal , col = "brown", lwd = 2, lty = 1)

legend("topleft", legend = c("Série Temporal", "Modelo Ingênuo Sazonal", "Modelo ARIMA", "Modelo NNAR"),
       col = c("blue","brown", "green", "red"), lty = 1, lwd = 2, cex = 1.0, bty = "n")


# 1. Identificar o último valor e tempo do Treino
ultimo_valor_treino = treino[length(treino)]
tempo_inicio_teste = time(teste)[1]
tempo_fim_treino = time(treino)[length(treino)]

# 2. Criar um ponto de conexão
# Este vetor deve ser [último ponto do treino, primeiro ponto do teste]
ponto_conexao_y = c(ultimo_valor_treino, teste[1])
ponto_conexao_t = c(tempo_fim_treino, tempo_inicio_teste)

# 3. Plotar o Treino (Azul)
x11()
plot(treino, 
     main = "", 
     col = 'blue', 
     type='l', 
     ylab = "Consumo", 
     xlab = "Ano",
     lwd = 2
     # Garante que o eixo X e Y comporte toda a série
     # O 'xlim' deve ser ajustado para incluir o 'teste'
     # xlim = range(time(treino), time(teste)) 
)

# 4. Adicionar a Conexão (Linha do último ponto azul ao primeiro ponto vermelho)
# Isso garante que a linha final do treino seja coberta/conectada corretamente
lines(ponto_conexao_t, 
      ponto_conexao_y, 
      col = 'red', 
      lwd = 2
)

# 5. Adicionar o restante da Série de Teste (Vermelho)
# Isso plota a linha de Janeiro/2021 em diante
lines(teste, 
      col = 'red', 
      type='l', 
      lty = 1, 
      lwd = 2
)

# 6. Adicionar a Legenda
legend("topleft", 
       legend = c("Treino 2004-2020", "Teste 2021-2023"), 
       col = c("blue", "red"), 
       lwd = 2
)
