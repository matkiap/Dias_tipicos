using CSV
using DataFrames
using Plots

# Função para converter minutos desde o início da semana para o dia da semana
function minutos_para_dia(minutos::Int)
    dias_da_semana = ["Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado", "Domingo"]
    dia_num = div(minutos, 24 * 60) % 7 + 1
    return dias_da_semana[dia_num]
end

# Ler o CSV para um DataFrame
caminho_arquivo = "C:\\Users\\franc\\OneDrive\\Área de Trabalho\\ESTÁGIO_PSR\\Modelo de demanda-Foresight\\primeira atividade média horas\\saida_codigo_medias_15_minutos\\DELAPAZ.csv"
df = CSV.read(caminho_arquivo, DataFrame)

# Mapear os dias da semana para números
dia_num = Dict("Monday" => 1, "Tuesday" => 2, "Wednesday" => 3, "Thursday" => 4, "Friday" => 5, "Saturday" => 6, "Sunday" => 7)
df[!, "Dia_Num"] = map(x -> dia_num[x], df[!, "Dia_da_Semana"])

# Mapear as horas para minutos
df[!, "Hora_Min"] = map(x -> parse(Int, split(x, ":")[1]) * 60 + parse(Int, split(x, ":")[2]), df[!, "Hora"])

# Adicionar uma coluna para representar o tempo em minutos desde o início da semana
df[!, "Minutos_Desde_Inicio_Semana"] = (df[!, "Dia_Num"] .- 1) * 24 * 60 + df[!, "Hora_Min"]

# Ordenar os dados pela coluna 'Minutos_Desde_Inicio_Semana'
sort!(df, [:Dia_Num, :Minutos_Desde_Inicio_Semana])

# Plotar os dados com o eixo x convertido para o dia da semana
plot(
    df[!, "Minutos_Desde_Inicio_Semana"], 
    df[!, "Média"], 
    xlabel="Dia da Semana", 
    xticks=(0:24*60:24*60*7, [minutos_para_dia(minutos) for minutos in 0:24*60:24*60*7]), 
    ylabel="Média", 
    title="Média ao longo da semana"
)
