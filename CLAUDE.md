# Nutriplan

App personal de organización de alimentación. Fase 1: uso personal
para validar durante 2-3 semanas. Fase 2: features para nutrióloga
y sus clientes. Fase 3: white-label multi-tenant.

## Stack

- Rails 7.2.2, Ruby 3.3.6
- PostgreSQL
- Hotwire (Turbo + Stimulus) — NO React
- Tailwind CSS (dark mode available, Apollo.io-inspired)
- esbuild
- RSpec + FactoryBot (pendiente instalar)
- Devise (pendiente instalar)
- Sidekiq (pendiente instalar)
- Deploy: Heroku

## Comandos

- `bin/dev` — servidor local
- `bin/rails db:migrate` — correr migraciones
- `bundle exec rspec` — tests (una vez instalado)

## Convenciones

- Dark mode por defecto (class strategy en Tailwind)
- Aesthetic Apollo.io-inspired - micro-interactions sutiles con Turbo Streams
- Specs para modelos y flows críticos, no para todo

## Visión del producto

Plataforma de planes alimenticios para nutriólogas boutique y sus
clientes. Inspirada en Avena (avena.io) pero con posicionamiento
opuesto: minimalista, opinionada, con diseño como diferenciador.
Mismo modelo mental que Eclipse vs. Mindbody.

## Roadmap de features (contexto para decisiones arquitectónicas)

### Fase 1 — uso personal (single user, yo)

- Editor de plan semanal (grid)
- Vista /today con logging de cumplimiento
- Intercambio de items (MealItem tiene swap_options)
- Shopping list auto-generada semanal
- Rating diario (score + energía/hambre/ánimo + texto)
- Historia con heatmap de cumplimiento

### Fase 2 — nutrióloga + sus clientes (multi-user, roles)

- Biblioteca personal de planes (templates)
- Biblioteca personal de recetas
- Export PDF del plan
- Cuestionario pre-consulta
- Tracking de peso/medidas con gráfica
- Chat asíncrono cliente ↔ nutrióloga
- Fotos de progreso (Active Storage)

### Fase 3 — white-label (multi-tenant)

- Subdominios por nutrióloga
- Stripe Connect
- Agenda/citas
- Suplementación
- Recordatorios push
- Análisis de foto de platillo con Claude API
- Import de análisis clínicos

## Principios de diseño técnico

- Modelar Fase 1 pensando en Fase 2: las decisiones de schema no
  deben bloquear agregar roles (nutrióloga/cliente) después
- Ejemplo: MealPlan ya debería tener concepto de "owner" y "assignee"
  aunque en Fase 1 sean el mismo user
- Evitar multi-tenant prematuro: no meter Current.account hasta Fase 3
- Active Storage se instala en Fase 2, no ahora
