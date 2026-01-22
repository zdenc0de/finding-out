-- ============================================================================
-- SEED DATA: Test Events
-- Description: Insert sample events for testing the application
-- Note: Run this after 001_create_events_tables.sql
-- ============================================================================

-- Insert sample events for each category
INSERT INTO events (title, description, category_id, image_url, address, start_date, end_date) VALUES
  -- Música
  (
    'Concierto Rock en Vivo',
    'Disfruta de las mejores bandas de rock local en un concierto épico.',
    (SELECT id FROM categories WHERE name = 'Música'),
    NULL,
    'Foro Sol, CDMX',
    NOW() + INTERVAL '7 days',
    NOW() + INTERVAL '7 days' + INTERVAL '4 hours'
  ),
  (
    'Festival de Jazz',
    'Una noche mágica de jazz con artistas internacionales.',
    (SELECT id FROM categories WHERE name = 'Música'),
    NULL,
    'Auditorio Nacional',
    NOW() + INTERVAL '14 days',
    NOW() + INTERVAL '14 days' + INTERVAL '5 hours'
  ),
  (
    'Noche de Salsa',
    'Baila toda la noche con la mejor música salsa en vivo.',
    (SELECT id FROM categories WHERE name = 'Música'),
    NULL,
    'Salón Los Ángeles',
    NOW() + INTERVAL '3 days',
    NOW() + INTERVAL '3 days' + INTERVAL '6 hours'
  ),

  -- Deportes
  (
    'Partido de Fútbol - Liga Local',
    'Ven a apoyar a tu equipo favorito en la final de la liga.',
    (SELECT id FROM categories WHERE name = 'Deportes'),
    NULL,
    'Estadio Azteca',
    NOW() + INTERVAL '5 days',
    NOW() + INTERVAL '5 days' + INTERVAL '2 hours'
  ),
  (
    'Carrera 10K Ciudad',
    'Participa en la carrera anual de 10 kilómetros por la ciudad.',
    (SELECT id FROM categories WHERE name = 'Deportes'),
    NULL,
    'Reforma 222',
    NOW() + INTERVAL '10 days',
    NOW() + INTERVAL '10 days' + INTERVAL '3 hours'
  ),
  (
    'Torneo de Básquetbol',
    'Torneo amateur de básquetbol 3x3. ¡Inscribe a tu equipo!',
    (SELECT id FROM categories WHERE name = 'Deportes'),
    NULL,
    'Deportivo Chapultepec',
    NOW() + INTERVAL '8 days',
    NOW() + INTERVAL '9 days'
  ),

  -- Bazares
  (
    'Bazar Navideño Artesanal',
    'Encuentra los mejores regalos hechos a mano para esta temporada.',
    (SELECT id FROM categories WHERE name = 'Bazares'),
    NULL,
    'Plaza Coyoacán',
    NOW() + INTERVAL '2 days',
    NOW() + INTERVAL '4 days'
  ),
  (
    'Mercado Vintage',
    'Ropa, accesorios y objetos vintage de décadas pasadas.',
    (SELECT id FROM categories WHERE name = 'Bazares'),
    NULL,
    'Roma Norte',
    NOW() + INTERVAL '6 days',
    NOW() + INTERVAL '6 days' + INTERVAL '8 hours'
  ),
  (
    'Feria del Libro Usado',
    'Miles de libros de segunda mano a precios increíbles.',
    (SELECT id FROM categories WHERE name = 'Bazares'),
    NULL,
    'Palacio de Minería',
    NOW() + INTERVAL '12 days',
    NOW() + INTERVAL '15 days'
  ),

  -- Tech
  (
    'Hackathon 2024',
    'Desarrolla tu proyecto en 48 horas y gana premios increíbles.',
    (SELECT id FROM categories WHERE name = 'Tech'),
    NULL,
    'Campus Google',
    NOW() + INTERVAL '15 days',
    NOW() + INTERVAL '17 days'
  ),
  (
    'Meetup de Flutter',
    'Aprende las últimas novedades de Flutter con expertos locales.',
    (SELECT id FROM categories WHERE name = 'Tech'),
    NULL,
    'WeWork Reforma',
    NOW() + INTERVAL '4 days',
    NOW() + INTERVAL '4 days' + INTERVAL '3 hours'
  ),
  (
    'Conferencia de IA',
    'Explora el futuro de la inteligencia artificial con líderes del sector.',
    (SELECT id FROM categories WHERE name = 'Tech'),
    NULL,
    'Centro Citibanamex',
    NOW() + INTERVAL '20 days',
    NOW() + INTERVAL '22 days'
  ),

  -- Artísticos
  (
    'Exposición de Arte Moderno',
    'Obras de artistas contemporáneos mexicanos e internacionales.',
    (SELECT id FROM categories WHERE name = 'Artísticos'),
    NULL,
    'Museo Tamayo',
    NOW() + INTERVAL '1 day',
    NOW() + INTERVAL '30 days'
  ),
  (
    'Taller de Pintura al Óleo',
    'Aprende técnicas de pintura con artistas profesionales.',
    (SELECT id FROM categories WHERE name = 'Artísticos'),
    NULL,
    'Casa del Lago',
    NOW() + INTERVAL '9 days',
    NOW() + INTERVAL '9 days' + INTERVAL '4 hours'
  ),
  (
    'Festival de Muralismo',
    'Observa a artistas crear murales en vivo por toda la ciudad.',
    (SELECT id FROM categories WHERE name = 'Artísticos'),
    NULL,
    'Centro Histórico',
    NOW() + INTERVAL '11 days',
    NOW() + INTERVAL '13 days'
  );
