#### Sources
sources = [
  {
    name: "Amazon",
    slug: "amazon",
    base_url: "https://www.amazon.nl",
    shipping_cost: 2.99,
    shipping_cost_currency: "EUR",
    shipping_cost_free_from_price: 20.0,
    shipping_cost_free_from_quantity: 0
  },
  {
    name: "Amazon RetourDeals",
    slug: "amazon-retourdeals",
    base_url: "https://www.amazon.nl",
    shipping_cost: 2.99,
    shipping_cost_currency: "EUR",
    shipping_cost_free_from_price: 20.0,
    shipping_cost_free_from_quantity: 0
  },
  {
    name: "Boeken.nl",
    slug: "boeken-nl",
    base_url: "https://www.boeken.nl",
    shipping_cost: 2.95,
    shipping_cost_currency: "EUR",
    shipping_cost_free_from_price: 19.95,
    shipping_cost_free_from_quantity: 0
  },
  {
    name: "Bruna",
    slug: "bruna",
    base_url: "https://bruna.nl",
    shipping_cost: 2.95,
    shipping_cost_currency: "EUR",
    shipping_cost_free_from_price: 20.0,
    shipping_cost_free_from_quantity: 0
  },
  {
    name: "Boekenbalie",
    slug: "boekenbalie",
    base_url: "https://www.boekenbalie.nl",
    shipping_cost: 3.15,
    shipping_cost_currency: "EUR",
    shipping_cost_free_from_price: 40.0,
    shipping_cost_free_from_quantity: 4
  },
  {
    name: "Voordeelboekenonline.nl",
    slug: "voordeelboekenonline",
    base_url: "https://www.voordeelboekenonline.nl",
    shipping_cost: 3.5,
    shipping_cost_currency: "EUR",
    shipping_cost_free_from_price: 0.0,
    shipping_cost_free_from_quantity: 0
  },
  {
    name: "Readshop",
    slug: "readshop",
    base_url: "https://www.readshop.nl",
    shipping_cost: 2.95,
    shipping_cost_currency: "EUR",
    shipping_cost_free_from_price: 20.0,
    shipping_cost_free_from_quantity: 0
  },
  {
    name: "De Slegte",
    slug: "de-slegte",
    base_url: "https://www.deslegte.com",
    shipping_cost: 3.5,
    shipping_cost_currency: "EUR",
    shipping_cost_free_from_price: 20.0,
    shipping_cost_free_from_quantity: 0
  },
  {
    name: "Bol.com",
    slug: "bol",
    base_url: "https://www.bol.com",
    shipping_cost: 2.99,
    shipping_cost_currency: "EUR",
    shipping_cost_free_from_price: 25.0,
    shipping_cost_free_from_quantity: 0
  },
  {
    name: "Bol.com Partners",
    slug: "bol-partners",
    base_url: "https://www.bol.com",
    shipping_cost: 0,
    shipping_cost_currency: "EUR",
    shipping_cost_free_from_price: 0,
    shipping_cost_free_from_quantity: 0
  },
  {
    name: "Paagman",
    slug: "paagman",
    base_url: "https://www.paagman.nl",
    shipping_cost: 4.95,
    shipping_cost_currency: "EUR",
    shipping_cost_free_from_price: 20.0,
    shipping_cost_free_from_quantity: 0
  },
  {
    name: "Boekenkraam",
    slug: "boekenkraam",
    base_url: "https://www.boekenkraam.nl",
    shipping_cost: 3.99,
    shipping_cost_currency: "EUR",
    shipping_cost_free_from_price: 42.5,
    shipping_cost_free_from_quantity: 0
  },
  {
    name: "Donner",
    slug: "donner",
    base_url: "https://www.donner.nl",
    shipping_cost: 2.9,
    shipping_cost_currency: "EUR",
    shipping_cost_free_from_price: 15.0,
    shipping_cost_free_from_quantity: 0
  },
  {
    name: "Broese",
    slug: "broese",
    base_url: "https://www.broese.nl",
    shipping_cost: 2.95,
    shipping_cost_currency: "EUR",
    shipping_cost_free_from_price: 20.0,
    shipping_cost_free_from_quantity: 0
  },
  {
    name: "Booknext",
    slug: "booknext",
    base_url: "https://www.booknext.nl",
    shipping_cost: 1.95,
    shipping_cost_currency: "EUR",
    shipping_cost_free_from_price: 0,
    shipping_cost_free_from_quantity: 0
  }
]

sources.each do |attributes|
  Source.find_or_create_by!(slug: attributes[:slug]) do |source|
    source.assign_attributes(attributes)

    puts "Created source: #{attributes[:name]}"
  end
end

#### Genres

def create_genre(name, slug, parent_slug = nil, keywords: "")
  parent = Genre.find_by!(slug: parent_slug) if parent_slug

  Genre.find_or_create_by!(slug: slug) do |genre|
    genre.name = name
    genre.keywords = keywords
    genre.parent_genre_id = parent&.id

    puts "Created genre: #{name}"
  end
end

### Primary genres
create_genre("Fictie", "fictie", nil, keywords: "Fiction")
create_genre("Non-fictie", "non-fictie", nil, keywords: "Nonfiction")
create_genre("Kookboeken", "kookboeken", nil, keywords: "Cookbooks")

## Fiction

# Novel
create_genre("Romans", "romans", "fictie", keywords: "Novel, Novels")
create_genre("Novella", "novella", "fictie", keywords: "Novella")
create_genre("Korte verhalen", "korte-verhalen", "fictie", keywords: "Short Stories, Collections, Short Story Collection")
create_genre("Literaire romans", "literaire-romans", "romans", keywords: "Literature")
create_genre("Historische romans", "historische-romans", "romans", keywords: "Historical Fiction")

# Thriller
create_genre("Thrillers", "thrillers", "fictie", keywords: "Thrillers, Thriller")
create_genre("Detective", "detective", "thrillers", keywords: "Detective")
create_genre("Whodunit", "whodunit", "detective", keywords: "Whodunit")
create_genre("Noir", "noir", "detective", keywords: "Noir")
create_genre("Mysterie", "mysterie", "thrillers", keywords: "Mystery")
create_genre("Spannend", "spanning", "thrillers", keywords: "Suspense")
create_genre("Misdaad", "misdaad", "thrillers", keywords: "Crime")
create_genre("Spionage", "spionage", "thrillers", keywords: "Spy, Espionage, Spy Thriller")
create_genre("Psychologische Thriller", "psychologische-thriller", "thrillers", keywords: "Psychological Thriller, Psychological")

# Scifi
create_genre("Scifi", "scifi", "fictie", keywords: "Sci-fi, Science Fiction, Sciencefiction")
create_genre("Dystopisch", "dystopisch", "scifi", keywords: "Dystopia, Dystopian")
create_genre("Utopisch", "utopisch", "scifi", keywords: "Utopia, Utopian")
create_genre("Apocalyptisch", "apocalyptisch", "scifi", keywords: "Apocalypse")
create_genre("Space opera", "space-opera", "scifi", keywords: "Space Opera")
create_genre("Tijdreizen", "tijdreizen", "scifi", keywords: "Timetravel, Time Travel")
create_genre("Cyberpunk", "cyberpunk", "scifi", keywords: "Cyperpunk")
create_genre("Aliens", "aliens", "scifi", keywords: "Aliens")
create_genre("First contact", "first-contact", "aliens", keywords: "First Contact")

# Fantasy
create_genre("Fantasy", "fantasy", "fictie", keywords: "Fantasy")
create_genre("High fantasy", "high-fantasy", "fantasy", keywords: "High Fantasy")
create_genre("Urban fantasy", "urban-fantasy", "fantasy", keywords: "Urban Fantasy")
create_genre("Epische fantasy", "epische-fantasy", "fantasy", keywords: "Epic Fantasy")
create_genre("Dark fantasy", "dark-fantasy", "fantasy", keywords: "Dark Fantasy")

# Horror
create_genre("Horror", "horror", "fictie", keywords: "Horror")
create_genre("Bovennatuurlijk", "bovennatuurlijk", "horror", keywords: "Supernatural, Paranormal, Ghost Stories, Ghosts")
create_genre("Klassieke horror", "klassieke-horror", "horror", keywords: "Classic Horror")
create_genre("Monster horror", "monster-horror", "horror", keywords: "Monster Horror")
create_genre("Lovecraftian", "lovecraftian", "horror", keywords: "Lovecraftian")
create_genre("Zombies", "Zombies", "horror", keywords: "Zombies")

# Children
create_genre("Kinderboeken", "kinderboeken", "fictie", keywords: "Children")
create_genre("Prentenboeken", "prentenboeken", "kinderboeken", keywords: "Picture Books")
create_genre("Voorleesboeken", "voorleesboeken", "kinderboeken", keywords: "Storytime")
create_genre("Avonturenverhalen", "avonturenverhalen", "kinderboeken", keywords: "Chapter Books")

# Romance
create_genre("Romantiek", "romantiek", "fictie", keywords: "Romance")
create_genre("Historische romantiek", "historische-romantiek", "romantiek", keywords: "Historical Romance")
create_genre("Moderne romantiek", "moderne-romantiek", "romantiek", keywords: "Contemporary Romance")
create_genre("Romantische komedie", "romantische-komedie", "romantiek", keywords: "Romantic Comedy")

# Random
create_genre("Young Adult", "young-adult", "fictie", keywords: "Young Adult")
create_genre("LGBTQ+", "lgbtq", "fictie", keywords: "LGBTQ+, LGBT, Gay, Lesbian, Queer, Bisexual")
create_genre("Feelgood", "feelgood", "fictie", keywords: "Feelgood, Feel Good")
create_genre("Knus", "knus", "fictie", keywords: "Cozy")
create_genre("Humor", "humor", "fictie", keywords: "Humor, Comedy")
create_genre("Militaire fictie", "militaire-fictie", "fictie", keywords: "Military Fiction")
create_genre("Avontuur", "avontuur", "fictie", keywords: "Adventure")
create_genre("Actie", "actie", "fictie", keywords: "Action")

## Non-fictie
create_genre("Biografieën", "biografieen", "non-fictie", keywords: "Biographies, Biography")
create_genre("Waargebeurde verhalen", "waargebeurde-verhalen", "non-fictie", keywords: "True Stories, True Story")
create_genre("Reizen & Cultuur", "reizen-cultuur", "non-fictie", keywords: "Travel, Culture")
create_genre("Economie", "economie", "non-fictie", keywords: "Economics")
create_genre("Educatie", "educatie", "non-fictie", keywords: "Education, Learning, Study")
create_genre("Financiën", "financien", "non-fictie", keywords: "Personal Finance, Money")

# Politics
create_genre("Maatschappij & Politiek", "maatschappij-politiek", "non-fictie", keywords: "Politics, Society")

# Mindset
create_genre("Zelfhulp", "zelfhulp", "non-fictie", keywords: "Self Help, Self")
create_genre("Spiritualiteit & Religie", "spiritualiteit-religie", "non-fictie", keywords: "Religion, Spirituality")
create_genre("Mindfulness", "mindfulness", "non-fictie", keywords: "Mindfulness")
create_genre("Gezondheid", "gezondheid", "non-fictie", keywords: "Health, Healthy")

# Science
create_genre("Wetenschap & Natuur", "wetenschap-natuur", "non-fictie", keywords: "Nature, Science")
create_genre("Astronomie", "astronomie", "wetenschap-natuur", keywords: "Astronomy")
create_genre("Biologie", "biologie", "wetenschap-natuur", keywords: "Biology")
create_genre("Ecologie", "ecologie", "wetenschap-natuur", keywords: "Ecology")

# Art & Culture
create_genre("Kunst & Cultuur", "kunst-cultuur", "non-fictie", keywords: "Art, Culture")
create_genre("Muziek", "muziek", "kunst-cultuur", keywords: "Music")
create_genre("Film & TV", "film-tv", "kunst-cultuur", keywords: "Film, Television, TV")
create_genre("Architectuur", "architectuur", "kunst-cultuur", keywords: "Architecture")

# Language
create_genre("Taal", "taal", "non-fictie", keywords: "Language, ")

# Cookbooks
create_genre("Vegetarisch", "vegetarisch", "kookboeken", keywords: "vegetarian")
create_genre("Vegen", "vegen", "kookboeken", keywords: "vegan")
create_genre("Bakken & Desserts", "bakken-desserts", "kookboeken", keywords: "Desserts, Baking")
create_genre("Dieet & Voeding", "dieet-voeding", "kookboeken", keywords: "Diet")
create_genre("Dranken", "dranken", "kookboeken", keywords: "Alcohol, Beverages")
create_genre("Gastronomie", "gastronomie", "kookboeken", keywords: "Gastronomy")
