defmodule FootballMarket.Providers.PlayerIdentity do
  @moduledoc "Exact player-name equivalence with observed aliases restricted to league and club."
  alias FootballMarket.Providers.TeamIdentity

  # Club/league evidence is recorded in TASK-094; aliases never enable fuzzy matching.
  @aliases %{
    {"PD", "deportivo alaves", "abde rebbach"} => "Abderrahman Rebbach",
    {"PD", "elche", "adam"} => "Adam Boayar",
    {"PD", "deportivo alaves", "yusi"} => "Youssef Enríquez",
    {"BL1", "hamburger", "albert gronbaek erlykke"} => "Albert Grønbæk",
    {"BL1", "bayern munchen", "min jae kim"} => "Kim Min-Jae",
    {"BL1", "borussia monchengladbach", "iaia manco danfa"} => "Iaia Danfa",
    {"BL1", "union berlin", "linus guether"} => "Linus Güther",
    {"BL1", "schalke", "chikwubuike adamu"} => "Chukwubuike Adamu",
    {"BL1", "hamburger", "daniel fernandes"} => "Daniel Heuer Fernandes",
    {"BL1", "hamburger", "david wolfe"} => "David Møller Wolfe",
    {"BL1", "schalke", "dina ebimbe"} => "Junior Dina Ebimbe",
    {"BL1", "mainz", "lennart maloney"} => "Lennard Maloney",
    {"BL1", "mainz", "philipp mwene"} => "Phillipp Mwene",
    {"BL1", "borussia dortmund", "sehrou guirassy"} => "Serhou Guirassy",
    {"BL1", "schalke", "soufiane el faouzi"} => "Soufian El-Faouzi",
    {"BL1", "bayer leverkusen", "victor boniface"} => "Victor Okoh Boniface",
    {"BL1", "rb leipzig", "orjan nyland"} => "Ørjan Håskjold Nyland",
    {"FL1", "lorient", "isak jensen"} => "Isak Steiner Jensen",
    {"FL1", "le havre", "lionel mpasi"} => "Lionel Mpasi-Nzau",
    {"FL1", "brest", "luc zogbe"} => "Luck Zogbé",
    {"FL1", "paris saint germain", "matvei safonov"} => "Matvey Safonov",
    {"FL1", "troyes", "merwan ifnaoui"} => "Merwan Ifnaou",
    {"FL1", "lens", "mezian soares"} => "Mezian Mesloub Soares",
    {"FL1", "lens", "mickael cuisance"} => "Michaël Cuisance",
    {"FL1", "nice", "mohammed amoura"} => "Mohamed Amoura",
    {"FL1", "angers", "ousman camara"} => "Ousmane Camara",
    {"FL1", "strasbourg", "pape diop"} => "Pape Demba Diop",
    {"FL1", "lorient", "srdan kuzmic"} => "Srdjan Kuzmić",
    {"FL1", "troyes", "timothee nkada"} => "Timothé Nkada",
    {"FL1", "marseille", "tochukwu nadi"} => "Tochukwu Nnadi",
    {"FL1", "paris saint germain", "william pacho"} => "Willian Pacho",
    {"PD", "deportivo alaves", "alena"} => "Carles Aleñá",
    {"PD", "racing santander", "arana"} => "Juan Carlos Arana",
    {"PD", "real betis", "bartra"} => "Marc Bartra",
    {"PD", "elche", "buba"} => "Buba Sangaré",
    {"PD", "racing santander", "canales"} => "Sergio Canales",
    {"PD", "osasuna", "catena"} => "Alejandro Catena",
    {"PD", "atletico madrid", "christian romero"} => "Cristian Romero",
    {"PD", "valencia", "copete"} => "José Copete",
    {"PD", "valencia", "cristian"} => "Cristian Rivero",
    {"PD", "real betis", "cucho hernandez"} => "Juan Hernández",
    {"PD", "real madrid", "cucurella"} => "Marc Cucurella",
    {"PD", "valencia", "gaya"} => "José Gayà",
    {"PD", "sevilla", "isaac"} => "Isaac Romero",
    {"PD", "atletico madrid", "johnny"} => "Johnny Cardoso",
    {"PD", "espanyol", "moscardo"} => "Gabriel Moscardo",
    {"PD", "real sociedad", "ochieng"} => "Job Ochieng",
    {"PD", "sevilla", "odisseas vlachodimos"} => "Odysseas Vlachodimos",
    {"PD", "rayo vallecano", "pedrosa"} => "Adrià Pedrosa",
    {"PD", "sevilla", "peque"} => "Peque Fernández",
    {"PD", "malaga", "puga"} => "Carlos Puga",
    {"PD", "rayo vallecano", "randy ntekja"} => "Randy Nteka",
    {"PD", "real madrid", "raul"} => "Raúl Asencio",
    {"PD", "athletic club", "roberto navarro"} => "Robert Navarro",
    {"PD", "athletic club", "ruiz de galarreta"} => "Iñigo Ruiz de Galarreta",
    {"PD", "racing santander", "salinas"} => "Jorge Salinas",
    {"PD", "athletic club", "sannadi"} => "Maroan Sannadi",
    {"PD", "deportivo alaves", "sivera"} => "Antonio Sivera",
    {"PD", "athletic club", "unai egiluz"} => "Unai Eguiluz",
    {"PD", "getafe", "valou"} => "Jean Ives Valou",
    {"PD", "getafe", "zaid romero"} => "Zaid Abner Romero",
    {"PL", "aston villa", "alysson"} => "Alysson Edward",
    {"PL", "nottingham forest", "arnaud kalimuendo"} => "Arnaud Kalimuendo-Muinga",
    {"PL", "crystal palace", "cheick doucoure"} => "Cheick Oumar Doucouré",
    {"PL", "sunderland", "jocelin bi"} => "Jocelin Ta Bi",
    {"PL", "liverpool", "joe gomez"} => "Joseph Gomez",
    {"PL", "nottingham forest", "john"} => "John Victor",
    {"PL", "bournemouth", "juanlu"} => "Juanlu Sánchez",
    {"PL", "coventry city", "kaine kesler"} => "Kaine Kesler-Hayden",
    {"PL", "brighton hove albion", "malick yalcouye"} => "Malick Junior Yalcouyé",
    {"PL", "tottenham hotspur", "mickey van de ven"} => "Micky van de Ven",
    {"PL", "tottenham hotspur", "mykhailo mudryk"} => "Mykhaylo Mudryk",
    {"PL", "ipswich town", "sindre egeli"} => "Sindre Walle Egeli",
    {"PL", "brentford", "thiago"} => "Igor Thiago",
    {"PL", "everton", "vitalii mykolenko"} => "Vitaliy Mykolenko",
    {"PL", "brighton hove albion", "yankubah minteh"} => "Yankuba Minteh",
    {"SA", "milan", "ardon jasari"} => "Ardon Jashari",
    {"SA", "juventus", "bremer"} => "Gleison Bremer",
    {"SA", "inter", "carlos"} => "Carlos Augusto",
    {"SA", "lazio", "filipe"} => "Filipe Bordon",
    {"SA", "inter", "francesco esposito"} => "Francesco Pio Esposito",
    {"SA", "milan", "gila"} => "Mario Gila",
    {"SA", "juventus", "khephren thuram ulie"} => "Khéphren Thuram-Ulien",
    {"SA", "como", "lorenzo ginelli"} => "Lorenzo Luigi Ginelli",
    {"SA", "cagliari", "michel adopo"} => "Michel Ndary Adopo",
    {"SA", "monza", "yvan maye"} => "Yvan Kouadio Maye",
    {"BL1", "hamburger", "alexander rossing lelesiit"} => "Alexander Røssing",
    {"BL1", "elversberg", "david mokwa ntusu"} => "David Mokwa",
    {"BL1", "borussia dortmund", "felix kalu nmecha"} => "Felix Nmecha",
    {"BL1", "borussia monchengladbach", "jan jakob olschowsky"} => "Jan Olschowsky",
    {"BL1", "stuttgart", "julian chabot"} => "Jeff Chabot",
    {"BL1", "borussia dortmund", "kouakou gadou"} => "Joane Gadou",
    {"BL1", "elversberg", "look sa nicholas mickelson"} => "Nicholas Mickelson",
    {"BL1", "borussia monchengladbach", "nicolas kuhn"} => "Nicolas-Gerrit Kühn",
    {"BL1", "eintracht frankfurt", "noel aseko nkili"} => "Noël Aséko",
    {"BL1", "union berlin", "ohis uduokhai"} => "Felix Uduokhai",
    {"BL1", "rb leipzig", "romulo cruz"} => "Rômulo",
    {"BL1", "mainz", "silas wamangituka"} => "Silas Katompa Mvumpa",
    {"BL1", "eintracht frankfurt", "timmy chandler"} => "Timothy Chandler",
    {"BL1", "augsburg", "young woo seol"} => "Seol Young-Woo",
    {"BL1", "koln", "isak bergmann johannesson"} => "Ísak Jóhannesson",
    {"FL1", "lille", "alexsandro ribeiro"} => "Alexsandro",
    {"FL1", "nice", "ali el abdi"} => "Ali Abdi",
    {"FL1", "lorient", "arthur ebong"} => "Arthur Avom",
    {"FL1", "toulouse", "cristian casseres jr"} => "Cristian Cásseres",
    {"FL1", "auxerre", "daniel namaso"} => "Danny Namaso",
    {"FL1", "le havre", "elias jelert kristensen"} => "Elias Jelert",
    {"FL1", "rennes", "elias legendre quinonez"} => "Elías Legendre",
    {"FL1", "strasbourg", "gio reyna"} => "Giovanni Reyna",
    {"FL1", "paris saint germain", "illia zabarnyi"} => "Ilya Zabarnyi",
    {"FL1", "troyes", "ismaelben boura"} => "Ismaël Boura",
    {"FL1", "brest", "joseph nonge"} => "Joseph Boende",
    {"FL1", "lyon", "justin jose bengui joao"} => "Justin Bengui",
    {"FL1", "lorient", "kan guy arsene kouassi"} => "Arsène Kouassi",
    {"FL1", "troyes", "karim dermane"} => "Dermane Karim",
    {"FL1", "paris saint germain", "lucas beraldo"} => "Beraldo",
    {"FL1", "lille", "nianzou kouassi"} => "Tanguy Nianzou",
    {"FL1", "paris", "otavio ataide"} => "Otávio",
    {"FL1", "troyes", "paolo gozzi iweru"} => "Paolo Gozzi",
    {"FL1", "nice", "sepe elye wahi"} => "Elye Wahi",
    {"FL1", "monaco", "stanis idumbo muzambo"} => "Stanis Idumbo",
    {"FL1", "marseille", "tim weah"} => "Timothy Weah",
    {"PD", "athletic club", "aitor paredes casamichana"} => "Aitor Paredes",
    {"PD", "atletico madrid", "alejandro baena"} => "Álex Baena",
    {"PD", "malaga", "alex pastor carayol"} => "Álex Pastor",
    {"PD", "sevilla", "alfonso gonzalez"} => "Alfon González",
    {"PD", "deportivo alaves", "carlos benavidez"} => "Carlos Protesoni",
    {"PD", "getafe", "dakonam djene"} => "Djené",
    {"PD", "deportivo a coruna", "ede bright"} => "Bright Ede",
    {"PD", "malaga", "eneko jauregi escobar"} => "Eneko Jauregi",
    {"PD", "rayo vallecano", "georgiy tsitaishvili"} => "Giorgi Tsitaishvili",
    {"PD", "celta vigo", "javier galan"} => "Javi Galán",
    {"PD", "malaga", "jens cajuste"} => "Jens-Lys Cajuste",
    {"PD", "valencia", "jesus vazquez alcalde"} => "Jesús Vázquez",
    {"PD", "espanyol", "jofre carreras pages"} => "Jofre Carreras",
    {"PD", "deportivo a coruna", "jonathan asp jensen"} => "Jonathan Asp",
    {"PD", "elche", "josan fernandez"} => "Josan",
    {"PD", "levante", "karl etta eyong"} => "Etta Eyong",
    {"PD", "osasuna", "kike barja"} => "Enrique Barja",
    {"PD", "malaga", "lopez nogueras"} => "Carlos López",
    {"PD", "villarreal", "luiz lucio reis junior"} => "Luíz Júnior",
    {"PD", "levante", "maty ryan"} => "Mathew Ryan",
    {"PD", "villarreal", "nathan dylan saliba"} => "Nathan Saliba",
    {"PD", "deportivo a coruna", "nsongo tonfack"} => "Bil Nsongo",
    {"PD", "real sociedad", "orri steinn oskarsson"} => "Orri Óskarsson",
    {"PD", "levante", "pablo cunat"} => "Pablo Campos",
    {"PD", "deportivo alaves", "pablo ibanez tebar"} => "Pablo Ibáñez",
    {"PD", "malaga", "ramon enriquez rodriguez"} => "Ramón Enríquez",
    {"PD", "getafe", "ramonterrats espacio"} => "Ramón Terrats",
    {"PL", "ipswich town", "abdul issahaku"} => "Abdul Fatawu",
    {"PL", "everton", "carlos alcaraz"} => "Charly Alcaraz",
    {"PL", "crystal palace", "eddie nketiah"} => "Edward Nketiah",
    {"PL", "brentford", "el hadji malick diouf"} => "Malick Diouf",
    {"PL", "bournemouth", "eli kroupi"} => "Junior Kroupi",
    {"PL", "arsenal", "gabriel magalhaes"} => "Gabriel",
    {"PL", "chelsea", "jamie bynoe gittens"} => "Jamie Gittens",
    {"PL", "leeds united", "jean bahoya"} => "Jean-Mattéo Bahoya",
    {"PL", "newcastle united", "joe willock"} => "Joseph Willock",
    {"PL", "liverpool", "kostas tsimikas"} => "Konstantinos Tsimikas",
    {"PL", "brighton hove albion", "matt oriley"} => "Matthew O'Riley",
    {"PL", "hull city", "oliver mcburnie"} => "Oli McBurnie",
    {"PL", "brighton hove albion", "promise akinpelu"} => "Promise David",
    {"PL", "hull city", "ryan john giles"} => "Ryan Giles",
    {"PL", "brentford", "yegor yarmolyuk"} => "Yehor Yarmoliuk",
    {"SA", "genoa", "alexsandro amorim"} => "Amorim",
    {"SA", "napoli", "andre zambo anguissa"} => "Frank Anguissa",
    {"SA", "frosinone", "ben lhassine kone"} => "Benjamin Lhassine Kone",
    {"SA", "sassuolo", "benjamin dominguez"} => "Benja Domínguez",
    {"SA", "fiorentina", "christ ravynel inao oulai"} => "Christ Inao Oulaï",
    {"SA", "monza", "dany mota carvalho"} => "Dany Mota",
    {"SA", "genoa", "ethan meichtry"} => "Franz-Ethan Meichtry",
    {"SA", "fiorentina", "joao mario lopes"} => "João Mário",
    {"SA", "cagliari", "juan martin rodriguez"} => "Juan Rodríguez",
    {"SA", "venezia", "lamine dabo"} => "Lamine Fanne",
    {"SA", "monza", "manga foe ondoa"} => "Foe Ondoa",
    {"SA", "inter", "marcus thuram ulien"} => "Marcus Thuram",
    {"SA", "venezia", "mohamed malang toure"} => "Mohamed Toure",
    {"SA", "lazio", "mohamed salim fares"} => "Mohamed Fares",
    {"SA", "napoli", "nikita contini baranovsky"} => "Nikita Contini",
    {"SA", "sassuolo", "rafa obrador"} => "Rafael Obrador",
    {"SA", "cagliari", "ze pedro figueiredo"} => "Zé Pedro",
    {"SA", "venezia", "thorir johann helgason"} => "Thórir Helgason",
    {"FL1", "angers", "mamadou usman simbakoli"} => "Usman Simbakoli",
    {"FL1", "strasbourg", "maximillian oyedele"} => "Maxi Oyedele",
    {"FL1", "rennes", "musa al taamari"} => "Mousa Al Tamari",
    {"BL1", "bayern munchen", "david daiber"} => "David Santos Daiber",
    {"BL1", "stuttgart", "jeremy"} => "Jeremy Arévalo",
    {"BL1", "paderborn", "luka duric"} => "Luka Djuric",
    {"FL1", "strasbourg", "diogo lobao"} => "Diogo Lobo",
    {"FL1", "toulouse", "francis abu"} => "Abu Francis",
    {"FL1", "angers", "marius louar"} => "Marius Louër",
    {"PD", "getafe", "chrisantus"} => "Christantus Uche",
    {"PD", "elche", "fernando nino"} => "Fer Niño",
    {"PD", "real madrid", "ilya voloshyn"} => "Ilia Voloshyn",
    {"PD", "atletico madrid", "kang in lee"} => "Lee Kang-In",
    {"PD", "sevilla", "miguel angel sierra"} => "Miguel Sierra",
    {"PD", "rayo vallecano", "morro"} => "Miguel Morro",
    {"PD", "espanyol", "muneco"} => "Alejandro Santiago",
    {"PD", "barcelona", "pablo gavira"} => "Gavi",
    {"PD", "malaga", "rafa garrido"} => "Rafita",
    {"PD", "getafe", "yvan neyou"} => "Yvan Neyou Noupa",
    {"PD", "barcelona", "alex balde"} => "Alejandro Balde",
    {"PL", "bournemouth", "ben doak"} => "Ben Gannon-Doak",
    {"PL", "everton", "briaden graham"} => "Braiden Graham",
    {"PL", "newcastle united", "dan burn"} => "Daniel Burn",
    {"PL", "nottingham forest", "jair paula"} => "Jair Cunha",
    {"PL", "leeds united", "mateo fernandez"} => "Mateo Joseph",
    {"PL", "everton", "thomas king"} => "Tom King",
    {"BL1", "borussia dortmund", "enzo dos santos"} => "Enzo Duarte",
    {"BL1", "freiburg", "ifechukwu ogbus"} => "Bruno Ogbus",
    {"BL1", "rb leipzig", "suleman sani"} => "Sani Suleiman",
    {"FL1", "le havre", "andy logbo"} => "Élysée Logbo",
    {"FL1", "nice", "brad mantsounga"} => "Brad-Hamilton Mantsounga",
    {"FL1", "troyes", "elijah olaniyi odede"} => "Elijah Odede",
    {"FL1", "auxerre", "xiangxin wei"} => "Wei Xiangxin",
    {"PD", "getafe", "femenia far"} => "Kiko",
    {"PD", "getafe", "ibra danfakha"} => "Ibrahima Danfakha",
    {"PD", "sevilla", "nicolas guillen"} => "Nico Guillen",
    {"PL", "sunderland", "aji alese"} => "Ajibola Alese",
    {"PL", "brentford", "josh dasilva"} => "Joshua Dasilva",
    {"SA", "venezia", "calixte ligue"} => "Junior Ligue",
    {"SA", "torino", "faustino anjorin"} => "Tino Anjorin",
    {"SA", "como", "suliman mustapha"} => "Marlon Mustapha",
    {"SA", "fiorentina", "victor valdepenas"} => "Valde",
    {"PD", "osasuna", "raul"} => "Raúl García",
    {"PD", "malaga", "chupete"} => "Chupe",
    {"FL1", "lille", "tiago fonseca morais"} => "Tiago Morais",
    {"FL1", "lorient", "souleymane isaak toure"} => "Souleymane Touré",
    {"PL", "bournemouth", "dorde petrovic"} => "Djordje Petrović",
    {"BL1", "werder bremen", "arthur augusto"} => "Arthur",
    {"BL1", "eintracht frankfurt", "kaua santos"} => "Kauã",
    {"FL1", "lyon", "alejandro rodriguez"} => "Alejandro Gomes Rodríguez",
    {"FL1", "le mans", "bilal brahimi"} => "Billal Brahimi",
    {"FL1", "le mans", "habib diallo"} => "Habibou Mouhamadou Diallo",
    {"FL1", "paris saint germain", "pedro fernandez"} => "Dro Fernández",
    {"FL1", "lens", "pierre ganiou"} => "Ismaëlo Ganiou",
    {"FL1", "auxerre", "remy labeau lascary"} => "Rémy Lascary",
    {"PD", "rayo vallecano", "alexandre alemao"} => "Alemão",
    {"PD", "sevilla", "castrin"} => "Andrés López",
    {"PD", "atletico madrid", "daniel martinez"} => "Dani Martínez",
    {"PD", "real betis", "francisco garcia"} => "Fran García",
    {"PD", "racing santander", "jose manuel"} => "Manu",
    {"PD", "villarreal", "santiago comesana"} => "Santi Comesaña",
    {"PD", "real betis", "alvaro valles rosa"} => "Álvaro Vallés",
    {"PD", "espanyol", "angel fortuno vinas"} => "Ángel Fortuño",
    {"PD", "sevilla", "jesus morales"} => "Jesús Cruz",
    {"PL", "brentford", "gustavo gomes"} => "Gustavo Nunes",
    {"PL", "fulham", "kevin santos"} => "Kevin",
    {"SA", "parma", "jose romero"} => "David Romero",
    {"SA", "lazio", "oliver nielsen"} => "Oliver Provstgaard",
    {"SA", "fiorentina", "pedro goncalves"} => "Pote",
    {"SA", "genoa", "vitor oliveira"} => "Vítinha",
    {"PD", "deportivo a coruna", "peke"} => "Yeremay Hernández",
    {"PD", "deportivo a coruna", "noe carrillo"} => "Noé",
    {"PL", "brentford", "ji soo kim"} => "Kim Ji-Soo"
  }

  # Official club/league references recorded in TASK-094 disambiguate homonyms.
  @birth_dates %{
    {"BL1", "mainz", "fabio gruber"} => "2002-09-03",
    {"FL1", "le mans", "djibril sidibe"} => "1992-07-29",
    {"FL1", "auxerre", "mamadou diop"} => "2000-01-03",
    {"PD", "real madrid", "ibrahima konate"} => "1999-05-25",
    {"SA", "lecce", "mohamed kaba"} => "2001-10-27",
    {"PD", "malaga", "rafita"} => "2004-11-09",
    {"PD", "osasuna", "raul garcia"} => "2000-11-03",
    {"PL", "bournemouth", "djordje petrovic"} => "1999-10-08",
    {"BL1", "eintracht frankfurt", "kaua"} => "2003-04-11",
    {"PD", "real betis", "fran garcia"} => "1999-08-14",
    {"PD", "sevilla", "andres lopez"} => "2003-05-26",
    {"PD", "racing santander", "manu"} => "1998-07-19",
    {"PD", "deportivo a coruna", "noe"} => "2006-12-28",
    {"SA", "lazio", "patric"} => "1993-04-17",
    {"PL", "brentford", "kim ji soo"} => "2004-12-24"
  }

  # The public index duplicates Kaba's name, club and birthday under an obsolete
  # ID. Patric's public profile is absent from the index. These scoped IDs use
  # reviewed public profile/birthday evidence; all history and match validation
  # still applies, including unsupported coverage for an absent season.
  @source_ids %{
    {"SA", "lecce", "mohamed kaba"} => "1299869",
    {"SA", "lazio", "patric"} => "358149",
    {"PL", "brentford", "kim ji soo"} => "1341538"
  }

  def source_id(name, league, team),
    do: Map.get(@source_ids, key(canonical_name(name, league, team), league, team))

  def search_name(name, league, team) do
    canonical_name(name, league, team)
  end

  def search_terms(name, league, team) do
    primary = search_name(name, league, team)
    last = primary |> String.split() |> List.last()

    [primary, last, normalize(primary)]
    |> Enum.filter(&(is_binary(&1) and (&1 == primary or String.length(&1) >= 3)))
    |> Enum.uniq()
    |> Enum.take(3)
  end

  def birth_date(name, league, team),
    do: Map.get(@birth_dates, key(canonical_name(name, league, team), league, team))

  defp canonical_name(name, league, team) do
    Map.get(@aliases, key(name, league, team), name)
  end

  def equivalent?(left, right, league, team) do
    left = identity_key(canonical_name(left, league, team))
    right = identity_key(canonical_name(right, league, team))
    left != "" and left == right
  end

  defp key(name, league, team),
    do: {league, TeamIdentity.normalize(team, league), normalize(name)}

  defp identity_key(name), do: name |> normalize() |> String.replace(" ", "")

  defp normalize(name) when is_binary(name) do
    name
    |> String.downcase()
    |> String.replace(["ø", "æ", "ı", "ł", "đ", "ð", "þ", "ß"], fn
      "ø" -> "o"
      "æ" -> "ae"
      "ı" -> "i"
      "ł" -> "l"
      "đ" -> "d"
      "ð" -> "d"
      "þ" -> "th"
      "ß" -> "ss"
    end)
    |> :unicode.characters_to_nfd_binary()
    |> String.replace(~r/\p{Mn}/u, "")
    |> String.replace(~r/['’]/u, "")
    |> String.replace(~r/[^a-z0-9]+/u, " ")
    |> String.split()
    |> Enum.join(" ")
  end

  defp normalize(_), do: ""
end
