# 3-trimestre-projeto-api
Plano de ataque do 3° trimestre

# Projeto - Identificação e Extração de Dados de Contratos

**Equipe:**  
- Artur Flacon  
- Eduardo Ceciliato  
- Mateus Stainer
- Pedro H. Lino

---

## Planos de Ataque

### Modelagem (Aplicativo Mobile)
- Autenticação de usuário e telas de cadastro e Login.  
- Upload e leitura da resposta da aplicação com Flutter e SQLite.  
- Dashboard sobre todos os dados extraídos dos contratos.  

### Flutter
- Autenticação de usuários em conjunto com a API (telas de cadastro e login).  
- Página para envio do PDF.  
- Página de Dashboard com respostas da API Java (Gemini) (ou dados mockados/firebase).
- Banco de dados (**sqflite**).  

### Java
- Autenticação de usuários.  
- Entidade com PDFs salvos.  
- Arquitetura **MVC** com resposta para Flutter.  

---

## Mitigação de Riscos
- Muito foco na automação das IAs.  
- Atenção na pontualidade dos checks.  
- Priorizar Flutter inicialmente, sem foco imediato em uma API Java ou IA com Gemini.  

---

## Definições e planejamento

### 4 classes

- Cada um vai fazer um crud
- Usuario: Mateus
- Contrato: Eduardo
- ModeloIA e gemini: Pedro
- Recado: artur

## Diagrama de Classes

```mermaid
classDiagram
    class Usuario {
        - Long id
        - String nome
        - String email
        - String senha
    }

    class Contrato {
        - Long id
        - String nomeArquivo
        - String tipoSociedade
        - String clausulas
        - String areaAtuacoes
        - String socios
        - String jsonIA
        - Date dataUpload
        - bool analisado
        - String caminhoArquivo
    }

    class Recado {
        - Long id
        - String nome
        - String erroIA
    }

    class ModeloIA {
        - Long id
        - String nome
        - String chave
    }

    Usuario "1" --> "*" Contrato
    Usuario "1" --> "*" ModeloIA
    Usuario "1" --> "*" Recado
