# ServiceOps — Stack, trilha de aprendizado e plano de implementação

## 1. Visão do projeto

**ServiceOps** é um sistema de ordens de serviço para empresas de assistência técnica, manutenção de computadores, suporte de TI, montagem de máquinas, formatação, limpeza, instalação de servidores locais e outros serviços técnicos.

O objetivo do projeto não é apenas criar telas CRUD. A ideia é construir um fluxo real de negócio:

```txt
Cliente solicita atendimento
Técnico registra diagnóstico
Sistema gera orçamento
Cliente aprova ou recusa
Serviço entra em execução
Técnico registra peças/serviços usados
Sistema calcula valor final
Cliente acompanha o status
Ordem é finalizada
```

Esse projeto é bom para aprender Ruby/Rails porque envolve:

```txt
Ruby básico
Orientação a objetos
Rails MVC
Banco relacional
Relacionamentos
Validações
Autenticação
Autorização simples
Fluxo de status
Service objects
Background jobs
Emails
Uploads
Dashboard
Testes
Deploy
```

## 2. Stack recomendada

### Stack principal

```txt
Ruby 3.4.x ou Ruby 4.x
Ruby on Rails 8.x
PostgreSQL
Hotwire/Turbo
Tailwind CSS
Active Record
Active Storage
Active Job
Solid Queue
Minitest ou RSpec
Docker
```

### Recomendação prática

Para evitar dor desnecessária no começo:

```txt
Ruby: 3.4.x
Rails: 8.x estável
Banco: PostgreSQL
Frontend: Rails views + Hotwire + Tailwind
Autenticação: Rails authentication generator
Jobs: Active Job + Solid Queue
Testes: começar com Minitest; migrar para RSpec depois se quiser
Deploy: Render, Railway, Fly.io ou VPS
```

Ruby 4.x já existe, mas para aprendizado e compatibilidade de gems, Ruby 3.4.x é uma escolha mais conservadora. Depois, você pode testar Ruby 4.x.

## 3. Por que não usar React no começo?

Porque o objetivo é aprender Ruby/Rails de verdade.

Se colocar React ou Next.js agora, você provavelmente vai gastar tempo demais com frontend, API, autenticação por token, CORS, estado, roteamento e integração. Para este projeto, Rails full-stack é melhor:

```txt
Menos peças móveis
Menos boilerplate
Entrega mais rápida
Mais foco em backend e regra de negócio
Mais fácil de finalizar
```

Depois que o app estiver pronto, você pode criar uma API JSON e consumir com React/Next se quiser.

## 4. Conceitos que você vai aprender em cada parte

| Parte do projeto | O que aprende |
|---|---|
| Cadastro de clientes | Models, controllers, views, validações |
| Cadastro de técnicos | Relacionamento com usuários e papéis |
| Ordem de serviço | Modelagem de domínio e fluxo de status |
| Diagnóstico | Associação entre models e histórico |
| Orçamento | Regras de negócio e cálculo de total |
| Aprovação de orçamento | Transição de estados e segurança |
| Anexos | Active Storage |
| Emails | Action Mailer e Active Job |
| Página pública de tracking | Rotas públicas seguras por token |
| Dashboard | Queries, scopes e agregações |
| Testes | Teste de model, request e service |
| Deploy | Variáveis de ambiente, banco, assets e jobs |

## 5. Estrutura geral do projeto

Nome recomendado do repositório:

```txt
service-ops
```

Estrutura Rails esperada:

```txt
app/
  controllers/
  models/
  views/
  services/
  jobs/
  mailers/
  policies/              # opcional no começo
  helpers/
config/
db/
test/ ou spec/
```

Pasta para regras de negócio:

```txt
app/services/
  service_orders/
    create_service.rb
    update_status_service.rb
    cancel_service.rb
  quotes/
    generate_service.rb
    approve_service.rb
    reject_service.rb
  notifications/
    send_quote_email_service.rb
```

## 6. Modelagem inicial

### Entidades principais

```txt
User
Customer
TechnicianProfile
ServiceCategory
ServiceOrder
Diagnostic
Quote
QuoteItem
Attachment
StatusHistory
Payment
```

### Versão MVP das tabelas

#### users

Representa quem acessa o sistema.

Campos sugeridos:

```txt
id
email_address
password_digest
role
created_at
updated_at
```

Roles:

```txt
admin
technician
attendant
```

#### customers

Representa o cliente atendido.

Campos:

```txt
id
name
email
phone
document
created_at
updated_at
```

#### service_categories

Tipos de serviço.

Campos:

```txt
id
name
description
active
created_at
updated_at
```

Exemplos:

```txt
Formatação
Limpeza interna
Montagem de computador
Troca de pasta térmica
Instalação de servidor local
Desenvolvimento de software
Suporte remoto
```

#### service_orders

Representa uma ordem de serviço.

Campos:

```txt
id
code
customer_id
assigned_user_id
service_category_id
title
description
status
priority
public_token
opened_at
finished_at
created_at
updated_at
```

Status:

```txt
opened
in_diagnosis
waiting_quote_approval
quote_approved
quote_rejected
in_progress
waiting_payment
done
cancelled
```

Prioridade:

```txt
low
normal
high
urgent
```

#### diagnostics

Diagnóstico técnico da ordem.

Campos:

```txt
id
service_order_id
user_id
summary
technical_details
created_at
updated_at
```

#### quotes

Orçamento da ordem.

Campos:

```txt
id
service_order_id
status
subtotal
discount
total
expires_at
approved_at
rejected_at
created_at
updated_at
```

Status:

```txt
draft
sent
approved
rejected
expired
```

#### quote_items

Itens do orçamento.

Campos:

```txt
id
quote_id
kind
description
quantity
unit_price
total_price
created_at
updated_at
```

Kind:

```txt
service
part
fee
```

#### status_histories

Histórico de alteração de status.

Campos:

```txt
id
service_order_id
user_id
from_status
to_status
note
created_at
```

#### payments

Pagamento simples/fake.

Campos:

```txt
id
service_order_id
status
method
amount
paid_at
created_at
updated_at
```

Status:

```txt
pending
paid
failed
refunded
```

Método:

```txt
cash
pix
credit_card
bank_transfer
```

## 7. Relacionamentos principais

```rb
class Customer < ApplicationRecord
  has_many :service_orders
end

class ServiceOrder < ApplicationRecord
  belongs_to :customer
  belongs_to :assigned_user, class_name: "User", optional: true
  belongs_to :service_category

  has_one :diagnostic
  has_one :quote
  has_one :payment
  has_many :status_histories
end

class Quote < ApplicationRecord
  belongs_to :service_order
  has_many :quote_items, dependent: :destroy
end

class QuoteItem < ApplicationRecord
  belongs_to :quote
end
```

## 8. Fluxo de status

Fluxo principal:

```txt
opened
  -> in_diagnosis
  -> waiting_quote_approval
  -> quote_approved
  -> in_progress
  -> waiting_payment
  -> done
```

Fluxos alternativos:

```txt
waiting_quote_approval -> quote_rejected
opened -> cancelled
in_diagnosis -> cancelled
in_progress -> cancelled
waiting_payment -> cancelled
```

Regra importante:

```txt
Não deixe qualquer status ir para qualquer status.
Crie uma regra de transição permitida.
```

Exemplo:

```rb
ALLOWED_TRANSITIONS = {
  "opened" => ["in_diagnosis", "cancelled"],
  "in_diagnosis" => ["waiting_quote_approval", "cancelled"],
  "waiting_quote_approval" => ["quote_approved", "quote_rejected", "cancelled"],
  "quote_approved" => ["in_progress"],
  "in_progress" => ["waiting_payment", "cancelled"],
  "waiting_payment" => ["done", "cancelled"],
  "done" => [],
  "cancelled" => []
}.freeze
```

## 9. Roadmap de aprendizado e implementação

## Fase 0 — Preparação do ambiente

Objetivo: deixar Ruby/Rails rodando com PostgreSQL.

Aprender:

```txt
Ruby version manager
Gems
Bundler
Rails CLI
PostgreSQL
Docker básico
```

Comandos base:

```bash
ruby -v
rails -v
psql --version
```

Criar o projeto:

```bash
rails new service_ops -d postgresql --css=tailwind
cd service_ops
bin/rails db:create
bin/rails server
```

Primeiro commit:

```bash
git init
git add .
git commit -m "chore: initial rails app"
```

## Fase 1 — Ruby básico antes de Rails pesado

Objetivo: entender o mínimo de Ruby para não ficar perdido no Rails.

Estudar:

```txt
Variáveis
Strings
Arrays
Hashes
Symbols
Métodos
Classes
Modules
Blocks
Enumerable: each, map, select, find, reduce
```

Exercício antes de mexer muito no Rails:

```rb
class QuoteItem
  attr_reader :description, :quantity, :unit_price

  def initialize(description:, quantity:, unit_price:)
    @description = description
    @quantity = quantity
    @unit_price = unit_price
  end

  def total
    quantity * unit_price
  end
end
```

Meta da fase:

```txt
Conseguir escrever classes simples sem copiar tudo.
```

## Fase 2 — CRUD base: clientes e categorias

Objetivo: aprender MVC no Rails.

Criar Customer:

```bash
bin/rails generate scaffold Customer name:string email:string phone:string document:string
bin/rails db:migrate
```

Criar ServiceCategory:

```bash
bin/rails generate scaffold ServiceCategory name:string description:text active:boolean
bin/rails db:migrate
```

Aprender:

```txt
Model
Migration
Controller
View
Routes
Validations
Partials
Form helpers
Strong parameters
```

Adicionar validações:

```rb
class Customer < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true
end
```

Meta da fase:

```txt
Cadastrar, listar, editar e remover clientes/categorias.
```

## Fase 3 — Autenticação

Objetivo: proteger o painel administrativo.

Usar o gerador nativo do Rails:

```bash
bin/rails generate authentication
bin/rails db:migrate
```

Depois criar cadastro de usuário manualmente ou via seed no começo.

Aprender:

```txt
Sessão
Login
Logout
Cookies
Current.user
before_action
Autorização simples por role
```

Roles no User:

```bash
bin/rails generate migration AddRoleToUsers role:string
bin/rails db:migrate
```

Exemplo inicial:

```rb
class User < ApplicationRecord
  enum :role, {
    admin: "admin",
    technician: "technician",
    attendant: "attendant"
  }
end
```

Meta da fase:

```txt
Somente usuário logado acessa o sistema.
```

## Fase 4 — Ordem de serviço

Objetivo: criar o coração do projeto.

Gerar model:

```bash
bin/rails generate model ServiceOrder \
  code:string \
  customer:references \
  assigned_user:references \
  service_category:references \
  title:string \
  description:text \
  status:string \
  priority:string \
  public_token:string \
  opened_at:datetime \
  finished_at:datetime
```

Ajustar a migration de `assigned_user` manualmente para referenciar `users`:

```rb
t.references :assigned_user, foreign_key: { to_table: :users }
```

Aprender:

```txt
belongs_to
optional relationships
foreign_key customizada
callbacks
before_validation
scopes
enums com string
```

Exemplo de código automático:

```rb
before_validation :set_defaults, on: :create

private

def set_defaults
  self.status ||= "opened"
  self.priority ||= "normal"
  self.opened_at ||= Time.current
  self.public_token ||= SecureRandom.urlsafe_base64(24)
  self.code ||= "OS-#{Time.current.year}-#{SecureRandom.hex(3).upcase}"
end
```

Meta da fase:

```txt
Criar OS vinculada a cliente, categoria e técnico.
```

## Fase 5 — Diagnóstico

Objetivo: registrar análise técnica da ordem.

Gerar model:

```bash
bin/rails generate model Diagnostic \
  service_order:references \
  user:references \
  summary:string \
  technical_details:text

bin/rails db:migrate
```

Aprender:

```txt
Nested resources
has_one
Validações contextuais
Atualização de status após ação
```

Rota sugerida:

```rb
resources :service_orders do
  resource :diagnostic, only: [:new, :create, :edit, :update]
end
```

Regra:

```txt
Ao criar diagnóstico, a OS pode ir de opened para in_diagnosis.
Quando diagnóstico for concluído, pode ir para waiting_quote_approval após gerar orçamento.
```

Meta da fase:

```txt
Toda OS pode receber um diagnóstico técnico.
```

## Fase 6 — Orçamento e itens

Objetivo: criar orçamento com serviços e peças.

Gerar models:

```bash
bin/rails generate model Quote \
  service_order:references \
  status:string \
  subtotal:decimal{10,2} \
  discount:decimal{10,2} \
  total:decimal{10,2} \
  expires_at:datetime \
  approved_at:datetime \
  rejected_at:datetime

bin/rails generate model QuoteItem \
  quote:references \
  kind:string \
  description:string \
  quantity:decimal{10,2} \
  unit_price:decimal{10,2} \
  total_price:decimal{10,2}

bin/rails db:migrate
```

Aprender:

```txt
has_many
accepts_nested_attributes_for
cálculo de total
callbacks controlados
service objects
transações
```

Service object sugerido:

```rb
module Quotes
  class GenerateService
    def self.call(service_order:, items:, discount: 0)
      new(service_order:, items:, discount:).call
    end

    def initialize(service_order:, items:, discount:)
      @service_order = service_order
      @items = items
      @discount = discount
    end

    def call
      ActiveRecord::Base.transaction do
        quote = @service_order.build_quote(status: "sent", discount: @discount)

        @items.each do |item|
          quote.quote_items.build(item)
        end

        quote.subtotal = quote.quote_items.sum { |item| item.quantity * item.unit_price }
        quote.total = quote.subtotal - quote.discount
        quote.expires_at = 7.days.from_now
        quote.save!

        ServiceOrders::UpdateStatusService.call(
          service_order: @service_order,
          to_status: "waiting_quote_approval",
          user: Current.user,
          note: "Orçamento enviado"
        )

        quote
      end
    end
  end
end
```

Meta da fase:

```txt
Criar orçamento com vários itens e total calculado.
```

## Fase 7 — Aprovação pública do orçamento

Objetivo: criar uma página que o cliente acessa sem login.

Rota:

```rb
get "/track/:public_token", to: "public/service_orders#show", as: :public_service_order
post "/track/:public_token/approve", to: "public/quotes#approve", as: :approve_public_quote
post "/track/:public_token/reject", to: "public/quotes#reject", as: :reject_public_quote
```

Aprender:

```txt
Namespace de controller
Rotas públicas
Token seguro
Aprovação sem login
Segurança básica
```

Regras:

```txt
Cliente só acessa usando public_token.
Não expor ID sequencial na URL pública.
Só permitir aprovar se status atual for waiting_quote_approval.
Se aprovado, quote.status = approved e service_order.status = quote_approved.
Se recusado, quote.status = rejected e service_order.status = quote_rejected.
```

Meta da fase:

```txt
Cliente consegue ver e aprovar/recusar o orçamento por link público.
```

## Fase 8 — Histórico de status

Objetivo: registrar toda mudança importante.

Gerar model:

```bash
bin/rails generate model StatusHistory \
  service_order:references \
  user:references \
  from_status:string \
  to_status:string \
  note:text

bin/rails db:migrate
```

Service:

```rb
module ServiceOrders
  class UpdateStatusService
    def self.call(service_order:, to_status:, user:, note: nil)
      new(service_order:, to_status:, user:, note:).call
    end

    def initialize(service_order:, to_status:, user:, note:)
      @service_order = service_order
      @to_status = to_status
      @user = user
      @note = note
    end

    def call
      from_status = @service_order.status

      unless allowed_transition?(from_status, @to_status)
        raise ArgumentError, "Transição de status inválida"
      end

      ActiveRecord::Base.transaction do
        @service_order.update!(status: @to_status)
        @service_order.status_histories.create!(
          user: @user,
          from_status: from_status,
          to_status: @to_status,
          note: @note
        )
      end
    end

    private

    def allowed_transition?(from, to)
      ServiceOrder::ALLOWED_TRANSITIONS.fetch(from, []).include?(to)
    end
  end
end
```

Meta da fase:

```txt
Toda troca de status fica auditável.
```

## Fase 9 — Anexos com Active Storage

Objetivo: permitir fotos e documentos na OS.

Instalar Active Storage:

```bash
bin/rails active_storage:install
bin/rails db:migrate
```

No model:

```rb
class ServiceOrder < ApplicationRecord
  has_many_attached :files
end
```

Aprender:

```txt
Upload de arquivos
Validação de tipo/tamanho
Storage local
Storage em produção
```

Exemplos de anexos:

```txt
Foto do equipamento
Print do erro
PDF de orçamento assinado
Comprovante de pagamento
```

Meta da fase:

```txt
OS permite anexar arquivos.
```

## Fase 10 — Emails e background jobs

Objetivo: enviar notificação sem travar request.

Criar mailer:

```bash
bin/rails generate mailer QuoteMailer sent approved rejected
```

Exemplo:

```rb
class QuoteMailer < ApplicationMailer
  def sent
    @quote = params[:quote]
    @service_order = @quote.service_order
    mail(to: @service_order.customer.email, subject: "Orçamento disponível")
  end
end
```

Chamada assíncrona:

```rb
QuoteMailer.with(quote: quote).sent.deliver_later
```

Aprender:

```txt
Action Mailer
Active Job
Solid Queue
Processamento assíncrono
```

Meta da fase:

```txt
Ao enviar orçamento, cliente recebe email com link público.
```

## Fase 11 — Pagamento simples/fake

Objetivo: simular pagamento sem gateway real.

Gerar model:

```bash
bin/rails generate model Payment \
  service_order:references \
  status:string \
  method:string \
  amount:decimal{10,2} \
  paid_at:datetime

bin/rails db:migrate
```

Regras fake:

```txt
PIX sempre aprova
Cartão terminado em 0000 falha
Cartão terminado em 1111 aprova
Dinheiro precisa ser marcado manualmente como pago
```

Service:

```txt
Payments::SimulateService
Payments::MarkAsPaidService
Payments::RefundService
```

Meta da fase:

```txt
OS só finaliza depois de pagamento marcado como pago.
```

## Fase 12 — Dashboard

Objetivo: criar visão de gestão.

Métricas:

```txt
Ordens abertas
Ordens em diagnóstico
Ordens aguardando aprovação
Ordens em execução
Ordens concluídas no mês
Faturamento do mês
Ticket médio
Categorias mais solicitadas
Técnicos com mais atendimentos
```

Aprender:

```txt
Scopes
Queries Active Record
Agregações SQL
Group/count/sum
Cards de dashboard
```

Exemplo:

```rb
ServiceOrder.where(status: "done").where(finished_at: Time.current.all_month).count
Payment.where(status: "paid").where(paid_at: Time.current.all_month).sum(:amount)
```

Meta da fase:

```txt
Página inicial mostra indicadores reais do sistema.
```

## Fase 13 — Testes

Objetivo: deixar o projeto com cara profissional.

Começar testando:

```txt
Model validations
Status transitions
Quote total calculation
Quote approval
Public tracking token
```

Exemplo de teste conceitual:

```rb
test "approved quote changes service order status" do
  quote = quotes(:sent)

  Quotes::ApproveService.call(quote: quote)

  assert_equal "approved", quote.reload.status
  assert_equal "quote_approved", quote.service_order.reload.status
end
```

Meta da fase:

```txt
Ter testes das principais regras de negócio.
```

## Fase 14 — Docker

Objetivo: facilitar setup do projeto no GitHub.

Criar `docker-compose.yml` com PostgreSQL.

Exemplo:

```yaml
services:
  postgres:
    image: postgres:17
    container_name: service_ops_postgres
    environment:
      POSTGRES_USER: service_ops
      POSTGRES_PASSWORD: service_ops
      POSTGRES_DB: service_ops_development
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

Para ambiente real, usar `.env` e não commitar segredos.

Meta da fase:

```txt
Subir banco com docker compose up -d.
```

## Fase 15 — README, seeds e finalização

Objetivo: deixar o projeto apresentável.

Adicionar:

```txt
README decente
Prints do sistema
Seeds com dados fake
Comandos de setup
Diagrama simples do domínio
Checklist de funcionalidades
Explicação das decisões técnicas
```

Seeds sugeridos:

```txt
Usuário admin
3 técnicos
10 clientes
5 categorias
20 ordens de serviço
Algumas ordens com diagnóstico
Algumas ordens com orçamento aprovado
Algumas ordens concluídas
```

## 10. Ordem ideal de commits

```txt
chore: initialize rails app
chore: configure postgresql and docker compose
feat: add customers management
feat: add service categories
feat: add authentication
feat: add user roles
feat: add service orders
feat: add diagnostics
feat: add quotes and quote items
feat: add quote approval workflow
feat: add status history
feat: add public service order tracking
feat: add file attachments
feat: add quote email notifications
feat: add simulated payments
feat: add dashboard metrics
test: add domain workflow tests
docs: improve project README
```

## 11. Rotas principais

```rb
Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  root "dashboard#index"

  resources :customers
  resources :service_categories

  resources :service_orders do
    resource :diagnostic
    resource :quote do
      post :approve
      post :reject
    end
    resource :payment do
      post :mark_as_paid
      post :simulate
    end
  end

  namespace :public do
    get "/track/:public_token", to: "service_orders#show", as: :service_order_tracking
    post "/track/:public_token/approve", to: "quotes#approve", as: :approve_quote
    post "/track/:public_token/reject", to: "quotes#reject", as: :reject_quote
  end
end
```

## 12. Telas do sistema

### Painel interno

```txt
/dashboard
/customers
/customers/:id
/service_orders
/service_orders/new
/service_orders/:id
/service_orders/:id/diagnostic/new
/service_orders/:id/quote/new
/service_orders/:id/payment
/service_categories
```

### Página pública

```txt
/public/track/:public_token
```

A página pública deve mostrar:

```txt
Código da OS
Status atual
Descrição do problema
Diagnóstico resumido
Orçamento
Itens do orçamento
Valor total
Botão de aprovar
Botão de recusar
Histórico simplificado
```

## 13. Regras de negócio importantes

```txt
1. Uma OS precisa pertencer a um cliente.
2. Uma OS precisa ter uma categoria.
3. Uma OS começa com status opened.
4. Uma OS não pode pular qualquer status.
5. Orçamento só pode ser aprovado se estiver sent.
6. OS só pode ir para in_progress após orçamento aprovado.
7. OS só pode ir para done depois do pagamento pago.
8. Página pública não deve expor IDs internos.
9. Toda troca de status deve gerar histórico.
10. Valor total do orçamento deve vir da soma dos itens menos desconto.
```

## 14. Coisas para evitar no início

```txt
Não começar com API + frontend separado.
Não colocar React no começo.
Não criar multi-tenant logo no início.
Não fazer integração real de pagamento no MVP.
Não criar permissões complexas demais no começo.
Não tentar deixar perfeito antes de funcionar.
```

## 15. Evoluções futuras

Depois do MVP:

```txt
Multi-empresa
Controle de estoque de peças
Assinatura digital do orçamento
Geração de PDF
Exportação CSV
Kanban de ordens
Chat interno na OS
Notificações em tempo real
API JSON
Aplicativo mobile
Integração real com pagamento
Integração WhatsApp
```

## 16. Checklist final do MVP

```txt
[ ] Projeto Rails criado
[ ] Banco PostgreSQL configurado
[ ] Docker Compose para banco
[ ] Clientes CRUD
[ ] Categorias CRUD
[ ] Login funcionando
[ ] Roles básicos
[ ] Ordem de serviço criada
[ ] Diagnóstico criado
[ ] Orçamento criado com itens
[ ] Total do orçamento calculado
[ ] Aprovação pública do orçamento
[ ] Histórico de status
[ ] Upload de anexos
[ ] Email de orçamento
[ ] Pagamento fake
[ ] Dashboard
[ ] Testes principais
[ ] Seeds
[ ] README final
```

## 17. Referências oficiais úteis

```txt
Ruby: https://www.ruby-lang.org/
Rails: https://rubyonrails.org/
Rails Guides: https://guides.rubyonrails.org/
Active Record PostgreSQL: https://guides.rubyonrails.org/active_record_postgresql.html
Active Job: https://guides.rubyonrails.org/active_job_basics.html
Rails Security: https://guides.rubyonrails.org/security.html
Hotwire/Turbo: https://turbo.hotwired.dev/
Solid Queue: https://github.com/rails/solid_queue
```
