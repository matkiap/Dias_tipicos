using CSV
using Dates
using DataFrames
using Statistics

# Função para ler os dados do arquivo CSV
function ler_dados_csv(caminho_arquivo)
    return CSV.read(caminho_arquivo, DataFrame)
end

# Função para separar os dados por usina e dia da semana
function separar_dados_por_intervalo(dados)
    dados_por_usina = Dict{String, Dict{String, Dict{String, Float64}}}()

    # Extrair o nome das usinas do DataFrame, excluindo as colunas 'data' e 'hora'
    usinas = setdiff(names(dados), ["data", "hora"])

    # Criar um dicionário para cada usina
    for usina in usinas
        dados_por_usina[usina] = Dict{String, Dict{String, Float64}}()
    end

    # Preencher os dados por usina e dia da semana
    for linha in eachrow(dados)
        data = Dates.Date(linha["data"], "mm/dd/yyyy")
        dia_semana = Dates.dayname(data)

        for usina in usinas
            valor = linha[usina]

            # Verificar se o dia da semana já existe no dicionário da usina
            if !(dia_semana in keys(dados_por_usina[usina]))
                dados_por_usina[usina][dia_semana] = Dict{String, Float64}()
            end

            # Armazenar o valor na hora correspondente
            dados_por_usina[usina][dia_semana][linha["hora"]] = valor
        end
    end

    return dados_por_usina
end

# Função para calcular as médias por usina e dia da semana
function calcular_medias(dados_por_usina)
    medias_por_usina = Dict{String, Dict{String, Dict{String, Float64}}}()

    for (usina, dados_usina) in dados_por_usina
        medias_por_usina[usina] = Dict{String, Dict{String, Float64}}()

        for (dia_semana, dados_dia) in dados_usina
            medias_por_usina[usina][dia_semana] = Dict{String, Float64}()

            # Obter todas as horas em ordem crescente
            horas_ordenadas = sort(collect(keys(dados_dia)))

            # Calcular a média para cada hora do dia
            for hora in horas_ordenadas
                valores = get(dados_dia, hora, [])  # Verificar se a hora existe no dicionário
                media = isempty(valores) ? NaN : mean(valores)  # Calcular a média ou definir NaN se não houver valores

                # Armazenar a média no dicionário de médias
                medias_por_usina[usina][dia_semana][hora] = media
            end
        end
    end

    return medias_por_usina
end

# Função para imprimir os resultados para cada usina
function imprimir_resultados_por_usina(medias_por_usina::Dict{String, Dict{String, Dict{String, Float64}}})
    for (usina, dados_usina) in medias_por_usina
        println("Usina: $usina")
        println("Dia da Semana | Hora | Média")
        println("-"^40)

        for (dia_semana, dados_dia) in dados_usina
            # Obter todas as horas em ordem crescente
            horas_ordenadas = sort(collect(keys(dados_dia)))

            # Imprimir as médias para cada hora do dia
            for hora in horas_ordenadas
                media = dados_dia[hora]
                println("$dia_semana | $hora | $media")
            end
        end

        println("-"^40)
    end
end

# Função para escrever os dados de média em um arquivo CSV para cada usina
function escrever_csv_por_usina(medias_por_usina, caminho_saida)
    for (usina, dados_usina) in medias_por_usina
        df = DataFrame(Dia_da_Semana = String[], Hora = String[], Média = Float64[])

        for (dia_semana, dados_dia) in dados_usina
            horas_ordenadas = sort(collect(keys(dados_dia)))

            for hora in horas_ordenadas
                push!(df, [dia_semana, hora, dados_dia[hora]])
            end
        end

        # Ordenar o DataFrame por Dia_da_Semana e Hora
        sort!(df, [:Dia_da_Semana, :Hora])

        # Escrever o DataFrame em um arquivo CSV
        caminho_arquivo = joinpath(caminho_saida, "$usina.csv")
        CSV.write(caminho_arquivo, df)
    end
end


# Ler os dados do arquivo CSV
caminho_arquivo = raw"C:\Users\franc\OneDrive\Área de Trabalho\ESTÁGIO_PSR\Modelo de demanda-Foresight\primeira atividade média horas\20222.csv"
dados = ler_dados_csv(caminho_arquivo)

# Separar os dados por usina e dia da semana
dados_por_usina = separar_dados_por_intervalo(dados)

# Calcular as médias por usina e dia da semana
medias_por_usina = calcular_medias(dados_por_usina)

# Imprimir os resultados para cada usina
imprimir_resultados_por_usina(medias_por_usina)

# Caminho de saída para os arquivos CSV
caminho_saida = raw"C:\Users\franc\OneDrive\Área de Trabalho\ESTÁGIO_PSR\Modelo de demanda-Foresight\primeira atividade média horas\saida_codigo_medias_15_minutos"

# Escrever os dados de média em um arquivo CSV para cada usina
escrever_csv_por_usina(medias_por_usina, caminho_saida)
