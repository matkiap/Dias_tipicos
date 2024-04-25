using CSV
using Plots

# Função para plotar gráfico a partir de um arquivo CSV
function plotar_grafico(caminho_arquivo)
    # Ler os dados do arquivo CSV em um DataFrame
    df = CSV.read(caminho_arquivo, DataFrame)

    # Extrair as colunas do DataFrame
    horas = df[:, "Hora"]
    medias = df[:, "Média"]

    # Plotar o gráfico
    plot(horas, medias, xlabel="Hora", ylabel="Média", title="Média por Hora", label="Média", linewidth=2)
end

# Caminho do arquivo CSV
caminho_arquivo = raw"C:\Users\franc\OneDrive\Área de Trabalho\ESTÁGIO_PSR\Modelo de demanda-Foresight\primeira atividade média horas\saida_codigo_medias_15_minutos\DELAPAZ.csv"

# Plotar o gráfico
plotar_grafico(caminho_arquivo)
