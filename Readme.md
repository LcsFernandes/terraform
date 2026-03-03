# 🏗️ AWS Data Infrastructure (Terraform)

Este repositório contém a infraestrutura como código (IaC) para o pipeline de dados utilizando **AWS S3, Lambda e Glue**. A arquitetura foi desenhada seguindo os princípios de **Modularidade**, **Segurança** e **Separação de Preocupações**.

---

## 📂 Arquitetura de Pastas e Definições

Abaixo está a explicação detalhada de como o projeto está organizado e a função técnica de cada componente:

### 1. `env/` (Camada de Orquestração de Ambientes)
Esta pasta é o ponto de entrada para a execução do Terraform. Separamos por ambiente para garantir que mudanças em `dev` não afetem `prod`.
* **`main.tf`**: Atua como o "maestro". Ele chama os módulos e conecta as saídas de um (ex: ARN do S3) nas entradas de outro (ex: permissão da Lambda).
* **`terraform.tfvars`**: Arquivo de definição de valores. É aqui que você personaliza os nomes dos recursos para cada ambiente sem mexer na lógica do código.
* **`backend.tf`**: Configura o **Remote State**. Essencial para trabalho em equipe, ele garante que o estado da infraestrutura seja salvo em um Bucket S3 centralizado com trava (lock) via DynamoDB.

### 2. `modules/` (Camada de Blocos Reutilizáveis)
Aqui reside a inteligência técnica. Cada subpasta é um módulo independente que segue o padrão *Standard Module Structure*.
* **`s3/`**: Gerencia a criação de buckets, políticas de criptografia (SSE), versionamento e regras de ciclo de vida (Lifecycle Rules).
* **`lambda/`**: Provisiona a função, configura variáveis de ambiente, triggers (gatilhos) e, principalmente, as **IAM Roles** com o princípio de privilégio mínimo.
* **`glue/`**: Define os Crawlers para catalogação de dados e os Jobs para transformações ETL complexas.
* **Estrutura Interna (`main.tf`, `variables.tf`, `outputs.tf`)**: Garante que o módulo seja uma "caixa-preta": você injeta variáveis e recebe outputs, facilitando a manutenção.

### 3. `scripts/` (Camada de Lógica de Dados)
Esta pasta isola o código **Python/Spark** dos arquivos de infraestrutura **HCL**.
* **Objetivo**: Permitir que desenvolvedores de dados alterem a lógica de processamento (ETL) sem a necessidade de conhecimento profundo em Terraform. O Terraform apenas "empacota" e faz o deploy destes scripts.

---

## 🛠️ Boas Práticas Implementadas

* **Princípio de Privilégio Mínimo (PoLP)**: As IAM Roles são criadas dentro de cada módulo, garantindo que a Lambda, por exemplo, só acesse o bucket S3 que ela realmente precisa.
* **DRY (Don't Repeat Yourself)**: Através do uso de módulos, evitamos a duplicação de código. O mesmo código de S3 é usado para Dev, Staging e Prod.
* **State Locking**: Configurado via `backend.tf` para evitar corrupção do arquivo de estado durante execuções simultâneas.
* **Segurança de Segredos**: Uso de `.gitignore` rigoroso para impedir o vazamento acidental de credenciais e estados locais.

---

## 🚀 Comandos Rápidos

```bash
# Entrar no ambiente desejado
cd env/dev

# Inicializar e baixar providers/módulos
terraform init

# Validar o plano de execução
terraform plan

# Aplicar as mudanças
terraform apply