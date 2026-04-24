# Nutriplan

App personal de organización de alimentación. Fase 1: uso personal
para validar durante 2-3 semanas. Fase 2: features para nutrióloga
y sus clientes. Fase 3: white-label multi-tenant.

## Stack
- Rails 7.2.2, Ruby 3.3.6
- PostgreSQL
- Hotwire (Turbo + Stimulus) — NO React
- Tailwind CSS (dark mode first, Linear-inspired)
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
- Aesthetic Linear-inspired: grises fríos, tipografía Inter,
  micro-interactions sutiles con Turbo Streams
- Specs para modelos y flows críticos, no para todo
