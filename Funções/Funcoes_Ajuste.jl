__________________________________________________________________________________________________________________________
# Definição e Inicialização dos Pacotes utilizados
using CSV # Importação e manipulação de planilhas no formato .CSV
using DataFrames # Manipulação de tabelas de dados
using Distributions # Tabelas e recursos voltados a distribuições de testes (T,Z,Qi-Quadrado...)
using LinearAlgebra # Recursos voltados a manipulação de matrizes
using LsqFit # Pacote para regressão não linear
using Plots # Criação e Manipulação de gráficos
using REPL.TerminalMenus # Modo interativo do REPL voltada a manipulação de Menus
__________________________________________________________________________________________________________________________
# Seleção da Base de dados em .CSV a ser importada
dados = CSV.read("Dados.csv", DataFrame)
__________________________________________________________________________________________________________________________
# Definição da função príncipal e subfunções a serem utilizadas no projeto
function Regressao(dados::DataFrame)
    clear() = run(`cmd /c cls`) # Limpa o terminal
    # Conversão de DataFrame para matriz
    Mdados = Matrix(dados)
    # Inicialização das variaveis auxiliares
    SizeV = size(dados, 1)
    SizeH = size(dados, 2)
    # Inicialização das variáveis principais Y, D, H
    Y, D, H = [Vector{Float64}(undef, SizeV) for X in 1:3]
    # Definição das informações do menu voltado à seleção das variaveis
    colunas = [names(dados); "Dados não informados"]
    variaveis = ["Y", "D", "H"]
    menu2 = RadioMenu(colunas, pagesize = size(colunas, 1))
    # Define a ordem de definição das variáveis, sendo 1º Y, 2º D e 3º H
    for i in 1:3
        clear()
        choice = request("Selecione os dados referentes a variável $(variaveis[i,1]) ", menu2)
        if i === 1
            Y = Vector{Float64}(Mdados[:, choice])
        elseif i === 2
            D =  Vector{Float64}(Mdados[:, choice])
        elseif i === 3
            if (choice >= 1) && (choice <= SizeH)
                H = Vector{Float64}(Mdados[:, choice])
            else
                H = Vector{Float64}(zeros(SizeV))
            end
        else
            println("Erro ao definir variáveis")
        end
    end
    # Possibilidade de Modelos a serem utilizados pela função
    # Sendo os modelos de 1 a 13 lineares
    # Sendo os modelos de 14 a 20 não lineares
    Modelos = [
                "Y = β0 + β1*d + ϵ",  
                "Y = β0 + β1*(d²) + ϵ",  
                "Y = β0 + β1*(d²H) + ϵ",         
                "Y = β0 + β1*ln(d) + ϵ", 
                "Y = β0 + β1*(1/d) + ϵ",
                "Y = β0 + β1*(1/d²) + ϵ",
                "Y = β0 + β1*(d) + β2*(d²) + ϵ",
                "Y = β0 + β1*(d) + β2*(1/d) + ϵ",
                "Y = β0 + β1*d² + β2*(d²*h) + β3*(h) + ϵ",
                "Y = β0 + β1*d + β2*d² + β3*(d*h) + β4(d²*h) + ϵ",
                "Y = β0 + β1*d + β2*d² + β3*(d*h²) + β4*(d²*h) + ϵ",        
                "Y = β0 + β1*d² + β2*(d²*h) + β3*(h²) + β4*(d*h²) + ϵ",
                "Y = β0 * dᵝ¹ + ϵ",
                "Y = β0 * (1/d)ᵝ¹",
                "Y = β0 * (d²*h)ᵝ¹ + ϵ",
                "Y = β0 * (d*h²)ᵝ¹ + ϵ", 
                "Y = β0 * (dᵝ¹) * (1/d)ᵝ²",
                "Y = β0 * (d)ᵝ¹ * (h)ᵝ² + ϵ"
               ]
    # Define e apresenta o menu de seleção de modelos
    menu = RadioMenu(Modelos, pagesize = 10)
    clear()
    global choice = request("Selecione o Modelo da Regressão: ", menu)
    # Define o resultado da seleção realizada no menu de modelos
    if choice <= 18 # Se selecionado um modelo de 1 a 13
        clear()
        println("O modelo selecionado é: ", Modelos[choice], "!")
        # Sendo selecionado um modelo na escala natural, não há alteração na variavel Y
        Y = Y
        # Altera a variável X conforme o modelo escolhido na escala natural
        if choice === 1
            X = [ones(SizeV) D]
        elseif choice === 2
            X = [ones(SizeV) (D.^2)]
        elseif choice === 3
            X = [ones(SizeV) ((D.^2).*H)]
        elseif choice === 4
            X = [ones(SizeV) (log.(D))]
        elseif choice === 5
            X = [ones(SizeV) (1.0./D)]
        elseif choice === 6
            X = [ones(SizeV) (1.0./(D.^2))]
        elseif choice === 7
            X = [ones(SizeV) D (D.^2)]
        elseif choice === 8
            X = [ones(SizeV) D (1.0./D)]
        elseif choice === 9
            X = [ones(SizeV) (D.^2) H ((D.^2).*H)]
        elseif choice === 10
            X = [ones(SizeV) D (D.^2) (D.*H) ((D.^2).*H)]
        elseif choice === 11
            X = [ones(SizeV) D (D.^2) (D.*(H.^2)) ((D.^2).*H)]
        elseif choice === 12
            X = [ones(SizeV) (D.^2) ((D.^2).*H) (H.^2) (D.*(H.^2))]
        elseif choice === 13
            X = (D) # Define a variável X 
            m13(X,p) = p[1] * X[:,1].^p[2] # Define a função de ajuste
            p0 = [0.5, 0.5] # Parâmetros iniciais
            m = m13 # Atribui a função m8 a variável m
        elseif choice === 14
            X = (1.0./D) # Define a variável X 
            m14(X,p) = p[1] * X[:,1].^p[2] # Define a função de ajuste
            p0 = [0.5, 0.5] # Parâmetros iniciais
            m = m14 # Atribui a função m8 a variável m
        elseif choice === 15
            X = ((D.^2).*H) # Define a variável X 
            m15(X,p) = p[1] * X[:,1].^p[2] # Define a função de ajuste
            p0 = [0.01, 0.01] # Parâmetros iniciais
            m = m15 # Atribui a função m8 a variável m
        elseif choice === 16
            X = (D.*(H.^2)) # Define a variável X 
            m16(X,p) = p[1] * X[:,1].^p[2] # Define a função de ajuste
            p0 = [0.01, 0.01] # Parâmetros iniciais
            m = m16 # Atribui a função m8 a variável m
        elseif choice === 17
            X = [D (1.0./D)] # Define a variável X 
            m17(X,p) = p[1] * X[:,1].^p[2] .* X[:,2].^p[3] # Define a função de ajuste
            p0 = [0.5, 0.5, 0.5] # Parâmetros iniciais
            m = m17 # Atribui a função m8 a variável m
        elseif choice === 18
            X = [D H] # Define a variável X 
            m18(X,p) = p[1] * X[:,1].^p[2] .* X[:,2].^p[3] # Define a função de ajuste
            p0 = [0.5, 0.5, 0.5] # Parâmetros iniciais
            m = m18 # Atribui a função m8 a variável m
        else
            println("Falha ao definir modelo para regressão!")
        end
    end
    if choice < 13
        global β = (inv(X'X))*X'*Y  # Cálculo dos coeficientes
        λ = Y - X*β  # Cálculos das estimativas        
        n = size(X,1) # Variável auxiliar referente ao número de observaçoes
        λporc = (λ./Y)*100 # Cálculo dos resíduos em %
        GLReg = size(β,1) - 1 # Graus de liberdade da regressão
        GLTot = n-1  # Graus de liberdade do total        
        GLRes = GLTot-GLReg # Graus de liberdade do resíduo
        SQReg = β'*X'*Y-(sum(Y)^2)/n # Soma de quadrados dos resíduos corrigido                                 
        SQTot = Y'*Y - (sum(Y)^2)/n # Soma de quadrados do total corrigido
        SQRes = SQTot - SQReg # Soma de quadrados da regressão
        QMRes = SQRes/GLRes # Quadrado médio do resíduo
        QMReg = SQReg/GLReg # Quadrado médio da regressão
        F = round(QMReg/QMRes, digits = 5) # F calculado
        R²aj = round(1-(QMRes/(SQTot/GLTot)), digits = 5) # Coeficiente de determinação ajustado
        R² = round(1-((SQRes/SQTot)), digits = 5) # Coeficiente de determinação
        R = round(sqrt(R²), digits = 5) # Coeficiente de correlação linear
        Syx = sqrt(QMRes) # Erro padrão da estimativa     
        Syxporc = ((Syx/(mean(Y)))*100) # Erro padrão da estimativa em porcentagem        
        result = DataFrame([Syx Syxporc R² R²aj F], ["Syx", "Syx(%)", "R²", "R²aj", "F calculado"])
        result2 = DataFrame([β], ["β"])
        println("\n Estatísticas da Regressão Linear", result)
        println("\n \n \n Resultados dos Estimadores da Regressão Linear", result2)
        ylabel_def = ["Volume (m³)", "Biomassa do Fuste (Kg)", "Biomassa da Copa (Kg)", "Biomassa Total (Kg)"]
        scatter(D, λ, border = :box, legend = false, title = "Gráfico de Resíduos - Modelo $choice", ylabel = ylabel_def[4], xlabel = "DAP (cm)")
        savefig("Gráficos de Resíduos/Biomassa Total/Gráfico de Resíduos - Modelo $choice.png")
    else
        fit = curve_fit(m,X,Y,p0)
        global β = coef(fit)
        if choice < 17
            model_ajust = (β[1] * (X[:,1].^β[2]))
        elseif choice >= 17 
            model_ajust = (β[1] * (X[:,1].^β[2]) .* X[:,2].^β[3])
        else
        end
        λ = Y - model_ajust
        λporc = (λ./Y)*100 # Cálculo dos resíduos em %
        corr = cor(Y, model_ajust)
        pseudoR² = corr^2
        n = size(X,1)      
        GLReg = size(β,1) - 1 # Graus de liberdade da regressão
        GLTot = n-1  # Graus de liberdade do total        
        GLRes = GLTot-GLReg # Graus de liberdade do resíduo
        SQRes = sum(λ.^2) # Soma de quadrados dos resíduos corrigido        
        QMRes = SQRes/GLRes # Quadrado médio do resíduo
        R² = pseudoR²
        Syx = sqrt(QMRes) # Erro padrão da estimativa     
        Syxporc = ((Syx/(mean(Y)))*100) # Erro padrão da estimativa em porcentagem        
        result = DataFrame([Syx Syxporc R²], ["Syx", "Syx(%)", "R²"])
        result2 = DataFrame([β], ["β"])
        println("\n Estatísticas da Regressão Linear", result)
        println("\n \n \n Resultados dos Estimadores da Regressão Linear", result2)
        ylabel_def = ["Volume (m³)", "Biomassa do Fuste (Kg)", "Biomassa da Copa (Kg)", "Biomassa Total (Kg)"]
        scatter(D, λ, border = :box, legend = false, title = "Gráfico de Resíduos - Modelo $choice", ylabel = ylabel_def[4], xlabel = "DAP (cm)")
        savefig("Gráficos de Resíduos/Biomassa Total/Gráfico de Resíduos - Modelo $choice.png")
    end
end
__________________________________________________________________________________________________________________________
# Execução da função Modelagem_Biomassa em relação ao conjuntos DADOS

est = Regressao(dados)