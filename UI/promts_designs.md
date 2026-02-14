# 🎨 Finding Out - UI/UX Design Prompts

> **Objetivo**: Prompts de alta calidad para generar mockups profesionales de cada pantalla de la app.  
> **Estilo actual**: "Santorini" - Colores mediterráneos (azul #1976D2, blanco, coral/terracota)  
> **Target**: Jóvenes 18-35, descubrimiento de eventos locales  

---

## 📱 Tema Visual Recomendado

### Paleta de Colores
- **Primario**: Azul Santorini (#1976D2) → Confianza, frescura
- **Secundario**: Coral/Terracota (#FF7043) → Energía, calidez
- **Accent**: Turquesa (#26C6DA) → Dinamismo, modernidad
- **Backgrounds**: Blanco cálido (#FAFAFA), Crema suave (#FFF8E1)
- **Dark mode**: Azul profundo (#0D1B2A), Gris azulado (#1B263B)

### Elementos Diferenciadores
- Ilustraciones custom estilo "line art" con acentos de color
- Micro-interacciones y animaciones sutiles
- Glassmorphism en elementos flotantes
- Gradientes suaves (azul→coral al atardecer)
- Iconografía Phosphor Icons (ya implementado)

---

## 1. 🔐 Login Screen

### Estado Actual
```
Elementos:
- Título "Finding Out" (texto simple)
- Subtítulo "Descubre eventos cerca de ti"
- Campo email con icono
- Campo contraseña con toggle visibility
- Link "¿Olvidaste tu contraseña?"
- Botón "Continuar" (primario)
- Divisor "o"
- Botón "Crear cuenta" (outlined)
```

### Lo que Falta / Debe Mejorar
- ❌ Sin ilustración hero o imagen de fondo
- ❌ Logo como texto, no hay logotipo visual
- ❌ Sin animaciones de entrada
- ❌ Campos de formulario genéricos
- ❌ Sin opciones de login social (Google, Apple)
- ❌ No hay indicador visual de la propuesta de valor

### 🎯 PROMPT PARA IA DE DISEÑO

```
Design a premium mobile login screen for "Finding Out" - a local events discovery app targeting young adults (18-35).

VISUAL STYLE:
- Mediterranean/Santorini aesthetic with modern minimalism
- Primary color: #1976D2 (Santorini blue), Accent: #FF7043 (coral)
- Clean white backgrounds with subtle warm cream tones
- Soft shadows and glassmorphism effects

HERO SECTION (Top 40%):
- Custom illustrated scene showing a lively city with event venues (concert, rooftop bar, art gallery)
- People discovering events on their phones, walking toward lit-up venues
- Sunset gradient from blue to coral in the illustration background
- App logo: stylized compass/pin icon merged with letter "F", modern geometric design

FORM SECTION (Middle):
- Floating card with subtle shadow and rounded corners (24px radius)
- Email input with envelope icon, pill-shaped with soft border
- Password input with lock icon and eye toggle
- "Forgot password?" link aligned right, subtle coral color
- Large "Continue" button with gradient (blue to slightly lighter blue), full width, 56px height
- Subtle loading animation when pressed (ripple effect)

BOTTOM SECTION:
- Elegant divider with "or continue with" text
- Social login buttons: Google and Apple (horizontal row, outlined style)
- "Create account" link with arrow icon
- Small tagline: "Join 50,000+ event explorers"

ANIMATIONS TO CONSIDER:
- Parallax effect on hero illustration
- Fields slide up sequentially on load
- Button has micro-interaction on tap

OUTPUT: High-fidelity mockup, iPhone 14 Pro frame, 390x844px, light mode
```

---

## 2. 📝 Register Screen

### Estado Actual
```
Elementos:
- Título similar a login
- Campo nombre completo
- Campo email
- Campo contraseña
- Campo confirmar contraseña
- Botón "Crear cuenta"
- Link "¿Ya tienes cuenta? Inicia sesión"
```

### Lo que Falta / Debe Mejorar
- ❌ Sin progress stepper (un solo paso largo)
- ❌ Sin ilustración contextual
- ❌ Sin validación visual inline
- ❌ Sin indicador de fortaleza de contraseña
- ❌ Demasiados campos en una sola vista

### 🎯 PROMPT PARA IA DE DISEÑO

```
Design a modern mobile registration screen for "Finding Out" - an events discovery app.

LAYOUT APPROACH:
- Multi-step registration (3 dots progress indicator at top)
- Step 1: Personal info (name, profile picture optional)
- Clean, focused form with ONE primary action per screen

HERO (Compact, 25%):
- Small illustrated header showing a person setting up their profile
- Character holding a ticket/pass with excitement
- Maintains blue/coral color scheme

STEP 1 - PROFILE SETUP:
- Circular avatar placeholder with camera plus icon (optional upload)
- "What should we call you?" friendly question format
- Single text input for display name
- Skip option for avatar in subtle text
- "Continue" button, same style as login

STEP 2 - ACCOUNT:
- Email field with real-time validation checkmark
- Password field with strength indicator (weak/medium/strong bars)
- Password requirements shown as checklist (8+ chars, number, etc.)
- Visual feedback: green checkmarks appear as requirements are met

STEP 3 - INTERESTS (Optional):
- "What events interest you?" header
- Grid of category chips with icons (Music, Sports, Food, Art, Tech, Nightlife, Outdoors, Comedy)
- Multi-select with animated bounce effect
- Skip option available

BOTTOM:
- Page dots indicator
- "Already have an account? Log in" link
- Privacy policy link in fine print

STYLE:
- Same Mediterranean aesthetic as login
- Progress feels lightweight, not bureaucratic
- Encouraging microcopy ("Almost there!", "Looking good!")

OUTPUT: Show all 3 steps as separate screens in a horizontal flow, iPhone 14 Pro
```

---

## 3. 🏠 Events Home Screen

### Estado Actual
```
Elementos:
- AppBar con título "Finding Out" y botón de búsqueda
- Header "Explora tu ciudad" + subtítulo
- Listados horizontales por categoría (CategorySection)
- Cada categoría tiene: título, "Ver todos", scroll horizontal de cards
- Event cards: imagen, título, fecha, ubicación
- Pull to refresh
```

### Lo que Falta / Debe Mejorar
- ❌ Sin featured/hero banner para evento destacado
- ❌ Sin personalización ("Para ti", "Trending cerca de ti")
- ❌ Sin stories/reels de eventos
- ❌ Sin sección de amigos que van a eventos
- ❌ Búsqueda solo abre bottom sheet vacío
- ❌ Sin filtros rápidos visibles
- ❌ Cards de eventos muy similares entre sí

### 🎯 PROMPT PARA IA DE DISEÑO

```
Design a vibrant events discovery home screen for "Finding Out" app - think Netflix meets Eventbrite for local events.

STRUCTURE (scrollable):

1. HEADER (sticky):
   - Location chip with pin icon "📍 Monterrey" (tappable to change)
   - Search bar (rounded, placeholder: "Search events, venues...")
   - Profile avatar (small circle, right side)

2. STORIES ROW (Instagram-style):
   - "Happening Now" live events as circular thumbnails
   - Gradient ring around active/live events (blue to coral)
   - First item: "Go Live" with camera icon for creators
   - Horizontal scroll, 4-5 visible

3. HERO BANNER (Featured Event):
   - Large card (full width, 200px height)
   - Stunning event photo with gradient overlay
   - Category badge floating (e.g., "🎵 Music")
   - Event title, date, "This Weekend" tag
   - Attendee avatars row (3 stacked circles + "+50")
   - Subtle parallax on scroll

4. QUICK FILTERS:
   - Horizontal chips: "Today", "This Weekend", "Free", "Near Me", "Friends Going"
   - Selected state: solid fill with white text
   - Non-selected: outlined or ghost style

5. "TRENDING NEAR YOU" Section:
   - Section title with fire emoji 🔥
   - Horizontal scroll of medium-sized cards
   - Cards show: image, title, venue, distance ("0.5 km")
   - Attendance indicator (profile pics + count)

6. "FRIENDS ARE GOING" Section:
   - Friend avatar + "María and 3 friends are going to..."
   - Event preview card
   - Creates FOMO and social proof

7. CATEGORY SECTIONS:
   - "🎵 Música" - horizontal scroll of event cards
   - Each card: image (16:9), gradient overlay at bottom, title, date pill
   - "Ver todos →" link aligned right
   - Repeat for: Deportes, Arte, Comida, Nightlife, Tech

8. BOTTOM SPACING:
   - 80px clear for floating navbar

VISUAL STYLE:
- Cards have subtle hover-lift shadow
- Smooth rounded corners (16px on cards)
- Category-colored accents on each section
- Skeleton loaders for images
- Lottie animation for empty states

NAVBAR (fixed bottom):
- 5 items: Home (active), Map, Create (+), Profile, Search
- Create button is elevated circle with gradient
- Active item has filled icon + label

OUTPUT: Full scrollable mockup showing all sections, iPhone 14 Pro, light mode
```

---

## 4. 🗺️ Map Screen

### Estado Actual
```
Elementos:
- Google Maps a pantalla completa
- Search bar flotante arriba
- Chips de categorías (horizontal scroll)
- Marcadores de eventos por categoría (coloreados)
- Controles de zoom (derecha)
- Botón "Mi ubicación"
- Panel "Eventos destacados" (bottom sheet colapsable)
- Si no hay ubicación: prompt para activarla
```

### Lo que Falta / Debe Mejorar
- ❌ Marcadores son los default de Google Maps (poco personalizados)
- ❌ Sin clustering de eventos cercanos
- ❌ Panel de eventos básico, sin preview rich
- ❌ Sin filtro por horario en el mapa
- ❌ Sin modo "ahora mismo" para eventos live

### 🎯 PROMPT PARA IA DE DISEÑO

```
Design an immersive event map discovery screen for "Finding Out" - think Google Maps meets Spotify's event feature.

MAP CORE:
- Full-bleed map with custom Santorini-style tiles (white buildings, blue water if coastal)
- Subtle desaturated map colors to make markers pop
- Custom event markers: circular badges with category icon inside
  - Music: purple gradient, music note
  - Sports: green, trophy/ball
  - Food: orange, fork/knife
  - Art: pink, palette
  - Nightlife: dark purple with glow effect, cocktail
- Clustered events show number badge ("5+") with pulsing animation

FLOATING UI ELEMENTS:

1. TOP SEARCH BAR:
   - Floating pill shape with glassmorphism (frosted glass effect)
   - Search icon, "Encuentra eventos...", filter button
   - Safe area respected

2. CATEGORY FILTERS (below search):
   - Floating horizontal chips
   - Same glass effect
   - Category icon + name, colored when selected
   - "All" option first

3. RIGHT SIDE CONTROLS:
   - Vertical stack: Compass, Zoom+, Zoom-, My Location
   - Compact circular buttons, glass effect
   - My location has pulse animation when tracking

4. BOTTOM SHEET (Collapsed state):
   - Handle bar at top
   - "Eventos destacados cerca de ti" with fire emoji
   - "Ver Top 10" button aligned right
   - Horizontal scroll preview of 3 event cards (compact)

5. BOTTOM SHEET (Expanded):
   - Pulls up to 60% of screen
   - Vertical list of events sorted by proximity
   - Each item: thumbnail, title, distance, time, attendees
   - "Voy" quick action button on each

6. EVENT PREVIEW (When marker tapped):
   - Small floating card appears near marker
   - Event image, title, time
   - "Ver detalles" and "Cómo llegar" buttons
   - Swipe to dismiss

7. LIVE NOW INDICATOR:
   - Special filter chip: "🔴 Ahora mismo"
   - Events happening right now have pulsing marker
   - Red/orange accent color for live events

SPECIAL STATES:
- Location permission needed: Friendly illustration of phone with compass, "Activa tu ubicación" card
- No events nearby: "Be the first! Create an event" with illustration

OUTPUT: Two mockups - one with bottom sheet collapsed, one with expanded. Show custom map style and markers. iPhone 14 Pro.
```

---

## 5. 👤 Profile Screen

### Estado Actual
```
Elementos:
- AppBar "Mi perfil"
- Avatar grande (circular) con iniciales o foto
- Nombre de usuario y email
- Botón "Editar perfil"
- Stats de seguidores/siguiendo
- Card "Cuenta" (miembro desde fecha)
- Card "Estadísticas" (eventos asistidos, creados, lugares favoritos)
- Card "Mis próximos eventos" (lista vertical)
- Botón "Cerrar sesión" (outlined, rojo)
```

### Lo que Falta / Debe Mejorar
- ❌ Diseño muy plano, sin personalidad
- ❌ Sin cover photo/banner
- ❌ Sin badges o logros
- ❌ Sin historial de eventos pasados
- ❌ Sin intereses/categorías preferidas visibles
- ❌ Sin integración social (compartir perfil)
- ❌ Stats no visuales (solo números)

### 🎯 PROMPT PARA IA DE DISEÑO

```
Design a premium user profile screen for "Finding Out" - think Instagram meets LinkedIn for event enthusiasts.

STRUCTURE:

1. HEADER BANNER (20% of screen):
   - Cover photo area with gradient overlay (user can customize)
   - Default: beautiful gradient from Santorini blue to coral sunset
   - Edit cover button (small pencil icon, floating)

2. PROFILE SECTION (overlapping header):
   - Large avatar (96px) with white ring border, overlapping header by 50%
   - Verification badge if applicable (blue checkmark)
   - Display name bold, large
   - Username subtle (@username)
   - Bio text (2 lines max, "Event explorer 🌴 Monterrey")
   - Location chip with pin icon

3. ACTION BUTTONS (horizontal row):
   - "Edit profile" (primary outlined)
   - "Share profile" (icon button with share icon)
   - Settings gear (icon button)

4. STATS GRID (visual and engaging):
   - Three columns in a card:
     - Events Attended: number + calendar icon + circular progress ring
     - Events Created: number + sparkle icon
     - Connections: followers/following count
   - Tappable to see details

5. ACHIEVEMENT BADGES:
   - Horizontal scroll of earned badges
   - Examples: "🥇 First Event", "🔥 5-Event Streak", "⭐ Top Creator", "🎉 Party Animal", "🌅 Early Bird"
   - Locked badges shown grayed with lock icon
   - This gamification increases engagement!

6. INTEREST CHIPS:
   - "My interests" section
   - Selected categories: Music, Tech, Food (colorful chips)
   - "Edit interests" link

7. UPCOMING EVENTS SECTION:
   - Card with vertical list
   - Each event: date badge (colored square with day/month), title, time
   - Empty state: "No upcoming events - Explore now" with illustration

8. PAST EVENTS (Collapsed default):
   - "View event history" expandable section
   - Shows last 3 attended events with photos
   - "See all" link

9. CREATED EVENTS:
   - If user is a creator, show their events
   - "My events" section with horizontal scroll

10. DANGER ZONE (Bottom):
    - "Sign out" in red text, no button
    - Small settings links: Privacy, Help, Terms

FOOTER SPACING: 100px for navbar

VISUAL STYLE:
- Cards with subtle shadows
- Stats should feel rewarding (progress rings, colors)
- Profile photo has shadow and pop
- Smooth fade from header to content

OUTPUT: Full scrollable mockup, iPhone 14 Pro, light mode. Show profile with sample data.
```

---

## 6. 🔍 User Search Screen

### Estado Actual
```
Elementos:
- AppBar "Buscar usuarios"
- TextField con placeholder "Buscar por nombre..."
- Empty state: icono + "Busca usuarios por su nombre"
- Search results: lista de cards con avatar, nombre, flecha
- Error state y no-results state
```

### Lo que Falta / Debe Mejorar
- ❌ Sin sugerencias de usuarios a seguir
- ❌ Sin búsqueda por intereses/eventos similares
- ❌ Sin "Personas que quizás conozcas"
- ❌ Sin filtros (solo nombre)
- ❌ Cards muy simples sin info útil

### 🎯 PROMPT PARA IA DE DISEÑO

```
Design a social discovery screen for "Finding Out" - finding people and making event buddies.

STRUCTURE:

1. SEARCH HEADER (sticky):
   - Large search bar with magnifying glass
   - Placeholder: "Find event buddies..."
   - Clear button (X) when text entered
   - Filter button (sliders icon)

2. FILTER CHIPS (below search):
   - "All", "Near Me", "Same Interests", "Mutual Friends"
   - Horizontal scroll

3. SUGGESTED SECTION (before search):
   Title: "People you might know 👋"
   - Based on mutual events, interests, location
   - Horizontal scroll of profile cards
   - Each card: Avatar, Name, mutual interests/events indicator
   - "Follow" button on each

4. QUICK CONNECT SECTION:
   Title: "Going to the same events 🎉"
   - People attending same upcoming events as user
   - Shows event name as connection reason
   - "Wave" or "Connect" action

5. SEARCH RESULTS:
   - Vertical list when searching
   - Rich cards with:
     - Avatar (larger, 48px)
     - Display name + username
     - Mutual connections ("5 mutual friends")
     - Shared interests (2-3 chips)
     - "Follow" button (right aligned)

6. RESULT EMPTY STATE:
   - Friendly illustration of binoculars searching
   - "No explorers found with that name"
   - "Invite friends" CTA button

7. INVITE FRIENDS CTA (bottom):
   - Floating card or banner
   - "Invite friends to Finding Out"
   - Share button
   - Small bonus: "Get a badge when 3 friends join!"

VISUAL:
- Social and friendly vibe
- Emphasis on connections and mutual context
- Avatar-forward design
- Follow buttons have satisfying filled state transition

OUTPUT: Two states - empty with suggestions, and with search results. iPhone 14 Pro.
```

---

## 7. 📅 Event Detail Screen

### Estado Actual
```
Elementos:
- SliverAppBar con hero image (280px height)
- Botones back y share flotantes
- Título del evento
- Badge de categoría
- Stats de asistentes (going/interested)
- Info cards: Fecha, Hora, Ubicación
- Botones "Voy" / "Me interesa"
- Descripción del evento
- Sección "Amigos que van"
- Card del organizador
```

### Lo que Falta / Debe Mejorar
- ❌ Sin gale ría de fotos (solo 1 imagen)
- ❌ Sin mapa preview inline
- ❌ Sin reviews/comentarios
- ❌ Sin botón "Agregar a calendario"
- ❌ Sin precio/entradas info
- ❌ Sin eventos relacionados
- ❌ Attendance stats podrían ser más visuales

### 🎯 PROMPT PARA IA DE DISEÑO

```
Design an immersive event detail screen for "Finding Out" - combining the best of Eventbrite's info with Instagram's visual appeal.

STRUCTURE:

1. HERO SECTION (40% of screen):
   - Full-bleed image carousel (dots indicator)
   - Swipe for multiple event photos
   - Gradient overlay (bottom darker)
   - Floating back button (circle, blur background)
   - Floating action buttons: Share, Save/Bookmark, Calendar

2. TITLE AREA:
   - Category badge (colored chip with icon)
   - Event title (large, bold, 2 lines max)
   - Hosted by: Organizer avatar + name (tappable)

3. KEY INFO STRIP:
   - Horizontal scroll of info pills:
     - 📅 Date & Time
     - 📍 Distance (if location known)
     - 💵 Price / Free badge
     - 👥 Attendees count
   - Tappable for more details

4. ATTENDANCE SECTION (Prominent):
   - Large buttons side by side:
     - "Voy" (Going) - Solid primary button with check icon
     - "Me interesa" - Outlined with heart icon
   - Below: Attendee avatars row (overlapping circles)
   - "María, Juan y 48 más van" social proof text

5. FRIENDS ATTENDING (If any):
   - Special highlight card with warm background
   - "3 amigos van a este evento 🎉"
   - Avatar row with names
   - Creates FOMO / social motivation

6. QUICK ACTIONS ROW:
   - Icon buttons: Add to Calendar, Get Directions, Share with Friend
   - Horizontally spaced, labeled below each

7. ABOUT SECTION:
   - "Acerca del evento" header
   - Expandable text (3 lines preview + "Read more")
   - Tags/keywords at bottom

8. LOCATION SECTION:
   - Inline map preview (small, 120px height)
   - Address text below
   - "Open in Maps" and "Copy address" links
   - Distance from user's location

9. ORGANIZER SECTION:
   - Card with organizer info
   - Avatar, name, verified badge
   - Follower count, events hosted count
   - "Follow" and "Contact" buttons

10. RELATED EVENTS:
    - "También te puede gustar" section
    - Horizontal scroll of similar event cards
    - Based on category or same organizer

11. COMMENTS/HYPE SECTION:
    - "Comentarios" section
    - Show 2-3 most recent comments
    - "Ver todos los comentarios" link
    - Add comment input at bottom (avatar + text field)

BOTTOM PADDING: 100px for navbar

VISUAL:
- Image carousel feels premium
- Info is scannable at a glance
- CTAs (Going/Interested) are prominent
- Social proof everywhere
- Map adds credibility

OUTPUT: Full scrollable mockup with all sections. iPhone 14 Pro, light mode.
```

---

## 8. ✨ Create Event Screen

### Estado Actual
```
Elementos:
- AppBar "Crear Evento"
- Form fields: Título, Descripción, Categoría dropdown
- Image picker area
- Date/time selectors (inline row buttons)
- Address autocomplete field
- Map picker button
- Submit button "Crear Evento"
```

### Lo que Falta / Debe Mejorar
- ❌ Diseño muy formulario típico
- ❌ Sin preview de cómo se verá el evento
- ❌ Sin sugerencias/tips mientras escriben
- ❌ Sin templates para eventos comunes
- ❌ Sin guardado de borrador
- ❌ Sin opciones de tickets/pricing
- ❌ Sin co-hosts/colaboradores

### 🎯 PROMPT PARA IA DE DISEÑO

```
Design an inspiring event creation experience for "Finding Out" - make users excited to host events!

APPROACH: Progressive disclosure, step-by-step wizard (not overwhelming form)

STEP 1 - BASICS:
Header: "Let's create something amazing ✨"

- Event photo upload (large, prominent area)
  - Drag & drop zone with dashed border
  - Camera icon + "Add a stunning cover photo"
  - AI suggestion: "Tip: Events with photos get 5x more views"
  
- Title input (large, prominent)
  - Character counter
  - "What's your event called?"
  
- Category picker (grid of icons)
  - 8 categories with colorful icons
  - Single select, animated selection

"Continue" button at bottom

STEP 2 - WHEN & WHERE:

Date & Time Section:
- Visual calendar picker (inline, not pop-up)
- Time slots as selectable chips for quick selection
- Duration picker (1h, 2h, 3h, Custom)
- "Multi-day event" toggle

Location Section:
- Search bar for address
- "Use my current location" button
- Small map preview that updates
- "Select on map" for precision

"Continue" button

STEP 3 - DETAILS:

- Description textarea (larger, full width)
  - Formatting hints: bullet points, emojis encouraged
  - "Tell people what to expect..."
  
- Tags input (chips)
  - Suggested tags based on category
  
- Event Settings:
  - Public/Private toggle
  - Allow comments toggle
  - Capacity limit (optional number input)

- Pricing Section (collapsed by default):
  - Free event toggle (default on)
  - If paid: price input + currency
  - "Tickets via external link" option

STEP 4 - PREVIEW:

- "Here's how it looks! 🎉"
- Full preview mimicking the event detail screen
- Edit buttons on each section to go back
- Final "Publish Event" button (large, gradient, celebratory)

POST-PUBLISH:
- Confetti animation
- "Your event is live!" celebration screen
- Quick actions: Share, Invite friends, View event
- "Create another" link

PROGRESS:
- Top progress bar or step indicators
- Can swipe back anytime
- Save draft automatically (show "Draft saved" feedback)

VISUAL:
- Clean, spacious design
- Illustrations for each step (small, corner)
- Encouraging microcopy throughout
- Form should feel fun, not tedious

OUTPUT: Show all 4 steps as separate screens in a flow. iPhone 14 Pro.
```

---

## 🎁 Bonus: Value-Add Features to Consider

Estos elementos diferenciarían Finding Out de la competencia:

### Para Usuarios
1. **Event Stories** - Quick reels de eventos en vivo
2. **Event Buddy Matching** - Encontrar gente con intereses similares
3. **Achievements System** - Badges por asistir a eventos
4. **Event Memories** - Fotos compartidas post-evento
5. **Personalized Feed** - AI que aprende gustos

### Para Organizadores
1. **Analytics Dashboard** - Views, conversions, demographics
2. **Promoción Boost** - Pago para mayor visibilidad (monetización)
3. **Ticket Integration** - Vender entradas directamente
4. **Check-in QR** - Escanear asistentes
5. **Co-host Invites** - Organizar en equipo

### Social/Viral
1. **Event Challenges** - "Asiste a 5 eventos este mes"
2. **Leaderboards** - Top event-goers de tu ciudad
3. **Referral Program** - Invita amigos, gana recompensas

---

## 📋 Cómo Usar Estos Prompts

1. **Midjourney/DALL-E**: Usa los prompts textuales directamente, añade `--ar 9:19` para proporción móvil
2. **Figma AI**: Adapta los prompts describiendo componentes individuales
3. **Galileo AI**: Pega el prompt completo, genera UI
4. **Claude/GPT**: Puede generar código Flutter basado en estos specs

### Modificadores Útiles para IA de Imágenes:
```
- "UI design, Figma mockup, iPhone 14 Pro, 390x844"
- "high fidelity, Dribbble quality, light mode"  
- "Material Design 3, modern app, premium feel"
- "Mediterranean color palette, blue and coral accents"
```

---

*Documento generado para Finding Out - Febrero 2026*
*Usa estos prompts como punto de partida y ajusta según feedback del equipo*
