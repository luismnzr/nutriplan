# Nutriplan dev seeds
#
# Genera:
#   - Usuario personal (me@nutriplan.local / password123)
#   - Plan de la semana pasada con logs y daily_notes (pobla /history)
#   - Plan de la semana actual con logs hasta "ahora" (pobla /today)
#   - Algunos items marcados en la lista de compras
#
# Idempotente: destruye al usuario seed y todo lo relacionado antes de recrear.
#
# Correr con:  bin/rails db:seed

srand(42) # resultados reproducibles

EMAIL    = "me@nutriplan.local"
PASSWORD = "password123"

BREAKFASTS = [
  { d: "Avena con plátano y chía",      q: "1 taza",   s: ["Yogurt griego con granola", "Smoothie verde", "Huevos revueltos con tortilla"] },
  { d: "Huevos revueltos con aguacate", q: "2 piezas", s: ["Avena con fruta", "Tostadas de nopal"] },
  { d: "Tostadas de nopal con queso",   q: "2 piezas", s: ["Huevos a la mexicana", "Avena con fruta"] },
  { d: "Yogurt griego con fresas",      q: "1 taza",   s: ["Avena con plátano", "Smoothie verde"] },
  { d: "Molletes con frijoles",         q: "1 pieza",  s: ["Huevos revueltos", "Avena con fruta"] },
  { d: "Smoothie verde con espinaca",   q: "1 vaso",   s: ["Yogurt griego", "Avena con chía"] },
  { d: "Chilaquiles verdes con huevo",  q: "1 plato",  s: ["Huevos a la mexicana", "Molletes"] }
]

LUNCHES = [
  { d: "Pollo a la plancha con ensalada", q: "150 g", s: ["Pescado al horno con verduras", "Ensalada de atún con aguacate"] },
  { d: "Pescado al vapor con brócoli",    q: "150 g", s: ["Pollo a la plancha", "Salmón al horno"] },
  { d: "Ensalada de atún con aguacate",   q: "1 plato", s: ["Pollo con ensalada", "Pescado con verduras"] },
  { d: "Tacos de pollo con guacamole",    q: "3 piezas", s: ["Tinga de pollo con arroz", "Ensalada completa"] },
  { d: "Salmón al horno con quinoa",      q: "150 g", s: ["Pescado al vapor", "Pollo a la plancha"] },
  { d: "Tinga de pollo con arroz",        q: "1 plato", s: ["Tacos de pollo", "Pollo con ensalada"] },
  { d: "Ensalada de lentejas con queso",  q: "1 plato", s: ["Ensalada de atún", "Pollo con verduras"] }
]

DINNERS = [
  { d: "Sopa de verduras con pollo",       q: "1 tazón",   s: ["Ensalada ligera", "Tacos de camarón"] },
  { d: "Quesadillas de champiñones",       q: "2 piezas",  s: ["Tacos de pollo", "Sopa de verduras"] },
  { d: "Tacos de camarón con pico de gallo", q: "3 piezas", s: ["Quesadillas", "Sopa de verduras"] },
  { d: "Ensalada César con pollo",         q: "1 plato",   s: ["Sopa de verduras", "Tacos ligeros"] },
  { d: "Crema de calabaza con queso",      q: "1 tazón",   s: ["Sopa de verduras", "Ensalada"] },
  { d: "Tortitas de atún con ensalada",    q: "2 piezas",  s: ["Quesadillas", "Ensalada"] },
  { d: "Sopa de fideos con verduras",      q: "1 tazón",   s: ["Crema de calabaza", "Ensalada ligera"] }
]

SNACKS = [
  { d: "Manzana con crema de almendra", q: "1 pieza",    s: ["Puñado de almendras", "Yogurt natural"] },
  { d: "Yogurt griego con frutos rojos", q: "1 tazón",   s: ["Fruta picada", "Almendras"] },
  { d: "Puñado de almendras",           q: "30 g",       s: ["Yogurt natural", "Fruta de temporada"] },
  { d: "Zanahorias con hummus",         q: "1/2 taza",   s: ["Fruta", "Almendras"] },
  { d: "Fruta de temporada",            q: "1 pieza",    s: ["Yogurt", "Almendras"] },
  { d: "Queso panela con jitomate",     q: "50 g",       s: ["Fruta", "Almendras"] },
  { d: "Licuado de avena con canela",   q: "1 vaso",     s: ["Fruta", "Yogurt griego"] }
]

DEFAULT_TIMES = { "breakfast" => "08:00", "lunch" => "14:00", "dinner" => "20:00", "snack" => "17:00" }.freeze

def seed_week!(user:, start_date:, name:, notes: nil)
  plan = user.owned_plans.create!(
    name:       name,
    start_date: start_date,
    end_date:   start_date + 6.days,
    assignee:   user,
    notes:      notes
  )

  (plan.start_date..plan.end_date).each_with_index do |date, idx|
    day = plan.plan_days.create!(date: date)
    recipes = {
      "breakfast" => BREAKFASTS[idx % BREAKFASTS.size],
      "lunch"     => LUNCHES[idx % LUNCHES.size],
      "dinner"    => DINNERS[idx % DINNERS.size],
      "snack"     => SNACKS[idx % SNACKS.size]
    }
    Meal.meal_types.keys.each_with_index do |type, pos|
      r = recipes.fetch(type)
      meal = day.meals.create!(meal_type: type, time: DEFAULT_TIMES[type], position: pos)
      meal.meal_items.create!(
        description:  r[:d],
        quantity:     r[:q],
        swap_options: r[:s],
        position:     0
      )
    end
  end

  plan
end

def log_meal!(meal, status:, logged_at:)
  actual =
    if status == :modified && meal.meal_items.first&.swap_options&.any?
      meal.meal_items.first.swap_options.sample
    end
  meal.create_meal_log!(status: status, actual_description: actual, logged_at: logged_at)
end

def daily_note!(user, day)
  total  = day.meals.size
  filled = day.meals.joins(:meal_log).where(meal_logs: { status: [MealLog.statuses[:eaten], MealLog.statuses[:modified]] }).count
  ratio  = total.zero? ? 0.0 : filled.to_f / total
  score  = (ratio * 5).round.clamp(1, 5)
  user.daily_notes.create!(
    plan_day:      day,
    overall_score: score,
    energy_level:  (score + rand(-1..1)).clamp(1, 5),
    hunger_level:  rand(2..4),
    mood:          %w[bien calmada motivada cansada enfocada].sample,
    free_text:     (["Día parejo, sin antojos.", "Mucha agua.", "Entrenamiento en la tarde.", nil, nil].sample)
  )
end

# ── Limpieza idempotente ───────────────────────────────────────────────────────
User.where(email: EMAIL).destroy_all

user = User.create!(email: EMAIL, password: PASSWORD)
puts "✓ Usuario creado: #{user.email} (password: #{PASSWORD})"

# ── Semana pasada: datos completos para /history ───────────────────────────────
last_week_start = Date.current.beginning_of_week(:monday) - 7.days
last_week_plan = seed_week!(
  user:       user,
  start_date: last_week_start,
  name:       "Semana del #{I18n.l(last_week_start, format: '%-d de %B')}",
  notes:      "Foco en sueño: 8 horas mínimo."
)
puts "✓ Plan pasado: #{last_week_plan.name} (#{last_week_plan.start_date} → #{last_week_plan.end_date})"

last_week_plan.plan_days.each_with_index do |day, idx|
  day.meals.each do |meal|
    # Patrón: mejor cumplimiento al inicio, relaja hacia el fin de semana
    pool =
      if idx < 3
        [:eaten, :eaten, :eaten, :modified]
      elsif idx < 5
        [:eaten, :modified, :modified, :skipped]
      else
        [:eaten, :skipped, :skipped, :modified]
      end
    status = pool.sample
    logged_at = day.date.in_time_zone.change(hour: meal.time.hour, min: meal.time.min)
    log_meal!(meal, status: status, logged_at: logged_at)
  end
  daily_note!(user, day)
end
puts "  → #{last_week_plan.plan_days.joins(meals: :meal_log).count} meal_logs, #{user.daily_notes.count} daily_notes"

# ── Semana actual: logs hasta hoy inclusive ────────────────────────────────────
this_week_start = Date.current.beginning_of_week(:monday)
current_plan = seed_week!(
  user:       user,
  start_date: this_week_start,
  name:       "Semana del #{I18n.l(this_week_start, format: '%-d de %B')}",
  notes:      "Hidratación: mínimo 2 litros de agua."
)
puts "✓ Plan actual: #{current_plan.name} (#{current_plan.start_date} → #{current_plan.end_date})"

now = Time.current

# Días pasados de esta semana → logs completos + notas
current_plan.plan_days.where("date < ?", Date.current).each do |day|
  day.meals.each do |meal|
    status = [:eaten, :eaten, :eaten, :modified, :skipped].sample
    logged_at = day.date.in_time_zone.change(hour: meal.time.hour, min: meal.time.min)
    log_meal!(meal, status: status, logged_at: logged_at)
  end
  daily_note!(user, day)
end

# Hoy → logs solo hasta "ahora" (para simular la experiencia de /today en vivo)
today_day = current_plan.plan_days.find_by(date: Date.current)
if today_day
  today_day.meals.each do |meal|
    meal_time = Date.current.in_time_zone.change(hour: meal.time.hour, min: meal.time.min)
    next unless meal_time < now
    status = [:eaten, :eaten, :modified].sample
    log_meal!(meal, status: status, logged_at: meal_time)
  end
end

# ── Lista de compras: marcar los primeros items como comprados ─────────────────
current_plan.shopping_list.first(4).each do |row|
  current_plan.shopping_list_checks.create!(item_key: row[:key])
end
puts "✓ #{current_plan.shopping_list_checks.count} items marcados en la lista de compras"

puts
puts "Listo. Entra a http://localhost:3000/ con:"
puts "  email:    #{EMAIL}"
puts "  password: #{PASSWORD}"
